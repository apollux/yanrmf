SUBDIRS = ex1
SRCS = blaat.c blaat2.c
LIBRARIES = libblaat.so libblaat.a
libblaat.so_DEPS = blaat.o blaat2.o
libblaat.a_DEPS = blaat.o blaat2.o

