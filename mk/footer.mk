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
##

-include $(addprefix $(OBJPATH)/,$(addsuffix .d,$(basename $(SRCS))))

# Use the object_skeleton for the "current dir"
$(eval $(call directory_skeleton,$(OBJPATH)))
$(eval $(call object_skeleton,$(d)))
# and for each SRCS_VPATH subdirectory of "current dir"
$(foreach vd,$(SRCS_VPATH),$(eval $(call skeleton,$(d)/$(vd))))

ifdef LIBRARIES
$(eval $(call directory_skeleton,$(LIBRARY_PATH)))
LIBRARIES_$(d) := $(addprefix $(LIBRARY_PATH)/,$(LIBRARIES))

$(foreach lib,LIBRARIES,$(eval $(call library_skeleton, $(lib))))
endif

#$(LIBRARIES_$(d))
TARGETS_$(d) := $(OBJS_$(d)) 

# $(call subtree_rules_file,$(d))
dir_$(d) : $(TARGETS_$(d))
	@echo $(LIBRARIES)
	@echo $(DEBUG)
	@echo Dependencies for this directory: $^ 
