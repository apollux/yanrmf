SUBDIRS = ex1
#SRCS = blaat.c blaat2.c
SRCS_VPATH = src
SHARED_LIBRARIES = libblaat.so
libblaat.so_DEPS = blaat.o blaat2.o
libblaat2.so_DEPS = blaat2.o


