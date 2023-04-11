export JENKINS_BUILD_NUMBER=$BUILD_NUMBER
unset BUILD_NUMBER
                                                                                                                                                                                                                   
copy_logs() {
# Copy logs
mkdir -p /data/logs/oi-userland/${JENKINS_BUILD_NUMBER}
rsync -av i386/logs/ /data/logs/oi-userland/${JENKINS_BUILD_NUMBER}/
/usr/gnu/bin/ln -snf /data/logs/oi-userland/${JENKINS_BUILD_NUMBER} /data/logs/oi-userland/latest
}
                                                                                                                                                                                                                   
trap copy_logs EXIT
                                                                                                                                                                                                                   
[ -f components/components.mk ] &amp;&amp; rm components/components.mk
[ -f components/depends.mk ] &amp;&amp; rm components/depends.mk
                                                                                                                                                                                                                   
# This following is temporarily needed after python/cryptography has been updated:
export CRYPTOGRAPHY_ALLOW_OPENSSL_102=true
                                                                                                                                                                                                                   
export PUBLISHER=openindiana.org
export USERLAND_ARCHIVES=/data/userland-archives/
export COMPONENT_BUILD_ARGS=-j8
                                                                                                                                                                                                                   
# Turn on incremental mode
export BASS_O_MATIC_MODE=incremental
                                                                                                                                                                                                                   
# Workaround for GOCACHE not defined in Jenkins jobs
export GOCACHE=/tmp/.cache/go-build
                                                                                                                                                                                                                   
# Tentative workaround
export GNUMAKEFLAGS=--no-print-directory
                                                                                                                                                                                                                   
/usr/bin/time gmake setup
/usr/bin/time gmake publish -j8 -k
/usr/bin/time gmake -C components incorporation
                                                                                                                                                                                                                   
/usr/bin/time rsync -av i386/repo/publisher/openindiana.org/file/ \
  rsync://pkg.openindiana.org:974/hipster-file/
                                                                                                                                                                                                                   
/usr/bin/time rsync -av i386/repo/publisher/openindiana.org/pkg/ \
  rsync://pkg.openindiana.org:974/hipster-pkg/
                                                                                                                                                                                                                   
echo &quot;Poor man&apos;s RPC...&quot;
mkdir /tmp/empty.$$
/usr/bin/time rsync /tmp/empty.$$/ \
  rsync://pkg.openindiana.org:974/hipster-update/
rmdir /tmp/empty.$$
                                                                                                                                                                                                                   
[ -f components/encumbered/components.mk ] &amp;&amp; rm components/encumbered/components.mk
[ -f components/encumbered/depends.mk ] &amp;&amp; rm components/encumbered/depends.mk
                                                                                                                                                                                                                   
export PUBLISHER=hipster-encumbered
                                                                                                                                                                                                                   
/usr/bin/time gmake -C components/encumbered setup
#/usr/bin/time gmake -C components/encumbered publish -j8 -k
                                                                                                                                                                                                                   
                                                                                                                                                                                                                   
/usr/bin/time rsync -av i386/encumbered-repo/publisher/hipster-encumbered/file/ \
  rsync://pkg.openindiana.org:974/hipster-encumbered-file/
                                                                                                                                                                                                                   
/usr/bin/time rsync -av i386/encumbered-repo/publisher/hipster-encumbered/pkg/ \
  rsync://pkg.openindiana.org:974/hipster-encumbered-pkg/
                                                                                                                                                                                                                   
                                                                                                                                                                                                                   
echo &quot;Poor man&apos;s RPC...&quot;
mkdir /tmp/empty.$$
/usr/bin/time rsync /tmp/empty.$$/ \
  rsync://pkg.openindiana.org:974/hipster-encumbered-update/
rmdir /tmp/empty.$$
                                                                                                                                                                                                                   
                                                                                                                                                                                                                   
# Wait for the package server to become accessible
for i in `seq 1 300`; do curl -If http://pkg.openindiana.org/hipster/openindiana.org/catalog/1/catalog.attrs &gt;/dev/null 2&gt;&amp;1 &amp;&amp; break; sleep 1; done
                                                                                                                                                                                                                   
                                                                                                                                                                                                                   
# Wait for the encumbered package server to become accessible
for i in `seq 1 300`; do curl -If http://pkg.openindiana.org/hipster-encumbered/hipster-encumbered/catalog/1/catalog.attrs &gt;/dev/null 2&gt;&amp;1 &amp;&amp; break; sleep 1; done
                                                                                                                                                                                                                   
#pfexec beadm create oi-$(date +%Y-%m-%d-%H:%M:%S)
                                                                                                                                                                                                                   
                                                                                                                                                                                                                   
pfexec pkg refresh --full
pfexec pkg install -v pkg:/package/pkg &gt; /tmp/pkg-update.out.$$ || \
  grep &quot;No updates necessary for this image.&quot; /tmp/pkg-update.out.$$ &gt;/dev/null
                                                                                                                                                                                                                   
(pfexec pkg update -v --deny-new-be &gt; /tmp/pkg-update.out.$$ || grep &quot;No updates available for this image.&quot; /tmp/pkg-update.out.$$ &gt;/dev/null) || \
((pfexec pkg update -v &gt; /tmp/pkg-update.out.$$ || grep &quot;No updates available for this image.&quot; /tmp/pkg-update.out.$$ &gt; /dev/null) &amp;&amp; \
pfexec shutdown -i6 -g30 -y)
                                                                                                                                                                                                                   
cat /tmp/pkg-update.out.$$
rm /tmp/pkg-update.out.$$
                                                                                                                                                                                                                   
/usr/bin/time rsync --password-file=/home/oi/.rsync.secrets -a --delete --delete-delay /data/userland-archives/ rsync://jenkins@dlc.openindiana.org/dlc-src-tarballs || true
