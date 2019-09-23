#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"). You may
# only use this file in accordance with the terms of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#
#
# Copyright (c) 2019, Till Wegmueller <toasterson@gmail.com>

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		zabbix
COMPONENT_VERSION=	4.2.2
COMPONENT_SRC=		zabbix-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=	zabbix-$(COMPONENT_VERSION).tar.gz
COMPONENT_SUMMARY=	Zabbix the Enterprise class monitoring system
COMPONENT_FMRI=		application/management/zabbix
COMPONENT_ARCHIVE_HASH= sha256:cfad388de0373b35240cf2acaba48633a6b12a67472278f18a0093284f1573e2
COMPONENT_PROJECT_URL=	http://www.zabbix.com/
COMPONENT_ARCHIVE_URL=	http://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/$(COMPONENT_VERSION)/$(COMPONENT_ARCHIVE)/download
COMPONENT_CLASSIFICATION=org.opensolaris.category.2008:Applications/System Utilities
COMPONENT_LICENSE_FILE= zabbix.license
COMPONENT_LICENSE=	GPLv2

include $(WS_MAKE_RULES)/prep.mk
include $(WS_MAKE_RULES)/configure.mk
include $(WS_MAKE_RULES)/ips.mk

CONFIGURE_DEFAULT_DIRS=no

COMPONENT_PRE_CONFIGURE_ACTION = \
	($(CLONEY) $(SOURCE_DIR) $(@D))

# Ugly hack for fixing problems with missing files in source directory
CONFIGURE_SCRIPT= 	$(@D)/configure

VARIANT_POSTGRESQL =	$(BUILD_DIR)/postgresql
VARIANT_SQLITE =	$(BUILD_DIR)/sqlite
VARIANT_MYSQL =		$(BUILD_DIR)/mysql
VARIANT_AGENT =		$(BUILD_DIR)/agent

VARIANTS = $(VARIANT_POSTGRESQL) $(VARIANT_SQLITE) $(VARIANT_MYSQL) $(VARIANT_AGENT)

BUILD_64 = $(VARIANTS:%=%/$(MACH64)/.built)

INSTALL_64 = $(VARIANTS:%=%/$(MACH64)/.installed)

$(VARIANT_POSTGRESQL)/$(MACH64)/.configured: BITS=64
$(VARIANT_SQLITE)/$(MACH64)/.configured: BITS=64
$(VARIANT_MYSQL)/$(MACH64)/.configured: BITS=64
$(VARIANT_AGENT)/$(MACH64)/.configured: BITS=64

$(VARIANT_POSTGRESQL)/%/.configured: CONFIGURE_OPTIONS += --with-postgresql --enable-server --enable-proxy --bindir=/usr/zabbix/psql/bin --sbindir=/usr/zabbix/psql/sbin
$(VARIANT_SQLITE)/%/.configured: CONFIGURE_OPTIONS += --with-sqlite3 --enable-proxy --bindir=/usr/zabbix/sqlite/bin --sbindir=/usr/zabbix/sqlite/sbin
$(VARIANT_MYSQL)/%/.configured: CONFIGURE_OPTIONS += --with-mysql=/usr/mysql/bin/mysql_config --enable-server --enable-proxy --bindir=/usr/zabbix/mysql/bin --sbindir=/usr/zabbix/mysql/sbin
$(VARIANT_AGENT)/%/.configured: CONFIGURE_OPTIONS += --enable-agent

PATH=$(MYSQL_HOME)/bin:$(PG_HOME)/bin:/usr/gnu/bin:/usr/bin

# Cmake makefiles somehow loose -R/path/to/lib
LDFLAGS.32 += -L$(MYSQL_HOME)/lib -R$(MYSQL_HOME)/lib
LDFLAGS.32 += -L$(PG_HOME)/lib -R$(PG_HOME)/lib
LDFLAGS.64 += -L$(MYSQL_HOME)/lib/$(MACH64) -R$(MYSQL_HOME)/lib/$(MACH64)
LDFLAGS.64 += -L$(PG_HOME)/lib/$(MACH64) -R$(PG_HOME)/lib/$(MACH64)
LDFLAGS += $(LDFLAGS.$(BITS))

CONFIGURE_OPTIONS +=    --sysconfdir=/etc/zabbix
CONFIGURE_OPTIONS +=	--enable-ipv6
CONFIGURE_OPTIONS +=	--enable-java
CONFIGURE_OPTIONS +=	--with-net-snmp
CONFIGURE_OPTIONS +=	--with-ldap
CONFIGURE_OPTIONS +=	--with-openssl
CONFIGURE_OPTIONS +=	--with-libcurl
CONFIGURE_OPTIONS +=	--with-ssh2
CONFIGURE_OPTIONS +=	--with-libxml2
# We are aparently currently missing openipmi or ipmiif.h which zabbix openipmi support requires
#CONFIGURE_OPTIONS +=	--with-openipmi
CONFIGURE_OPTIONS +=	--with-libpcre-include=/usr/include/pcre

COMPONENT_POST_INSTALL_ACTION = \
				(cd $(@D) ; \
				mkdir -p $(PROTO_DIR)/usr/share/zabbix/database ; \
			       	$(CP) -r database/ $(PROTO_DIR)/usr/share/zabbix/database ; \
			       	mkdir -p $(PROTO_DIR)/usr/share/zabbix/frontend ; \
			       	$(CP) -r frontends/php/* $(PROTO_DIR)/usr/share/zabbix/frontend; ) #\
			        #test -d $(PROTO_DIR)/usr/zabbix/sqlite && $(MV) $(PROTO_DIR)/usr/zabbix/sqlite/sbin/* $(PROTO_RIT)/usr/sbin/ )

build:          $(BUILD_64)

install:        $(INSTALL_64)

test:           $(TESTS_64)

REQUIRED_PACKAGES += SUNWcs
REQUIRED_PACKAGES += system/library
REQUIRED_PACKAGES += database/mariadb-103
REQUIRED_PACKAGES += database/mariadb-103/library
REQUIRED_PACKAGES += database/postgres-11/developer
REQUIRED_PACKAGES += database/sqlite-3
REQUIRED_PACKAGES += library/libevent
REQUIRED_PACKAGES += library/pcre
REQUIRED_PACKAGES += library/openldap
REQUIRED_PACKAGES += system/management/snmp/net-snmp
REQUIRED_PACKAGES += library/security/openssl
REQUIRED_PACKAGES += web/curl
REQUIRED_PACKAGES += network/ssh
REQUIRED_PACKAGES += system/management/ipmitool
