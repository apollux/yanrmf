CFLAGS = -W -Wall
CXXFLAGS = -W -Wall -Wold-style-cast -std=c++0x
CPPFLAGS = -MMD -MP -pthread -DDEBUG -ggdb $(addprefix -I,$(INCLUDES_LOCATIONS))
INCLUDES_LOCATIONS := . ./include

# Linker flags. The values below will use what you've specified for
# particular target or directory but if you have some flags or libraries
# that should be used for all targets/directories just append them at end.
LDFLAGS = $(LDFLAGS_$(@)) $(addprefix -L,$(LIBDIRS_$(subst /$(OBJDIR),,$(@D))))
LDLIBS = $(LIBS_$(@))

include $(MK)/helper_functions.mk
include $(MK)/config.mk

# Where to put the compiled objects.  You can e.g. make it different
# depending on the target platform (e.g. for cross-compilation a good
# choice would be OBJDIR := obj/$(HOST_ARCH)) or debugging being on/off.
OBJECT_PATH = $(BUILD_DIRECTORY)/$(call relative_path,$(TOP),$(d))/$(OBJDIR)
LIBRARY_PATH = $(BUILD_DIRECTORY)/$(call relative_path,$(TOP),$(d))/$(LIBDIR)
EXECUTABLE_PATH = $(BUILD_DIRECTORY)/$(call relative_path,$(TOP),$(d))/$(EXEDIR)


# Magic happens here. This traverses the directory structure to include all 
# Rules.mk files and build the rules.

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


COMPILE.c = $(call echo_cmd,CC $<,$(COLOR_BROWN)) $(CC) $(CPPFLAGS) $(CFLAGS) -c
COMPILE.cpp = $(call echo_cmd,CXX $<,$(COLOR_BROWN)) $(CXX) $(CPPFLAGS) $(CXXFLAGS) -c
COMPILECMD = $(COMPILE$(suffix $<)) -o $@ $<

LIBRARY_BUILDER.so = $(call echo_cmd,Creating library $@,$(COLOR_PURPLE))\
  $(CC) -fPIC -shared -o
LIBRARY_BUILDER.a = $(call echo_cmd,Creating archive $@,$(COLOR_PURPLE)) $(AR) rcs
LIBRARY_BUILDER = $(LIBRARY_BUILDER$(suffix $@)) $@ $(filter-out %/Rules.mk,$^)

EXECUTABLE_BUILDER = $(call echo_cmd,Creating executable $@,$(COLOR_GREEN))\
  $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(LDFLAGS) -o $@ $(filter %.o,$(filter-out %/Rules.mk,$^)) $(filter-out %.o,$(filter-out %/Rules.mk,$^))

# Argument 1 directory which should be created
define directory_skeleton
$(1):
	@[ -d $(1) ] ||\
	$(if $(findstring true,$(VERBOSE)), echo "creating directory: $(1)"; )\
	mkdir -p $(1)
endef


# Argument 1 directory for which the skeleton is created
define object_skeleton
# Rule to create object from .cpp file
$(OBJECT_PATH)/%.o: $(1)/%.cpp | $(OBJECT_PATH)
	$(value COMPILECMD)

# Rule to create object from .c file
$(OBJECT_PATH)/%.o: $(1)/%.c | $(OBJECT_PATH)
	$(value COMPILECMD)
endef


# Argument 1 library for which the skeleton is created
define library_skeleton
# absolute paths are needed for the prerequisites 
abs_deps := $$(filter /%,$$(DEPS_$(1)))
rel_deps := $$(filter-out /%,$$(DEPS_$(1)))
abs_deps += $$(addprefix $(LIBRARY_PATH)/,$$(filter %.a,$$(rel_deps)))
abs_deps += $$(addprefix $(OBJECT_PATH)/,$$(filter %.o,$$(rel_deps)))
#todo! special case for .so
$(1): $$(abs_deps) | $(LIBRARY_PATH)
	$(value LIBRARY_BUILDER)
endef


# Argument 1 executable for which the skeleton is created
define executable_skeleton
# absolute paths are needed for the prerequisites 
abs_deps := $$(filter /%,$$(DEPS_$(1)))
rel_deps := $$(filter-out /%,$$(DEPS_$(1)))
abs_deps += $$(addprefix $(OBJECT_PATH)/,$$(filter %.o,$$(rel_deps)))
abs_deps += $$(addprefix $(LIBRARY_PATH)/,$$(filter %.a,$$(rel_deps)))
#todo! special case for .so
$(1): $$(abs_deps) | $(EXECUTABLE_PATH)
	$(value EXECUTABLE_BUILDER)
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

