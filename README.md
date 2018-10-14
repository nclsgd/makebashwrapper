Lightweight Makefile foundations to wrap Bash scripts and complex commands
==========================================================================

This project is a set of makefiles and Bash scripts that are designed/hacked to
turn GNU Make and makefiles into complex Bash script wrappers.  It also
provides a set of Bash "library functions" to be used within those makefiles.

Integrated in larger and more purposeful projects, this can serve as a handy
way to wrap complex commands and still allowing to take advantage of the
makefile targets auto-completion features (via the use of common makefile
completion helpers, such as the _bash-completion_ functions).

Make also allows the user to chain invocations of recipes (which can be seen as
"sub-commands" of the overall project) in one `make` command call (recipes
cannot be repeated within the same call however).

Finally, a default recipe (that can still be changed via the GNU Make
`.DEFAULT_GOAL` variable) provides a way to list all the sub-commands/recipes
available to the user with a fancy self-description caption that is defined as
a header comment in the related recipes (however take care not to use any `$`
sign in these header comments as they might get wrongfully interpreted by
Make as they are part of the recipe's code).


How to use this?
----------------

Requirements on the environment to use this wrapper have purposely been kept as
minimal as possible to avoid as much as possible any exotic dependency to be
installed on the system: no Python, no Ruby, no compilation toolchain.  
Here are the environment requirements:

* A *nix environment
* GNU Make 4.0 (at least)
* Bash 4.3 (at least)
* The common *nix tools and utilities (i.e. sed, Awk and the common core
  utilities _coreutils_)

_Note:_ This GNU Make wrapper has been tested under Linux environments with GNU
toolchains and, to a lesser extent, with Busybox utilities.  However it should
also work under macOS or *BSD environments as long as the expected versions of
GNU Make and Bash are installed on these systems (which is, out-of-the-box,
usually not the case unlike most Linux environments).


Project status
--------------

This is a hobby project and still a work-in-progress.  It may be prone to
significant code evolutions.  But I use this code really frequently within some
other projects (most of them not public) to wrap complex scripts and it has
shown up to now enough stability to be made public.

To this day, this project still lacks some detailed documentation on how it
works and how to use it but the code has been commented here and there as best
as I could and should be self-explanatory for most developers and hackers
familiar with GNU Make.


License
-------

This is licensed under the MIT license.
