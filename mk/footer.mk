# save full path to the subdirs of the current directory
SUBDIRS_$(d) := $(patsubst %/,%,$(addprefix $(d)/,$(SUBDIRS)))

# check if OBJS are defined in current Rules.mk
ifneq ($(strip $(OBJS)),)
  OBJS_$(d) := $(addprefix $(OBJECT_PATH)/,$(OBJS))
else # Populate OBJS_ from SRCS

  # Expand wildcards in SRCS if they are given
  ifneq ($(or $(findstring *,$(SRCS)),$(findstring ?,$(SRCS)),$(findstring ],$(SRCS))),)
    SRCS := $(notdir $(foreach sd,. $(SRCS_VPATH),$(wildcard $(addprefix $(d)/$(sd)/,$(SRCS)))))
  endif

  OBJS := $(addsuffix .o,$(basename $(SRCS)))
  OBJS_$(d) := $(addprefix $(OBJECT_PATH)/,$(OBJS))
endif

# gather all test object locations
TEST_OBJS += $(foreach vd,. $(SRCS_VPATH),$(addsuffix .o,$(addprefix $(OBJECT_PATH)/,$(notdir $(basename $(wildcard $(d)/$(vd)/$(TESTDIR)/*.cpp))))))

# Use the object_skeleton for the "current dir"
$(eval $(call directory_skeleton,$(OBJECT_PATH)))

$(eval $(call object_skeleton,$(d)))
# and for each SRCS_VPATH subdirectory of "current dir"
$(foreach vd,$(SRCS_VPATH),$(eval $(call object_skeleton,$(d)/$(vd))))

# use object skeleton for test directories as well.
$(eval $(call object_skeleton,$(d)/$(TESTDIR)))
# and for each SRCS_VPATH subdirectory of "current dir"
$(foreach vd,$(SRCS_VPATH),$(eval $(call object_skeleton,$(d)/$(vd)/$(TESTDIR))))


ifdef LIBRARIES
# dependency on target directory
$(eval $(call directory_skeleton,$(LIBRARY_PATH)))

LIBRARIES_$(d) := $(addprefix $(LIBRARY_PATH)/,$(LIBRARIES))

# get the dependencies
$(foreach lib,$(strip $(LIBRARIES_$(d))),$(eval $(call save_target_variables,$(lib))))

# add object depencies to OBJS_$(d) this might cause duplictates in the list
# but this does not seem to be a problem...
OBJS_$(d) += $(foreach lib,$(strip $(LIBRARIES_$(d))),$(addprefix $(OBJECT_PATH)/,$(DEPS_$(lib))))
endif


ifdef EXECUTABLES
# dependency on target directory
$(eval $(call directory_skeleton,$(EXECUTABLE_PATH)))

EXECUTABLES_$(d) := $(addprefix $(EXECUTABLE_PATH)/,$(EXECUTABLES))

# get the dependencies
$(foreach exe,$(strip $(EXECUTABLES_$(d))),$(eval $(call save_target_variables,$(exe))))

# add object depencies to OBJS_$(d) this might cause duplictates in the list
# but this does not seem to be a problem...
# 
# need to filter absolute dependencies for libraries and not prefix those.
OBJS_$(d) += $(foreach exe,$(strip $(EXECUTABLES_$(d))),$(addprefix $(OBJECT_PATH)/,$(filter %.o,$(filter-out /%,$(DEPS_$(exe))))))
OBJS_$(d) += $(foreach exe,$(strip $(EXECUTABLES_$(d))),$(filter /%.o,$(DEPS_$(exe))))
endif

ifdef TEST_DEPS
abs_deps := $(filter /%,$(TEST_DEPS))
rel_deps := $(filter-out /%,$(TEST_DEPS))
abs_deps += $(addprefix $(LIBRARY_PATH)/,$(filter %.a,$(rel_deps)))
abs_deps += $(addprefix $(OBJECT_PATH)/,$(filter %.o,$(rel_deps)))

TEST_DEPENDENCIES += $(abs_deps)
endif

# Build the rules for the subtree
# Subtree rules should be build before creating recepies for current directory
# since these will probably depend on subtree targets
$(foreach sd,$(SUBDIRS),$(eval $(call include_subdir_rules,$(sd))))


ifdef LIBRARIES_$(d)
# create target rules
$(foreach lib,$(strip $(LIBRARIES_$(d))),$(eval $(call library_skeleton,$(lib))))
endif


ifdef EXECUTABLES_$(d)
# create target rules
$(foreach exe,$(strip $(EXECUTABLES_$(d))),$(eval $(call executable_skeleton,$(exe))))
endif


## include depency files for all objects
$(foreach obj,$(strip $(OBJS_$(d))),$(eval $(call include_dependency_files,$(obj))))

#every target in this directory depends on Rules.mk
$(EXTERNAL_TARGETS_$(d)) $(OBJS_$(d)) $(LIBRARIES_$(d)) $(EXECUTABLES_$(d)): $(d)/Rules.mk

TARGETS_$(d) := $(EXTERNAL_TARGETS_$(d)) $(OBJS_$(d)) $(LIBRARIES_$(d)) $(EXECUTABLES_$(d)) $(call subtree_targets,$(d))

dir_$(d) : $(TARGETS_$(d))
