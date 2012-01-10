SRCS = Program.cpp CppUnitWrapper.cpp
EXECUTABLES = TestRunner
TestRunner_DEPS = main.o libblaat.a

TestRunner_DEPS = $(OBJS) $(OBJECTS_UNDER_TEST) \
  $(BUILD_DIRECTORY)//cppunit/cppunit_external_build\
  $(TESTS_SRCS)\
  $(BUILD_DIRECTORY)/cppunit/lib/libcppunit.a
