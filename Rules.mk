SUBDIRS = ex1 
LIBRARIES = libblaat.a
libblaat.a_DEPS = Blaat.o blaat2.o

EXECUTABLES = runner
runner_DEPS = main.o libblaat.a

