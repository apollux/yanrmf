CFLAGS = -W -Wall
CXXFLAGS = -W -Wall -Wold-style-cast -std=c++0x
CPPFLAGS = -MMD -MP -pthread -DDEBUG -ggdb $(addprefix -I,$(INCLUDES_LOCATIONS))
INCLUDES_LOCATIONS := .

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
OBJPATH = $(BUILD_DIRECTORY)/$(call relative_path,$(TOP),$(d))/$(OBJDIR)
LIBRARY_PATH = $(BUILD_DIRECTORY)/$(call relative_path,$(TOP),$(d))/$(LIBDIR)


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
LIBRARY_BUILDER = $(LIBRARY_BUILDER$(suffix $@)) $@ $^

# Argument 1 directory which should be created
define directory_skeleton
$(1):
	@[ -d $(1) ] ||\
	$(if $(findstring true,$(VERBOSE)), echo "creating directory: $(1)"; )\
	mkdir -p $(1)
endef


# Argument 1 directory for which the skeleton is created
# Argument 2 extra dependency if applicable
define object_skeleton
# Rule to create object from .cpp file
$(OBJPATH)/%.o: $(1)/%.cpp $(2)| $(OBJPATH)
	$(value COMPILECMD)

# Rule to create object from .c file
$(OBJPATH)/%.o: $(1)/%.c $(2)| $(OBJPATH)
	$(value COMPILECMD)
endef


# Argument 1 library for which the skeleton is created
define library_skeleton
$(1): $(DEPS_$(1)) | $(LIBRARY_PATH)
	$(value LIBRARY_BUILDER)
endef


# Store al dependencies from the current Rules.mk for the current library
# in DEPS_<absolute path to library>
# This assumes all dependencies on a library are object files.
define save_library_deps
deps = $$($(1)_DEPS)

# absolute paths are needed for the prerequisites 
abs_deps := $$(filter /%,$$(deps))
rel_deps := $$(filter-out /%,$$(deps))
abs_deps += $$(addprefix $(OBJPATH)/,$$(rel_deps))
DEPS_$(LIBRARY_PATH)/$(1) = $$(abs_deps)
endef


# Include dependancy files for object targets if exists.
# Argument 1 list with full path to object for which dependency files should be
# included.
# This assumes .d files live at the same location as corresponding .o files.
define include_dependency_files
-include $(addsuffix .d,$(basename $(filter %.o,$(1))))
endef

