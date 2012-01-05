SUBDIRS = ex1
SRCS = blaat.c blaat2.c
SRCS_VPATH = src
SHARED_LIBRARIES = libblaat.so
libblaat.so_DEPS = blaat.o blaat2.o

ARCHIVES = libblaat.a
libblaat.a_DEPS = blaat.o blaat2.o

