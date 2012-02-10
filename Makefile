SHELL := /bin/bash
RUNDIR := $(shell pwd)
ifndef TOP
TOP := $(shell rd=$(RUNDIR); top=$$rd; \
               until [ -r $$top/Rules.top ]; do \
                 oldtop=$$top; \
                 cd ..; top=`pwd`; \
                 if [ $$oldtop = $$top ]; then \
                   top=$$rd; break; \
                 fi; \
               done; \
               echo $$top)
endif

MK := $(TOP)/mk

.PHONY: all clean clean_all runtest
.DEFAULT_GOAL := dir_$(RUNDIR)

clean: 
	rm -rf $(BUILD_DIRECTORY)

#clean: clean_$(RUNDIR)

include $(MK)/header.mk
include $(TOP)/Rules.top
include $(MK)/footer.mk


# Whole tree targets
all: $(TARGETS_$(TOP))

# This is just a convenience - to let you know when make has stopped
# interpreting make files and started their execution.
$(info Rules generated...)
$(info Build variant: $(VARIANT))

runtest: $(EXECUTABLES_$(TOP)/testrunner)
	$(EXECUTABLES_$(TOP)/testrunner)
