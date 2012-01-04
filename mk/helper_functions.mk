# "Pretty printing" stuff
#
# The value of the variable VERBOSE decides whether to output only
# a short note what is being done (e.g. "CC foobar.c") or a full
# command line.
# By default I check terminal capabilities and use colors only when the 
# terminal support them but you can suppress coloring by setting COLOR_TTY 
# to something else than 'true' (see config.mk).

# Please don't argue about this choice of colors - I'm always using black
# background so yellow on black it is :-D - background is specified
# below just for those using bright background :-P

COLOR_WHITE := \033[1;37m
COLOR_LIGHTGRAY := 033[0;37m
COLOR_GRAY := \033[1;30m
COLOR_BLACK := \033[0;30m
COLOR_RED := \033[0;31m
COLOR_LIGHTRED := \033[1;31m
COLOR_GREEN := \033[0;32m
COLOR_LIGHTGREEN := \033[1;32m
COLOR_BROWN := \033[0;33m
COLOR_YELLOW := \033[1;33m
COLOR_BLUE := \033[0;34m
COLOR_LIGHTBLUE := \033[1;34m
COLOR_PURPLE := \033[0;35m
COLOR_PINK := \033[1;35m
COLOR_CYAN := \033[0;36m
COLOR_LIGHTCYAN := \033[1;36m
COLOR_DEFAULT := \033[0m

FOREGROUND_COLOR := $(COLOR_BROWN)

ifndef COLOR_TTY
COLOR_TTY := $(shell [ `tput colors` -gt 2 ] && echo true)
endif

ifneq ($(VERBOSE),true)
ifeq ($(COLOR_TTY),true)
echo_prog := $(shell if echo -e | grep -q -- -e; then echo echo; else echo echo -e; fi)
echo_cmd = @$(echo_prog) "$(2)$(1)$(COLOR_DEFAULT)";
else
echo_cmd = @echo "$(1)";
endif
else # Verbose output
echo_cmd =
endif

# Argument 1 root path to which the relative path should relate. No trailing '/'.
# Argument 2 path to somewhere under root for which the relative path should be
# returned. No trailing '/'.
# If both path are equal return empty string otherwise return relative path
define relative_path
$(if $(filter $(1),$(2)),,$(patsubst $(1)/%,%,$(2)))
endef
