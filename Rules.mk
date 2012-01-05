SUBDIRS = ex1
SRCS = blaat.c 
LIBRARIES = libblaat.so libblaat.a
libblaat.so_DEPS = blaat.o blaat2.o
libblaat.a_DEPS = blaat.o blaat2.o

EXECUTABLES = runner

runner_DEPS = main.o libblaat.a
