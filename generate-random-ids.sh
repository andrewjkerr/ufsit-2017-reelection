#!/bin/bash
for i in {1..40}
do
    cat /dev/urandom | env LC_CTYPE=C LC_ALL=C tr -dc a-zA-Z0-9 | head -c 32; echo
done