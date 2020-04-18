#!/usr/bin/env bash

IMAGE="starefossen/github-pages"

MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

docker run -it --rm \
--name github-pages \
-v ${MYDIR}:/usr/src/app -p "4000:4000" \
${IMAGE} $@

