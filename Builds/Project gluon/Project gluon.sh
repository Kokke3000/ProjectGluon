#!/bin/sh
printf '\033c\033]0;%s\a' Project gluon
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Project gluon" "$@"
