#!/usr/bin/env python3
"""Compile the patch's actual polling state machine against fake DRM/Xorg APIs.
Run with CC=/usr/gcc/14/bin/gcc on illumos; no display or privileges required.
"""
from pathlib import Path
import os, subprocess, tempfile
patch = (Path(__file__).resolve().parents[1] / 'patches/42-illumos-hotplug-poll.patch').read_text()
start = patch.index('+#ifdef __sun\n')
end = patch.index('+#endif\n', start) + len('+#endif\n')
code = '\n'.join(line[1:] for line in patch[start:end].splitlines() if line.startswith('+'))
pre = r'''
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>
#define __sun 1
#define TRUE 1
#define FALSE 0
#define X_INFO 0
#define OPTION_HOTPLUG_POLL 1
#define DRM_MODE_CONNECTOR_LVDS 7
#define DRM_MODE_CONNECTOR_eDP 14
#define DRM_MODE_CONNECTOR_DSI 16
typedef int Bool;
typedef uint32_t CARD32;
typedef void *OsTimerPtr;
struct scrn { int vtSema, scrnIndex; };
struct drmmode_poll;
typedef struct { struct scrn *scrn; void *sysevent, *Options; int fd; struct drmmode_poll *hotplug_poll; } drmmode_rec, *drmmode_ptr;
typedef struct { uint32_t clock,hdisplay,vdisplay,htotal,vtotal,flags; } mode;
typedef struct { int count_connectors; uint32_t *connectors; } resources, *drmModeResPtr;
typedef struct { int connector_type, connection, count_modes, count_props; mode *modes; uint32_t *props; uint64_t *prop_values; } connector, *drmModeConnectorPtr;
static uint32_t ids[130];
static int nids=8, failure, status, calls, forced, reprobes, enabled=1;
static drmModeResPtr drmModeGetResources(int fd) { resources *r=calloc(1,sizeof(*r)); r->count_connectors=nids; r->connectors=ids; return r; }
static void drmModeFreeResources(drmModeResPtr r) { free(r); }
static drmModeConnectorPtr get_connector(uint32_t id) { connector *c; calls++; if (failure) return NULL; c=calloc(1,sizeof(*c)); c->connector_type=id==1 ? DRM_MODE_CONNECTOR_LVDS:10; c->connection=status; return c; }
static drmModeConnectorPtr drmModeGetConnectorCurrent(int fd,uint32_t id) { return get_connector(id); }
static drmModeConnectorPtr drmModeGetConnector(int fd,uint32_t id) { forced++; return get_connector(id); }
static void drmModeFreeConnector(drmModeConnectorPtr c) { free(c); }
static void drmmode_update_kms_state(drmmode_ptr d) { reprobes++; }
static int xf86ReturnOptValBool(void *o,int key,int def) { return enabled; }
static OsTimerPtr TimerSet(OsTimerPtr t,int flags,CARD32 ms,CARD32 (*fn)(OsTimerPtr,CARD32,void*),void *data) { return t ? t:malloc(1); }
static void TimerFree(OsTimerPtr t) { free(t); }
#define xf86DrvMsg(...) ((void)0)
'''
post = r'''
static CARD32 tick(struct drmmode_poll *p) { CARD32 r; calls=forced=0; r=drmmode_poll_tick(p->timer,0,p); assert(calls<=8); return r; }
static CARD32 cycle(struct drmmode_poll *p) { CARD32 r; unsigned batches=0; do { r=tick(p); assert(++batches<=32); } while(r==250); return r; }
int main(void) {
 struct scrn scrn={1,0}; drmmode_rec d={0}; struct drmmode_poll *p; int old;
 for(unsigned i=0;i<130;i++) ids[i]=i+1;
 d.scrn=&scrn; d.sysevent=&scrn;
 enabled=0; drmmode_poll_init(&d); assert(!d.hotplug_poll);
 enabled=1; drmmode_poll_init(&d); assert(d.hotplug_poll); p=d.hotplug_poll;
 assert(tick(p)==250 && forced==3); assert(tick(p)==5000 && forced==4 && reprobes==1);
 assert(cycle(p)==5000 && reprobes==1); /* unchanged topology */
 status=1; assert(cycle(p)==5000 && reprobes==2);
 nids=9; assert(cycle(p)==5000 && reprobes==3); /* MST addition */
 nids=8; assert(cycle(p)==5000 && reprobes==4); /* removal */
 failure=1; assert(tick(p)==10000); assert(tick(p)==20000); assert(tick(p)==30000); assert(tick(p)==30000);
 failure=0; assert(cycle(p)==5000 && reprobes==4);
 scrn.vtSema=0; old=reprobes; assert(tick(p)==5000 && calls==0 && reprobes==old);
 scrn.vtSema=1; assert(cycle(p)==5000 && reprobes==old+1);
 d.sysevent=NULL; assert(cycle(p)==3000); /* unavailable subscription */
 nids=1; assert(cycle(p)==30000 && forced==0); /* fixed panel */
 nids=0; assert(cycle(p)==3000); /* keep discovery alive */
 nids=129; assert(tick(p)==6000 && calls==0); /* resource bound */
 nids=128; assert(cycle(p)==3000); /* maximum bounded snapshot */
 drmmode_poll_fini(&d); assert(!d.hotplug_poll);
 puts("PASS: filtering, change detection, MST IDs, backoff, VT, limits, disable, teardown");
 return 0;
}
'''
with tempfile.TemporaryDirectory(prefix='hotplug-poll-') as td:
    src=Path(td)/'test.c'; exe=Path(td)/'test'; src.write_text(pre+code+post)
    subprocess.run([os.environ.get('CC','cc'),'-std=c99','-Wall','-Wextra','-Wno-unused-parameter','-o',str(exe),str(src)],check=True)
    subprocess.run([str(exe)],check=True)
