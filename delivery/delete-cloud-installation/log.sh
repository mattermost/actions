#!/bin/bash

set -u
set -e
set -o pipefail

BLUE=$(printf "\033[34m")
YELLOW=$(printf "\033[33m")
RED=$(printf "\033[31m")
GREEN=$(printf "\033[32m")
CNone=$(printf "\033[0m")

INFO () {
  echo $(date +%H:%M:%S) ${BLUE}[INFO]${CNone} $@ ; 
}
ERROR () {
  echo ::error title="Cloud Installation Creation Failed"::$@
}
OK () {
  echo $(date +%H:%M:%S) ${GREEN}[OK]${CNone} $@ ; 
}
WARN () {
  echo $(date +%H:%M:%S) ${YELLOW}[WARN]${CNone} $@ ;
}