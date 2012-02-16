CFLAGS = -W -Wall
CXXFLAGS = -Wold-style-cast -std=c++0x -Werror -pedantic-errors
CFLAGS_DEBUG = -ggdb
CFLAGS_RELEASE = -O2 -DNDEBUG -s
CPPFLAGS = -MMD -MP -pthread $(addprefix -I,$(INCLUDES_LOCATIONS))\
  $(addprefix -isystem,$(SYSTEM_INCLUDES_LOCATIONS)) 


COMPILE.c = $(call echo_cmd,CC $<,$(COLOR_BROWN)) $(CC) $(CPPFLAGS) $(CFLAGS) \
  $(if $(findstring debug,$(VARIANT)),$(CFLAGS_DEBUG),$(CFLAGS_RELEASE)) -c
COMPILE.cpp = $(call echo_cmd,CXX $<,$(COLOR_BROWN)) $(CXX) $(CPPFLAGS) $(CXXFLAGS) \
  $(if $(findstring debug,$(VARIANT)),$(CFLAGS_DEBUG),$(CFLAGS_RELEASE)) -c
COMPILECMD = $(COMPILE$(suffix $<)) -o $@ $<

LIBRARY_BUILDER.so = $(call echo_cmd,Creating library $@,$(COLOR_PURPLE))\
  $(CC) -fPIC -shared -o
LIBRARY_BUILDER.a = $(call echo_cmd,Creating archive $@,$(COLOR_PURPLE)) $(AR) rcs
LIBRARY_BUILDER = $(LIBRARY_BUILDER$(suffix $@)) $@ $(SANITIZED_^)

# Object files are passed to linker before archives to prevent linking errors.
# It is a bit of a hack but seems sufficient.
EXECUTABLE_BUILDER = $(call echo_cmd,Creating executable $@,$(COLOR_GREEN)) \
  $(CXX) $(CXXFLAGS) $(CPPFLAGS) \
  $(if $(findstring debug,$(VARIANT)),$(CFLAGS_DEBUG),$(CFLAGS_RELEASE)) \
  -o $@ $(filter %.o,$(SANITIZED_^)) $(filter-out %.o,$(SANITIZED_^)) $(LDFLAGS)
