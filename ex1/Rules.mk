SUBDIRS = Dir_1 
#Dir_2 Dir_3
EXECUTABLES = app
#cli.exe

app_DEPS = top_a.o top_b.o main.o 
#../Dir_1/lib/libdir1.a
app_LDFLAGS = -lpthread

#app.exe_DEPS = top_a.o top_b.o main.o $(SUBDIRS_TGTS)
#app.exe_LIBS = -lm

#cli.exe_DEPS = cli.o cli_dep.o

