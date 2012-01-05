SUBDIRS = Dir_1 
#TARGETS = app.exe cli.exe
#Dir_2 Dir_3

LIBRARIES = app.so
app.so_DEPS = top_a.o top_b.o main.o 

#app.exe_DEPS = top_a.o top_b.o main.o $(SUBDIRS_TGTS)
#app.exe_LIBS = -lm

#cli.exe_DEPS = cli.o cli_dep.o

