SUBDIRS = ex1 testrunner
LIBRARIES = libblaat.so libblaat.a
libblaat.so_DEPS = Blaat.o blaat2.o
libblaat.a_DEPS = Blaat.o blaat2.o

EXECUTABLES = runner
runner_DEPS = main.o libblaat.a

EXTERNAL_TARGETS = cppunit/cppunit_external_build
cppunit_external_build_CMD = $(call echo_cmd,Building cppunit $@,$(COLOR_RED))\
  export LIBS=-ldl; cd cppunit-1.12.1 &&\
  ./configure --prefix=$(BUILD_DIRECTORY)/cppunit $(if $(findstring true,$(VERBOSE)),,&>/dev/null)\
  && make install $(if $(findstring true,$(VERBOSE)),,&>/dev/null)\
  && touch $(BUILD_DIRECTORY)/cppunit/cppunit_external_build
