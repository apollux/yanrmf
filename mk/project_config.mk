BUILD_DIRECTORY := $(TOP)/build

OBJDIR := obj
LIBDIR := lib
EXEDIR := out
SRCS_VPATH := src
TESTDIR := test

CPPFLAGS +=
SYSTEM_INCLUDES_LOCATIONS += $(HOME)/workspace/boost_build/include
LDFLAGS += -L/home/andre/workspace/boost_build/lib

CC := gcc
CXX := g++
AR := ar
