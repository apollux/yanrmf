# convenience variable to have a ',' char in a string
comma := ,

include $(MK)/helper_functions.mk

INCLUDES_LOCATIONS := 
SYSTEM_INCLUDES_LOCATIONS :=


# Convenience variable for unit test runner.
TEST_OBJS :=

# Linker flags. The value below will use what you've specified for
# particular target. If you have some flags or libraries
# that should be used for all targets just append them in the project config
LDFLAGS = $(LDFLAGS_$(@))

# Include builders
include $(wildcard $(MK)/builders/*.mk)

# Get project config defaults.
include $(MK)/project_config.mk
# Get user config to override project settings.
-include $(MK)/user_config.mk

# Two variants supported: debug and release. If no VARIANT is set, default to
# debug.
VARIANT := $(if $(findstring undefined,$(origin VARIANT)),debug,\
  $(if $(findstring debug,$(VARIANT)),debug,\
  $(if $(findstring release,$(VARIANT)),release,$(error invalid variant))))

# Unleash the full power of make!
# Determine how many concurrent jobs may be executed
ifdef JOBS
MAKEFLAGS += -j $(JOBS)
else
MAKEFLAGS += -j $(shell grep processor /proc/cpuinfo | wc -l)
endif

# Where to put the compiled binaries.
# In the $(BUILD_DIRECTORY) the project folder structre is copied, build variant folders and
# seperate folders for objects, libraries and executables are added.
OBJECT_PATH = $(BUILD_DIRECTORY)/$(call relative_path,$(TOP),$(d))/$(VARIANT)/$(OBJDIR)
LIBRARY_PATH = $(BUILD_DIRECTORY)/$(call relative_path,$(TOP),$(d))/$(VARIANT)/$(LIBDIR)
EXECUTABLE_PATH = $(BUILD_DIRECTORY)/$(call relative_path,$(TOP),$(d))/$(VARIANT)/$(EXEDIR)

# convenience variable to get the 'real' dependencies of a target, so the object files and or libraries
SANITIZED_^ = $(filter-out %/Rules.mk,$^)


# This function traverses the directory structure to include all 
# Rules.mk files and build the rules of the subdirectory. This basically is the
# most important part of the framework.
define include_subdir_rules
dir_stack := $(d) $(dir_stack)
d := $(d)/$(1)
include $(MK)/header.mk
include $(addsuffix /Rules.mk,$$(d))
include $(MK)/footer.mk
d := $$(firstword $$(dir_stack))
dir_stack := $$(wordlist 2,$$(words $$(dir_stack)),$$(dir_stack))
endef


# Creates a list of all targets of the subtree
define subtree_targets
$(TARGETS_$(1)) $(foreach sd,$(SUBDIRS_$(1)),$(call subtree_targets,$(sd)))
endef


# Argument 1 directory which should be created
define directory_skeleton
$(1):
	@[ -d $(1) ] ||\
	$(if $(findstring true,$(VERBOSE)), echo "creating directory: $(1)"; )\
	mkdir -p $(1)
endef


# Argument 1 directory for which the skeleton is created
define object_skeleton
# Rule to create object from .cpp file.
# An 'order-only' ('|') prerequisite is placed on the output directory. It must
# exist before trying to put files in it.
$(OBJECT_PATH)/%.o: $(1)/%.cpp | $(OBJECT_PATH)
	$(value OBJECT_BUILDER_SELECTOR)

# Rule to create object from .c file
# An 'order-only' ('|') prerequisite is placed on the output directory. It must
# exist before trying to put files in it.
$(OBJECT_PATH)/%.o: $(1)/%.c | $(OBJECT_PATH)
	$(value OBJECT_BUILDER_SELECTOR)
endef


# Argument 1 library for which the skeleton is created
define library_skeleton
# absolute paths are needed for the prerequisites 
# only dependencies on objects are expected
abs_deps := $$(filter /%,$$(DEPS_$(1)))
rel_deps := $$(filter-out /%,$$(DEPS_$(1)))
abs_deps += $$(addprefix $(OBJECT_PATH)/,$$(filter %.o,$$(rel_deps)))

# An 'order-only' ('|') prerequisite is placed on the output directory. It must
# exist before trying to put files in it.
$(1): $$(abs_deps) | $(LIBRARY_PATH)
	$(value LIBRARY_BUILDER_SELECTOR)
ifeq ($(VARIANT),release)
ifeq ($(suffix $(1)),.so)
	@objcopy --only-keep-debug $(1) $(1).debug
	@strip --strip-debug --strip-unneeded $(1)
	@objcopy --add-gnu-debuglink=$(1).debug $(1)
endif
endif
endef


# Argument 1 executable for which the skeleton is created
define executable_skeleton
# absolute paths are needed for the prerequisites 
abs_deps := $$(filter /%,$$(DEPS_$(1)))
rel_deps := $$(filter-out /%,$$(DEPS_$(1)))
abs_deps += $$(addprefix $(LIBRARY_PATH)/,$$(filter %.so,$$(rel_deps)))
abs_deps += $$(addprefix $(LIBRARY_PATH)/,$$(filter %.a,$$(rel_deps)))
abs_deps += $$(addprefix $(OBJECT_PATH)/,$$(filter %.o,$$(rel_deps)))

# An 'order-only' ('|') prerequisite is placed on the output directory. It must
# exist before trying to put files in it.
$(1): $$(abs_deps) | $(EXECUTABLE_PATH)
	$(value EXECUTABLE_BUILDER_SELECTOR)
ifeq ($(VARIANT),release)
	@objcopy --only-keep-debug $(1) $(1).debug
	@strip --strip-debug --strip-unneeded $(1)
	@objcopy --add-gnu-debuglink=$(1).debug $(1)
endif
endef

# Store al dependencies from the current Rules.mk for the target passed as
# Argument 1 in DEPS_<absolute path to target>
# This assumes all dependencies on a library are object files.
define save_target_variables
#full path to target is passed as argument 1 need to get to <target name>_DEPS
DEPS_$(1) = $$($(notdir $(1))_DEPS)

# save linker flags for target, this saves it for all targets but it makes only
# sense for EXECUTABLES. However it's not a problem to save the value for all
# kind of targets
LDFLAGS_$(1) = $$($(notdir $(1))_LDFLAGS)
endef


# Include dependancy files for object targets if exists.
# Argument 1 list with full path to object for which dependency files should be
# included.
# This assumes .d files live at the same location as corresponding .o files.
define include_dependency_files
-include $(addsuffix .d,$(basename $(filter %.o,$(1))))
endef

