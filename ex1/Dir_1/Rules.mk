SHARED_LIBRARY := libdir1_lib.so
SUBDIRS := Dir_1a Dir_1b

libdir1_lib.so_DEPS = dir_1_file1.o dir_1_file2.o dir_1_file3.o #$(SUBDIRS_TGTS)
