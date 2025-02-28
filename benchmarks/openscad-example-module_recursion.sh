#!/usr/bin/env bash

set -euo pipefail

writeScript() {
    # copied from https://files.openscad.org/examples/Advanced/module_recursion.html
    cat <<EOF >"$1"
echo(version=version());

// Recursive calls of modules can generate complex geometry, especially
// fractal style objects.
// The example uses a recursive module to generate a random tree as
// described in http://natureofcode.com/book/chapter-8-fractals/

levels = 10; // number of levels for the recursion

len = 100; // length of the first segment
thickness = 5; // thickness of the first segment

// the identity matrix
identity = [ [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ] ];

// random generator
function rnd(s, e) = rands(s, e, 1)[0];

// generate 4x4 translation matrix
function mt(x, y) = [ [ 1, 0, 0, x ], [ 0, 1, 0, y ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ] ];

// generate 4x4 rotation matrix around Z axis
function mr(a) = [ [ cos(a), -sin(a), 0, 0 ], [ sin(a), cos(a), 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ] ];

module tree(length, thickness, count, m = identity) {
    color([0, 1 - (0.8 / levels * count), 0])
        multmatrix(m)
            cube([thickness, length, thickness]);

    if (count > 0) {
        tree(rnd(0.6, 0.8) * length, 0.8 * thickness, count - 1, m * mt(0, length) * mr(rnd(20, 35)));
        tree(rnd(0.6, 0.8) * length, 0.8 * thickness, count - 1, m * mt(0, length) * mr(-rnd(20, 35)));
    }
}

tree(len, thickness, levels);



// Written in 2015 by Torsten Paul <Torsten.Paul@gmx.de>
//
// To the extent possible under law, the author(s) have dedicated all
// copyright and related and neighboring rights to this software to the
// public domain worldwide. This software is distributed without any
// warranty.
//
// You should have received a copy of the CC0 Public Domain
// Dedication along with this software.
// If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
EOF
}

requirements() {
    echo "openscad"
}

prepare() {
    local out="$1"
    mkdir -p "$out/workdir"
    local scad="$out/workdir/module_recursion.scad"
    [[ -f "$scad" ]] || writeScript "$scad"
}

run() {
    local out="$1"
    local scad="$out/workdir/module_recursion.scad"
    local stl="$out/workdir/module_recursion.stl"
    openscad --hardwarnings -o "$stl" "$scad"
    rm "$stl"
}

cleanup() {
    local out="$1"
    rm -r "$out/workdir"
}

cmd="$1"
out="$2"

"$cmd" "$out"
