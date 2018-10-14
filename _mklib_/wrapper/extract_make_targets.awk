#!/usr/bin/awk -f
# SPDX-License-Identifier: MIT
# Copyright 2019-2020 Nicolas Godinho <nicolas@godinho.me>

# This Awk script extracts the targets from a GNU Makefile database (only in
# the C locale!) and outputs the list of targets followed by the description
# (i.e. the "header" comment in the target recipe) properly escaped for Bash.
# To get the GNU Makefile database (the returned error code can be ignored):
#   LC_ALL=C make -npq ._DUMMY_UNMATCHED_TARGET_

# String trimming functions:
function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s; }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s; }
function trim(s) { return rtrim(ltrim(s)); }

# String escaping function for Bash (to be unescaped with eval or declare):
function bashescapestr(s,     _a, _i, _n, _r) {
    _r=""; _n=split(s, _a, "\n");
    for (_i=1;_i<=_n;_i++) {
        gsub(/'+/, "'\"&\"'", _a[_i]); _a[_i]="'"_a[_i]"'";
        _r=_r"$'\\n'"_a[_i];
    }
    sub(/^\$'\\n'/, "", _r); return _r;
}

# Initialization:
BEGIN {
    begin_block=1; in_define_ctx=0; in_targets_part=0;
    in_target_block=0; target=""; desc=""; in_desc=0; in_recipe=0;
}
# Anything can happen in a define..endef block, ditch those lines:
( ! in_targets_part && /^define [^:=]/) { in_define_ctx=1; next; }
( in_define_ctx ) { if ($0 == "endef") { in_define_ctx=0; } next; }
# When does the target enumeration starts in the Make database?
( begin_block && ! in_targets_part && /^# (Directories|Files)$/) {
    in_targets_part=1; next;
}
# Sometimes target definitions can be found after some comments:
( begin_block && in_targets_part && ! /^# Not a target/) { in_target_block=1; }
# Extract the target name if we are in a target block and line looks like it:
( in_target_block && in_targets_part && /^[^#\. \t].+:/) { sub(/:.*$/, ""); target=$0; desc=""; }
# Detect the beginning of a code block (they are separated with blank lines):
{ begin_block = ($0 == ""); }
# Upon new block, dump what have been extracted so far and reset variables:
( begin_block ) {
    if (target != "") print target" "bashescapestr(trim(desc));
    in_target_block=0; target=""; desc=""; in_desc=0; in_recipe=0; next;
}
# Extract the description lines (header comment) of the target (if any set):
( in_target_block && target != "" && /^\t/ ) {
    if ((! in_recipe && ! in_desc && match($0, /^\t[\-\+@]*# ?/)) \
         || ( in_desc && match($0, /^\t+# ?/))) {
        in_desc=1; sub(/^[^#]+# ?/, ""); desc=desc"\n"rtrim($0);
    } else { in_desc=0; }
    in_recipe=1;
}
# Exhaustiveness: if a target still remains, print it.
END { if (target != "") print target" "bashescapestr(trim(desc)); }

# vim: set ft=awk ts=4 sw=4 et ai tw=79:
