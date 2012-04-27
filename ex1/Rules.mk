SUBDIRS = Dir_1 Dir_2
SRCS = *.cpp *.c
#Dir_2 Dir_3
EXECUTABLES = top_app1 main

#app_DEPS = main.o top_a.o top_b.o $(LIBRARIES_$(d)/Dir_1) 
#app_LDFLAGS = -lpthread

top_app1_DEPS = top_app1.o top_a.o $(LIBRARIES_$(d)/Dir_1) $(LIBRARIES_$(d)/Dir_1/Dir_1a)

main_DEPS = main.o $(LIBRARIES_$(d)/Dir_2)


