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

$(eval $(call object_skeleton,$(d)))
# and for each SRCS_VPATH subdirectory of "current dir"
$(foreach vd,$(SRCS_VPATH),$(eval $(call skeleton,$(d)/$(vd))))

ifdef SHARED_LIBRARIES
# dependency on target directory
$(eval $(call directory_skeleton,$(LIBRARY_PATH)))

SHARED_LIBRARIES_$(d) := $(addprefix $(LIBRARY_PATH)/,$(SHARED_LIBRARIES))

# get the dependencies
$(foreach lib,$(strip $(SHARED_LIBRARIES)),$(eval $(call save_shared_library_deps,$(lib))))
# create target rules
$(foreach lib,$(strip $(SHARED_LIBRARIES_$(d))),$(eval $(call shared_library_skeleton,$(lib))))
endif

$(foreach sd,$(SUBDIRS),$(eval $(call include_subdir_rules,$(sd))))

TARGETS_$(d) := $(OBJS_$(d)) $(SHARED_LIBRARIES_$(d))

## $(call subtree_rules_file,$(d))
dir_$(d) : $(TARGETS_$(d))
	@echo DEBUG $(DEBUG)

