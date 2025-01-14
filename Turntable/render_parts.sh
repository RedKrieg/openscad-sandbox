#!/usr/bin/env bash
OPENSCAD="openscad --enable fast-csg-safer --enable manifold --enable roof --enable lazy-union --enable vertex-object-renderers-indexing --enable textmetrics --enable import-function --enable predictible-output"
[ -z $1 ] && exit 1
for target in $(egrep '^render_target ?=' $1 | cut -d[ -f2 | cut -d] -f1 | tr ',' ' '); do
    $OPENSCAD -D render_target=\"${target}\" -o ${target}.3mf $1
done
