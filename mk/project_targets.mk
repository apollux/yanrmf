#.PHONY: runtests

runtests: $(EXECUTABLES_$(TOP)/apps/testrunner)
	@echo Running tests...
	@$(EXECUTABLES_$(TOP)/apps/testrunner) $(TOP)/TestReport.xml $(TOP)/apps/testrunner/testreport.xsl
	firefox $(TOP)/TestReport.xml &> /dev/null &