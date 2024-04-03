#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source.  A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#

#
# Copyright 2024 Till Wegmueller
#

BUILD_BITS= NO_ARCH
BUILD_STYLE= modulebuild
include ../../../make-rules/shared-macros.mk

COMPONENT_NAME= po4a
COMPONENT_VERSION= 0.71
COMPONENT_SUMMARY= Tools for helping translation of documentation
COMPONENT_PROJECT_URL= https://po4a.org/
COMPONENT_FMRI= developer/$(COMPONENT_NAME)
COMPONENT_CLASSIFICATION= 
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_URL= https://github.com/mquinson/po4a/files/14453212/$(COMPONENT_ARCHIVE)
COMPONENT_ARCHIVE_HASH= sha256:c572401e49cc11757c6d3060916fdfb5a833251ed1d4aeb989b66704bcf283f9
COMPONENT_LICENSE= GPL

PATH= $(PATH.gnu)

TEST_TARGET=$(NO_TESTS) # if no testsuite enabled
include $(WS_MAKE_RULES)/common.mk

# Build dependencies
REQUIRED_PACKAGES+=library/perl-5/pod-parser
REQUIRED_PACKAGES+=developer/documentation-tool/opensp
REQUIRED_PACKAGES+=data/docbook
REQUIRED_PACKAGES+=library/perl-5/yaml-tiny
# Auto-generated dependencies
# TODO: depend type=require fmri=__TBD pkg.debug.depend.file=SGMLS.pm pkg.debug.depend.path=usr/perl5/5.34/lib pkg.debug.depend.path=usr/perl5/5.34/lib/i86pc-solaris-thread-multi-64 pkg.debug.depend.path=usr/perl5/vendor_perl/5.34 pkg.debug.depend.path=usr/perl5/vendor_perl/5.34/i86pc-solaris-thread-multi-64
# TODO: depend type=require fmri=__TBD pkg.debug.depend.file=SGMLS.pm pkg.debug.depend.path=usr/perl5/5.36/lib pkg.debug.depend.path=usr/perl5/5.36/lib/i86pc-solaris-thread-multi-64 pkg.debug.depend.path=usr/perl5/vendor_perl/5.36 pkg.debug.depend.path=usr/perl5/vendor_perl/5.36/i86pc-solaris-thread-multi-64
# TODO: depend type=require fmri=__TBD pkg.debug.depend.file=SGMLS.pm pkg.debug.depend.path=usr/perl5/5.38/lib pkg.debug.depend.path=usr/perl5/5.38/lib/i86pc-solaris-thread-multi-64 pkg.debug.depend.path=usr/perl5/vendor_perl/5.38 pkg.debug.depend.path=usr/perl5/vendor_perl/5.38/i86pc-solaris-thread-multi-64
# TODO: depend type=require fmri=__TBD pkg.debug.depend.file=Unicode/GCString.pm pkg.debug.depend.path=usr/perl5/5.34/lib pkg.debug.depend.path=usr/perl5/5.34/lib/i86pc-solaris-thread-multi-64 pkg.debug.depend.path=usr/perl5/vendor_perl/5.34 pkg.debug.depend.path=usr/perl5/vendor_perl/5.34/i86pc-solaris-thread-multi-64
# TODO: depend type=require fmri=__TBD pkg.debug.depend.file=Unicode/GCString.pm pkg.debug.depend.path=usr/perl5/5.36/lib pkg.debug.depend.path=usr/perl5/5.36/lib/i86pc-solaris-thread-multi-64 pkg.debug.depend.path=usr/perl5/vendor_perl/5.36 pkg.debug.depend.path=usr/perl5/vendor_perl/5.36/i86pc-solaris-thread-multi-64
# TODO: depend type=require fmri=__TBD pkg.debug.depend.file=Unicode/GCString.pm pkg.debug.depend.path=usr/perl5/5.38/lib pkg.debug.depend.path=usr/perl5/5.38/lib/i86pc-solaris-thread-multi-64 pkg.debug.depend.path=usr/perl5/vendor_perl/5.38 pkg.debug.depend.path=usr/perl5/vendor_perl/5.38/i86pc-solaris-thread-multi-64
PERL_REQUIRED_PACKAGES += library/perl-5/module-build
