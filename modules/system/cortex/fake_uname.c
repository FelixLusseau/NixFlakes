#include <string.h>
#include <sys/utsname.h>

#ifndef FAKE_NODENAME
#define FAKE_NODENAME "flnix"
#endif

int uname(struct utsname *buf) {
    strcpy(buf->sysname, "Linux");
    strcpy(buf->nodename, FAKE_NODENAME);
    strcpy(buf->release, "5.15.0-140-generic");
    strcpy(buf->version, "#150-Ubuntu SMP Sat Apr 12 06:00:09 UTC 2025");
    strcpy(buf->machine, "x86_64");
    return 0;
}
