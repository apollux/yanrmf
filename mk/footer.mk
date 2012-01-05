# save full path to the subdirs of the current directory
SUBDIRS_$(d) := $(patsubst %/,%,$(addprefix $(d)/,$(SUBDIRS)))

# check if OBJS are defined in current Rules.mk
ifneq ($(strip $(OBJS)),)
  OBJS_$(d) := $(addprefix $(OBJPATH)/,$(OBJS))
else # Populate OBJS_ from SRCS

  # Expand wildcards in SRCS if they are given
  ifneq ($(or $(findstring *,$(SRCS)),$(findstring ?,$(SRCS)),$(findstring ],$(SRCS))),)
    SRCS := $(notdir $(foreach sd,. $(SRCS_VPATH),$(wildcard $(addprefix $(d)/$(sd)/,$(SRCS)))))
  endif

  OBJS_$(d) := $(addprefix $(OBJPATH)/,$(addsuffix .o,$(basename $(SRCS))))
endif

# Use the object_skeleton for the "current dir"
$(eval $(call directory_skeleton,$(OBJPATH)))

$(eval $(call object_skeleton,$(d),$(d)/Rules.mk))
# and for each SRCS_VPATH subdirectory of "current dir"
$(foreach vd,$(SRCS_VPATH),$(eval $(call object_skeleton,$(d)/$(vd),$(d)/Rules.mk)))

ifdef LIBRARIES
# dependency on target directory
$(eval $(call directory_skeleton,$(LIBRARY_PATH)))

LIBRARIES_$(d) := $(addprefix $(LIBRARY_PATH)/,$(LIBRARIES))

# get the dependencies
$(foreach lib,$(strip $(LIBRARIES)),$(eval $(call save_library_deps,$(lib))))

# create target rules
$(foreach lib,$(strip $(LIBRARIES_$(d))),$(eval $(call library_skeleton,$(lib))))

## include depency files for all prerequisites
$(foreach lib,$(strip $(SHARED_LIBRARIES_$(d))),$(eval $(call include_dependency_files,$(DEPS_$(lib)))))
endif


# Build the rules for the subtree
$(foreach sd,$(SUBDIRS),$(eval $(call include_subdir_rules,$(sd))))


TARGETS_$(d) := $(OBJS_$(d)) $(LIBRARIES_$(d)) $(call subtree_targets,$(d))

dir_$(d) : $(TARGETS_$(d))
	@echo DEBUG: $(DEBUG)
