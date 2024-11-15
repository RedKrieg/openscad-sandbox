#!/usr/bin/env bash
OPENSCAD="openscad --enable fast-csg-safer --enable manifold --enable roof --enable lazy-union --enable vertex-object-renderers-indexing --enable textmetrics --enable import-function --enable predictible-output"
$OPENSCAD -D render_target=\"all\" -o all.3mf tree.scad
for target in base star; do
    $OPENSCAD -D render_target=\"${target}\" -o ${target}.3mf tree.scad
done
for ring in {0..6}; do
    $OPENSCAD -D render_target=\"ring\" -D ring_number="${ring}" -o ring_${ring}.3mf tree.scad
done
