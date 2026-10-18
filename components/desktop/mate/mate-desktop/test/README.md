# Cached RandR update regression

This native test sends three real RandR notifications 150ms apart by changing
only the physical dimensions of a **private Xvfb** screen. It counts the
MateRRScreen changed callbacks, which use cached X server state rather than
forcing hardware detection. It does not test a physical cable or desktop policy.

Build with the native compiler and pkg-config flags for gtk+-3.0,
mate-desktop-2.0, xrandr and x11. Run with DISPLAY pointing to a task-owned Xvfb
with RandR enabled. Never point it at a user's desktop. Stop only that Xvfb
when finished.

Run once against the previous OI library, then with LD_LIBRARY_PATH_64 pointing
to the corrected prototype usr/lib/amd64. The old two-second throttle delivers
zero of three notifications (exit1); the corrected library delivers all three
(exit0). An initial failed XSendEvent-based harness is not this test: extension
event dispatch must be exercised with real server notifications.
