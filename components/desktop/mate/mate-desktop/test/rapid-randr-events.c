/* Cached RandR event delivery regression; run only on a private Xvfb. */
#include <gtk/gtk.h>
#include <gdk/gdkx.h>
#include <X11/extensions/Xrandr.h>
#include <string.h>
#define MATE_DESKTOP_USE_UNSTABLE_API
#include <libmate-desktop/mate-rr.h>

static unsigned sent, received;
static GMainLoop *loop;

static void changed (MateRRScreen *screen, gpointer data)
{
    received++;
}

static gboolean finish (gpointer data)
{
    g_main_loop_quit (loop);
    return G_SOURCE_REMOVE;
}

static gboolean send_event (gpointer data)
{
    Display *dpy = gdk_x11_get_default_xdisplay ();
    int base, error;
    XRRScreenChangeNotifyEvent ev;
    memset (&ev, 0, sizeof ev);
    XRRQueryExtension (dpy, &base, &error);
    ev.type = base + RRScreenChangeNotify;
    ev.display = dpy;
    ev.window = ev.root = DefaultRootWindow (dpy);
    ev.rotation = RR_Rotate_0;
    ev.width = DisplayWidth (dpy, DefaultScreen (dpy));
    ev.height = DisplayHeight (dpy, DefaultScreen (dpy));
    ev.mwidth = DisplayWidthMM (dpy, DefaultScreen (dpy));
    ev.mheight = DisplayHeightMM (dpy, DefaultScreen (dpy));
    /* Real RandR notifications from a private virtual server. Changing only
     * millimetres avoids requiring extra scanout modes in Xvfb. */
    XRRSetScreenSize (dpy, ev.root, ev.width, ev.height,
                     ev.mwidth + sent + 1, ev.mheight);
    XFlush (dpy);
    if (++sent == 3) {
        g_timeout_add (200, finish, NULL);
        return G_SOURCE_REMOVE;
    }
    return G_SOURCE_CONTINUE;
}

int main (int argc, char **argv)
{
    GError *error = NULL;
    MateRRScreen *screen;
    gtk_init (&argc, &argv);
    /* XSendEvent uses the core event selection, independently of RandR's
     * extension mask selected by MateRRScreen. */
    XSelectInput (gdk_x11_get_default_xdisplay (),
                  gdk_x11_get_default_root_xwindow (), StructureNotifyMask);
    screen = mate_rr_screen_new (gdk_screen_get_default (), &error);
    if (!screen) {
        g_printerr ("screen initialization: %s\n", error->message);
        return 2;
    }
    g_signal_connect (screen, "changed", G_CALLBACK (changed), NULL);
    loop = g_main_loop_new (NULL, FALSE);
    g_timeout_add (150, send_event, NULL);
    g_main_loop_run (loop);
    g_print ("synthetic cached RandR notifications sent=%u delivered=%u\n",
             sent, received);
    g_main_loop_unref (loop);
    g_object_unref (screen);
    return received == sent ? 0 : 1;
}
