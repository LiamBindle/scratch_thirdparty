# $Id: makefile,v 1.1.5.1 2013-01-11 20:23:44 mathomp4 Exp $

ALL: build_examples
run: run_examples
run_uni: run_examples_uni

LOCDIR	  = src/Infrastructure/DELayout/examples


EXAMPLES_BUILD    = $(ESMF_EXDIR)/ESMF_DELayoutEx

EXAMPLES_RUN      = run_ESMF_DELayoutEx

EXAMPLES_RUN_UNI  = run_ESMF_DELayoutEx_uni


include $(ESMF_DIR)/makefile

DIRS	  = 

CLEANDIRS   = 
CLEANFILES  = $(EXAMPLES_BUILD)
CLOBBERDIRS =

#
#  Run targets
#
run_ESMF_DELayoutEx:
	$(MAKE) EXNAME=DELayout NP=4 exfrun

run_ESMF_DELayoutEx_uni:
	$(MAKE) EXNAME=DELayout NP=1 exfrun
