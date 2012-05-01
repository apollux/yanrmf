SRCS := dir_2a_file1.c dir_2a_file2.c dir_2a_file3.c

LIBRARIES = libdir2a.so
libdir2a.so_DEPS = $(OBJS)
