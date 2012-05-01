CFLAGS = -W -Wall -fPIC
CXXFLAGS = -Wold-style-cast -std=c++0x -Werror -pedantic-errors -fPIC
CFLAGS_DEBUG = -ggdb
CFLAGS_RELEASE = -O2 -DNDEBUG 
CPPFLAGS = -MMD -MP -pthread $(addprefix -I,$(INCLUDES_LOCATIONS))\
  $(addprefix -isystem,$(SYSTEM_INCLUDES_LOCATIONS)) 


OBJECT_BUILDER.c = $(call echo_cmd,CC $<,$(COLOR_BROWN)) $(CC) $(CPPFLAGS) $(CFLAGS) \
  $(if $(findstring debug,$(VARIANT)),$(CFLAGS_DEBUG),$(CFLAGS_RELEASE)) -c
OBJECT_BUILDER.cpp = $(call echo_cmd,CXX $<,$(COLOR_BROWN)) $(CXX) $(CPPFLAGS) $(CXXFLAGS) \
  $(if $(findstring debug,$(VARIANT)),$(CFLAGS_DEBUG),$(CFLAGS_RELEASE)) -c
OBJECT_BUILDER_SELECTOR	 = $(OBJECT_BUILDER$(suffix $<)) -o $@ $<

# Library builders
LIBRARY_BUILDER.so = $(call echo_cmd,Creating library $@,$(COLOR_PURPLE))\
  $(CC) -shared -o
#remove existing archive before creating new one. Objects no longer in use could still remain in archive
LIBRARY_BUILDER.a = $(call echo_cmd,Creating archive $@,$(COLOR_PURPLE)) if [ -e $@ ] ; then rm $@; fi && $(AR) rcs
LIBRARY_BUILDER_SELECTOR = $(LIBRARY_BUILDER$(suffix $@)) $@ $(SANITIZED_^)

# Command to create executable
# Object files are passed to linker before archives to prevent linking errors.
# It is a bit of a hack but seems sufficient.
# If executable depends on $(TOP)/path/to/foo/libfoo.so the following happens:
# The library location is passed with -L/full/path/to/foo/ to g++, -lfoo is passed to g++ to indicata
# a required library. The -rpath with /full/path/to/foo is passed to linker. So the runtime linker
# can find the shared objects. Useful in development.
SO_LOCATIONS = $(dir $(filter %.so,$(SANITIZED_^)))
SO_LIB_NAMES = $(subst lib,,$(basename $(notdir $(filter %.so,$(SANITIZED_^)))))
EXECUTABLE_BUILDER = $(call echo_cmd,Creating executable $@,$(COLOR_GREEN)) \
  $(CXX) $(CXXFLAGS) $(CPPFLAGS)\
  $(if $(findstring debug,$(VARIANT)),$(CFLAGS_DEBUG),$(CFLAGS_RELEASE)) \
  -o $@ $(filter %.o,$(SANITIZED_^)) $(filter %.a,$(SANITIZED_^)) $(LDFLAGS)\
  $(addprefix -L,$(SO_LOCATIONS)) $(addprefix -l,$(SO_LIB_NAMES)) $(addprefix -Wl$(comma)-rpath ,$(SO_LOCATIONS)) -Wl$(comma)--enable-new-dtags

EXECUTABLE_BUILDER_SELECTOR = $(EXECUTABLE_BUILDER)
