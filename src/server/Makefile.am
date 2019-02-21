SUBDIRS=services data connections python
INCLUDES = $(all_includes) -I$(top_srcdir)/ -I$(top_srcdir)/services/ -I$(top_srcdir)/services/mt/ -I$(top_srcdir)/services/preprocess/ -I$(top_srcdir)/data/ -I$(top_srcdir)/connections/
lib_LTLIBRARIES = libTS.la

bin_PROGRAMS=TranslationServer

include_HEADERS = PipelineManager.h Segment.h util.h
libTS_la_SOURCES = PipelineManager.cpp

TranslationServer_SOURCES=main.cpp
TranslationServer_LDADD= $(top_builddir)/libTS.la \
                         $(top_builddir)/services/libTSServices.la \
                         $(top_builddir)/services/mt/libTSMTServices.la \
                         $(top_builddir)/services/preprocess/libTSPreproServices.la \
                         $(top_builddir)/data/libTSData.la \
                         $(top_builddir)/connections/libTSConnections.la

