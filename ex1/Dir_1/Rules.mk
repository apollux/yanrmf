SUBDIRS = Dir_1a Dir_1b

LIBRARIES = libdir1.a
SRCS = *.c
libdir1.a_DEPS = $(OBJS_$(d)) $(OBJS_$(d)/Dir_1b)
