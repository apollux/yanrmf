SUBDIRS = Dir_1 
#Dir_2 Dir_3
EXECUTABLES = app cli

app_DEPS = main.o top_a.o top_b.o $(LIBRARIES_$(d)/Dir_1) 
app_LDFLAGS = -lpthread

cli_DEPS = cli.o cli_dep.o

