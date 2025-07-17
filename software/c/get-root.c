#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

static char * const default_shell[] = {
    "/bin/zsh",
    NULL
};

int main(int argc, char **argv) {
    if (0 != setuid(0)) {
        fprintf(stderr, "Failed to switch to UID 0: %d %s\n", errno, strerror(errno));
        return 1;
    }

    if (-1 == execv(default_shell[0], default_shell)) {
        fprintf(stderr, "Failed to start shell: %d %s\n", errno, strerror(errno));
        return 1;
    }

    // Cannot happen
    return 0;
}
