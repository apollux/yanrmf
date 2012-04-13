# You can use wildcards in SRCS - they are detected and expanded by this
# make system (not make itself). 
SRCS = *.c
LIBRARIES = dir_1a.a
dir_1a.a_DEPS = $(OBJS)
