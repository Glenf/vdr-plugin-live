#
# Makefile for a Video Disk Recorder plugin
#
# $Id: Makefile,v 1.4 2007/01/02 20:23:45 lordjaxom Exp $

# The official name of this plugin.
# This name will be used in the '-P...' option of VDR to load the plugin.
# By default the main source file also carries this name.
# IPORTANT: the presence of this macro is important for the Make.config
# file. So it must be defined, even if it is not used here!
#
PLUGIN = live

### The version number of this plugin (taken from the main source file):

VERSION = $(shell grep 'static const char \*VERSION *=' $(PLUGIN).cpp | awk '{ print $$6 }' | sed -e 's/[";]//g')

### The C++ compiler and options:

CXX      ?= g++
CXXFLAGS ?= -fPIC -g -O2 -Wall -Woverloaded-virtual

ECPPC    ?= ecppc
CXXFLAGS += `tntnet-config --cxxflags`

LDFLAGS  += `tntnet-config --libs`

### The directory environment:

VDRDIR = ../../..
LIBDIR = ../../lib
TMPDIR = /tmp

### Allow user defined options to overwrite defaults:

-include $(VDRDIR)/Make.config

### The version number of VDR's plugin API (taken from VDR's "config.h"):

APIVERSION = $(shell sed -ne '/define APIVERSION/s/^.*"\(.*\)".*$$/\1/p' $(VDRDIR)/config.h)

### The name of the distribution archive:

ARCHIVE = $(PLUGIN)-$(VERSION)
PACKAGE = vdr-$(ARCHIVE)

### Includes and Defines (add further entries here):

INCLUDES += -I$(VDRDIR)/include -Ihttpd

DEFINES  += -D_GNU_SOURCE -DPLUGIN_NAME_I18N='"$(PLUGIN)"'

SUBDIRS   = httpd

LIBS     += httpd/libhttpd.a

### The object files (add further files here):

OBJS = $(PLUGIN).o thread.o tntconfig.o setup.o

WEBS = channels.o schedule.o

### Default rules:

.PHONY: all dist clean SUBDIRS

all: libvdr-$(PLUGIN).so libtnt-$(PLUGIN).so

### Implicit rules:

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $(DEFINES) $(INCLUDES) $<

%.cpp: %.ecpp
	$(ECPPC) $(ECPPFLAGS) $(ECPPFLAGS_CPP) $<

%.cpp: %.gif
	$(ECPPC) $(ECPPFLAGS) $(ECPPFLAGS_GIF) -b $<

%.cpp: %.jpg
	$(ECPPC) $(ECPPFLAGS) $(ECPPFLAGS_JPG) -b $<

%.cpp: %.css
	$(ECPPC) $(ECPPFLAGS) $(ECPPFLAGS_CSS) -b $<

%.cpp: %.js
	$(ECPPC) $(ECPPFLAGS) $(ECPPFLAGS_JS) -b $<

# Dependencies:

MAKEDEP = $(CXX) -MM -MG
DEPFILE = .dependencies
$(DEPFILE): Makefile
	@$(MAKEDEP) $(DEFINES) $(INCLUDES) $(OBJS:%.o=%.cpp) > $@

-include $(DEPFILE)

### Targets:

SUBDIRS:
	@for dir in $(SUBDIRS); do \
		make -C $$dir CXX="$(CXX)" CXXFLAGS="$(CXXFLAGS)" lib$$dir.a ; \
	done

libvdr-$(PLUGIN).so: $(OBJS) SUBDIRS
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -shared $(OBJS) $(LIBS) -o $@ 
	@cp --remove-destination $@ $(LIBDIR)/$@.$(APIVERSION)

libtnt-$(PLUGIN).so: $(WEBS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -shared -o $@ $^
	@cp --remove-destination $@ $(LIBDIR)/$@

dist: clean $(WEBS:%.o=%.cpp)
	@-rm -rf $(TMPDIR)/$(ARCHIVE)
	@mkdir $(TMPDIR)/$(ARCHIVE)
	@cp -a * $(TMPDIR)/$(ARCHIVE)
	@tar czf $(PACKAGE).tgz -C $(TMPDIR) $(ARCHIVE)
	@-rm -rf $(TMPDIR)/$(ARCHIVE)
	@echo Distribution package created as $(PACKAGE).tgz

clean:
	@-rm -f $(OBJS) $(WEBS) $(DEPFILE) *.so *.tgz core* *~
	@for dir in $(SUBDIRS); do \
		make -C $$dir clean ; \
	done

                                        