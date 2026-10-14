# illumos connector hotplug pilot

Patch 41 subscribes modesetting to EC_drm / ESC_drm_hotplug, version 1.
It requires the matching carried DRM KMS producer. The callback only wakes a
nonblocking pipe; Xorg's main thread reconciles KMS/RandR. Device matching uses
the driver major and the facade's primary minor (low nine clone-minor bits).
The existing EnterVT path re-probes; an event received off-VT stays pending.
Screen teardown removes the callback's pipe entry before unbinding/freeing it.
The intel DDX is not changed; use modesetting for this pilot.

Patch 42 adds Option "HotplugPoll" (default true). Setting it to "false"
disables only polling. External outputs are queried every three seconds when
subscription is unavailable and five seconds when it is available; the latter
is a lost-event watchdog, including when the kernel predates the producer.
Query failures back off to at most 30 seconds. Polling pauses off-VT.

A snapshot has at most 128 connectors, processed four per timer callback
(at most eight connector queries: current type then forced external probe).
Additional batches are 250 ms apart. Fixed panels are never forcibly probed;
a panel-only device gets only a slow 30-second resource/type check. Empty
resources remain eligible for topology discovery. Connector IDs, connection,
mode timings and property values form the change signature; only a changed
snapshot (or the initial one) invokes the complete MST/RandR reconciliation.
The work budget cannot preempt a single slow kernel ioctl. Upstream Zaphod
restrictions remain; hardware MST and suspend support are not implied.

Build from a clean component tree after changing drmmode_display.h or driver.h.
This OI recipe disables compiler dependency tracking: an incremental make can
retain objects built for the old embedded drmmode_rec layout, producing a
module that links but crashes in unrelated DRI2/glamor startup. Rebuild all
modesetting translation units, or use the normal clean component build. Never
install directly into a shared build host; use the recipe's prototype DESTDIR.

Validation: native full Xorg build for patch 41; clean native module rebuild
for patch 42; disposable X230 BE, sysevent device filtering/burst coalescing,
Xorg restart during events, polling cadence/change behavior and disable option.
See the workspace task receipt for exact hashes and which runtime checks have
completed. A guest without an Intel GPU can check payloads/load and desktop
regression, but cannot validate physical HPD, DMC or MST.
