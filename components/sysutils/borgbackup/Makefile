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
# This file was automatically generated using the following command:
#   $WS_TOOLS/python-integrate-project -d sysutils/borgbackup borgbackup
#

BUILD_STYLE = pyproject
BUILD_BITS=64
include ../../../make-rules/shared-macros.mk

COMPONENT_NAME =		borgbackup
HUMAN_VERSION =			1.4.0
COMPONENT_SUMMARY =		borgbackup - Deduplicated, encrypted, authenticated and compressed backups
COMPONENT_PROJECT_URL =		https://borgbackup.readthedocs.io/
COMPONENT_ARCHIVE_URL =     https://github.com/borgbackup/borg/archive/refs/heads/master.zip
COMPONENT_ARCHIVE_HASH =    sha256:1a5d7ecf4d9862ccfaf94bbb7139cc227be1149763af4761cbee43a1793efe62
COMPONENT_LICENSE =		BSD-3-Clause
COMPONENT_LICENSE_FILE =	LICENSE

COMPONENT_FMRI =		backup/borg
COMPONENT_CLASSIFICATION =	Applications/System Utilities

# This is a standalone application.  Since no other Python project depends on
# it we just provide single unversioned package.
SINGLE_PYTHON_VERSION = yes

include $(WS_MAKE_RULES)/common.mk

# To fully utilize pytest-xdist
COMPONENT_TEST_ENV += XDISTN=auto

# Auto-generated dependencies
PYTHON_REQUIRED_PACKAGES += library/python/argon2-cffi
PYTHON_REQUIRED_PACKAGES += library/python/cython
PYTHON_REQUIRED_PACKAGES += library/python/msgpack
PYTHON_REQUIRED_PACKAGES += library/python/packaging
PYTHON_REQUIRED_PACKAGES += library/python/pkgconfig
PYTHON_REQUIRED_PACKAGES += library/python/platformdirs
PYTHON_REQUIRED_PACKAGES += library/python/setuptools
PYTHON_REQUIRED_PACKAGES += library/python/setuptools-scm
PYTHON_REQUIRED_PACKAGES += library/python/wheel
PYTHON_REQUIRED_PACKAGES += runtime/python
REQUIRED_PACKAGES += compress/zstd
REQUIRED_PACKAGES += library/libxxhash
REQUIRED_PACKAGES += library/lz4
REQUIRED_PACKAGES += library/security/openssl-31
REQUIRED_PACKAGES += system/library
