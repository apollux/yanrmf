SUBDIRS = Dir_2a
SRCS = *.cpp

LIBRARIES = libdir_2.so
libdir_2.so_DEPS = $(OBJS_$(d))
