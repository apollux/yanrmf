CFLAGS = -g -W -Wall
CXXFLAGS = -g -W -Wall

INCLUDES_LOCATIONS := .

# Here's an example of settings for preprocessor.  -MMD is to
# automatically build dependency files as a side effect of compilation.
# This has some drawbacks (e.g. when you move/rename a file) but it is
# good enough for me.  You can improve this by using a special script
# that builds the dependency files (one can find examples on the web).
# Note that I'm adding DIR_INCLUDES before INCLUDES so that they have
# precedence.
CPPFLAGS = -MMD -D_REENTRANT -D_POSIX_C_SOURCE=200112L -D__EXTENSIONS__ \
	   -DDEBUG $(addprefix -I,$(INCLUDES_LOCATIONS))

# Linker flags.  The values below will use what you've specified for
# particular target or directory but if you have some flags or libraries
# that should be used for all targets/directories just append them at end.
LDFLAGS = $(LDFLAGS_$(@)) $(addprefix -L,$(LIBDIRS_$(subst /$(OBJDIR),,$(@D))))
LDLIBS = $(LIBS_$(@))

include $(MK)/helper_functions.mk
include $(MK)/config.mk

# ... and here's a good place to translate some of these settings into
# compilation flags/variables.  As an example a preprocesor macro for
# target endianess
#ifeq ($(ENDIAN),big)
#  CPPFLAGS += -DBIG_ENDIAN
#else
#  CPPFLAGS += -DLITTLE_ENDIAN
#endif

# Where to put the compiled objects.  You can e.g. make it different
# depending on the target platform (e.g. for cross-compilation a good
# choice would be OBJDIR := obj/$(HOST_ARCH)) or debugging being on/off.
ifeq ($(TOP), $(d))
RELPATH = 
else
RELPATH = $(patsubst $(TOP)/%,%,$(d))
endif
OBJPATH = $(BUILD_DIRECTORY)/$(RELPATH)/$(OBJDIR)
LIBRARY_PATH = $(BUILD_DIRECTORY)/$(RELPATH)/$(LIBDIR)

define include_subdir_rules
dir_stack := $(d) $(dir_stack)
d := $(d)/$(1)
include $(MK)/header.mk
include $(addsuffix /Rules.mk,$$(d))
include $(MK)/footer.mk
d := $$(firstword $$(dir_stack))
dir_stack := $$(wordlist 2,$$(words $$(dir_stack)),$$(dir_stack))
endef

COMPILE.c = $(call echo_cmd,CC $<) $(CC) 

COMPILECMD = $(COMPILE$(suffix $<)) -o $@ $<

define directory_skeleton
$(1): 
	@echo make sure $(1) exists
	@[ -d $(1) ] || echo "creating directory: $(1)"; mkdir -p $(1)
endef

define object_skeleton
$(OBJPATH)/%.o: $(1)/%.cpp | $(OBJPATH)
	@echo object rule from cpp

$(OBJPATH)/%.o: $(1)/%.c | $(OBJPATH)
	@echo object rule from c
	$(value COMPILECMD)
endef

define library_skeleton
DEBUG = $(LIBRARY_PATH)/$(1)
$(LIBRARY_PATH)/$(1):
	@echo "creating library

#$(LIBRARY_PATH)/%.ext: $(1)/%.cpp | $(LIBRARY_PATH)
#	@echo object rule from cpp

endef

# Suck in the default rules
#include $(MK)/def_rules.mk
