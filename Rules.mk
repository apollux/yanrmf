SUBDIRS = ex1
SRCS = blaat.c 
LIBRARIES = libblaat.so libblaat.a
libblaat.so_DEPS = blaat.o blaat2.o
libblaat.a_DEPS = blaat.o blaat2.o

EXECUTABLES = runner
runner_DEPS = main.o libblaat.a

EXTERNAL_TARGETS = cppunit/cppunit_build
cppunit_build_CMD = $(call echo_cmd,Building cppunit $@,$(COLOR_RED))\
  export LIBS=-ldl; cd cppunit-1.12.1 &&\
  ./configure --prefix=$(BUILD_DIRECTORY)/cppunit $(if $(findstring true,$(VERBOSE)),,&>/dev/null)\
  && make install $(if $(findstring true,$(VERBOSE)),,&>/dev/null)\
  && touch $(BUILD_DIRECTORY)/cppunit/cppunit_build
