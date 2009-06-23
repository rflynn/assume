/*
 * C99, POSIX, and system-specific system headers shouldn't
 * be defined by an application. we could keep a database of
 * all system headers for different platforms, but we could
 * more easily and flexibly determine this by simply building
 * a list of existing system headers beforehand and comparing
 * project headers to them.
 */
#include "stdio.h"
