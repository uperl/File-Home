# File::Home ![static](https://github.com/uperl/File-Home/workflows/static/badge.svg) ![linux](https://github.com/uperl/File-Home/workflows/linux/badge.svg) ![windows](https://github.com/uperl/File-Home/workflows/windows/badge.svg) ![macos](https://github.com/uperl/File-Home/workflows/macos/badge.svg)

Find your home directory portably and without side effects

# SYNOPSIS

```perl
use File::Home;

my $dir = home;
```

# DESCRIPTION

There are already lots of ways to get the home directory in Perl.  Some are "in-core" and some are
CPAN modules.  Why write another?  Well they are either partly wrong, or they have unwanted side
effects.  Frequently both.  This module is an attempt to correctly find the user's home directory
in the safest, most correct way without side effects.

# FUNCTIONS

## home

```perl
my $dir = home;
```

Returns the home directory for the current user.  The exact algorithm depends on your platform.

- Unix
    - `HOME` environment variable.

        Used first if defined and not the empty string (`''`).

    - [getpwent](https://metacpan.org/pod/perlfunc#getpwent)

        If this function is implemented by your Perl, and if it provides a home directory that is not
        the empty string (`''`), then this value will be used.

    - Give up!

        If the home directory cannot be found by any of the means listed above an exception will
        be thrown.
- Windows
    - `USERPROFILE` environment variable.

        Used first if defined and not the empty string (`''`).

    - `HOMEDRIVE` and `HOMEPATH` environment variables.

        If both are defined and both are not the empty string (`''`) then these values
        will be concatenated to compute the home directory.

    - `GetFolderPath` + `CSIDL_PROFILE`

        Use the Win32 API get query the home directory.  This is roughly equivalent to
        using [getpwent](https://metacpan.org/pod/perlfunc#getpwent) in Windows.

    - Give up!

        If the home directory cannot be found by any of the means listed above an exception will
        be thrown.

# CAVEATS

Platforms currently supported:

- Linux
- macOS
- Windows
- FreeBSD
- NetBSD
- OpenBSD

I would expect it should work on any Unix.  It may not work on more esoteric
platforms like OpenVMS or Plan 9, but I am happy to add support if someone
does the legwork and creates a PR.

# SEE ALSO

- `<~>`

    This operator will give you the home directory.  It is correct in Unix, in that it will
    give you `HOME` environment variable and fallback on `getpwent` otherwise.  Unfortunately
    it also checks `HOME` on Windows and does not use `GetFolderPath` + `CSIDL_PROFILE` as
    a fallback.  On modern Perls it does check `USERPROFILE` on windows, but it does not
    prior to 5.16.

- [File::Glob](https://metacpan.org/pod/File::Glob)

    This module provides a function `bsd_glob` which will expand `~` to the home directory.
    It appears to use essentially the same algorithm as `<~>`.

- [File::HomeDir](https://metacpan.org/pod/File::HomeDir)

    This module supports lot of esoteric and defunct platforms like MacOS 9.  It also provides
    interfaces for finding application specific directories like Desktop and and Photo folders.
    It has dynamic prereqs on macOS, which can be annoying if you are just looking for the home
    directory and don't need the extra bells and whistles.  It also checks the `HOME` environment
    variable on Windows and does not use `GetFolderPath` + `CSIDL_PROFILE` as a fallback.

- [File::HomeDir::Tiny](https://metacpan.org/pod/File::HomeDir::Tiny)

    Wow.  This was intended to address the problems of [File::HomeDir](https://metacpan.org/pod/File::HomeDir) being just too much most
    of the time, while supporting older Windows Perls where `<~>` returns the wrong value.
    Unfortunately instead of special casing `MSWin32` it special cases `Win32` which is not
    a platform that exists for Perl.  This is a bug which has gone unaddressed ans unanswered
    since October 2018 as of this writing.

    If this bug were fixed it would essentially provide the same algorithm as `<~>` on all
    versions of Windows Perl, but as it is it provides the same exact algorithm as `` `~` ``
    including the fact that it does not work on older versions of Windows Perl.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2021 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
