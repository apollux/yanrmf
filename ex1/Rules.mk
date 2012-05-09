SUBDIRS = Dir_1 Dir_2
SRCS = *.cpp *.c
EXECUTABLES = top_app1 main

top_app1_DEPS = top_app1.o top_a.o $(LIBRARIES_$(d)/Dir_1) $(LIBRARIES_$(d)/Dir_1/Dir_1a)
top_app1_LDFLAGS = -lpthread

main_DEPS = main.o $(LIBRARIES_$(d)/Dir_2) $(LIBRARIES_$(d)/Dir_2/Dir_2a)

