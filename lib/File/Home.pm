package File::Home;

use strict;
use warnings;
use 5.008004;
use Exporter qw( import );
use if $^O eq 'MSWin32', 'Win32';

our @EXPORT = qw( home );

# ABSTRACT: Find your home directory portably and without side effects
# VERSION

=head1 SYNOPSIS

 use File::Home;

 my $dir = home;

=head1 DESCRIPTION

There are already lots of ways to get the home directory in Perl.  Some are "in-core" and some are
CPAN modules.  Why write another?  Well they are either partly wrong, or they have unwanted side
effects.  Frequently both.  This module is an attempt to correctly find the user's home directory
in the safest, most correct way without side effects.

=head1 FUNCTIONS

=head2 home

 my $dir = home;

Returns the home directory for the current user.  The exact algorithm depends on your platform.

=over 4

=item Unix

=over 4

=item C<HOME> environment variable.

Used first if defined and not the empty string (C<''>).

=item L<getpwent|perlfunc/getpwent>

If this function is implemented by your Perl, and if it provides a home directory that is not
the empty string (C<''>), then this value will be used.

=item Give up!

If the home directory cannot be found by any of the means listed above an exception will
be thrown.

=back

=item Windows

=over 4

=item C<USERPROFILE> environment variable.

Used first if defined and not the empty string (C<''>).

=item C<HOMEDRIVE> and C<HOMEPATH> environment variables.

If both are defined and both are not the empty string (C<''>) then these values
will be concatenated to compute the home directory.

=item C<GetFolderPath> + C<CSIDL_PROFILE>

Use the Win32 API get query the home directory.  This is roughly equivalent to
using L<getpwent|perlfunc/getpwent> in Windows.

=item Give up!

If the home directory cannot be found by any of the means listed above an exception will
be thrown.

=back

=back

=cut

if($^O eq 'MSWin32')
{
  *home = sub {

    # 1. Try the USERPROFILE environment variable.
    return $ENV{USERPROFILE} if defined $ENV{USERPROFILE} and $ENV{USERPROFILE} ne '';

    # 2. Try HOMEDRIVE and HOMEPATH environment variables.
    return "$ENV{HOMEDRIVE}$ENV{HOMEPATH}"
      if defined $ENV{HOMEDRIVE} && $ENV{HOMEDRIVE} ne ''
      && defined $ENV{HOMEPATH}  && $ENV{HOMEPATH}  ne '';

    # 3. Try GetFolderPath
    my $getfolderpath_home = Win32::GetFolderPath(Win32::CSIDL_PROFILE(), 0);
    return $getfolderpath_home if defined $getfolderpath_home && $getfolderpath_home ne '';

    # 4. Give up.
    die "unable to determine home directory";
  };
}
else
{
  *home = sub {

    # 1. Try the HOME environment variable.
    return $ENV{HOME} if defined $ENV{HOME} and $ENV{HOME} ne '';

    # 2. Use getpwent to get the home directory.
    my $getpwent_home = eval { [getpwuid($>)]->[7] };
    return $getpwent_home if defined $getpwent_home && $getpwent_home ne '';

    # 3. Give up.
    die "unable to determine home directory";
  };
}

=head1 CAVEATS

Platforms currently supported:

=over 4

=item Linux

=item macOS

=item Windows

=item FreeBSD

=item NetBSD

=item OpenBSD

=back

I would expect it should work on any Unix.  It may not work on more esoteric
platforms like OpenVMS or Plan 9, but I am happy to add support if someone
does the legwork and creates a PR.

=head1 SEE ALSO

=over 4

=item C<< <~> >>

This operator will give you the home directory.  It is correct in Unix, in that it will
give you C<HOME> environment variable and fallback on C<getpwent> otherwise.  Unfortunately
it also checks C<HOME> on Windows and does not use C<GetFolderPath> + C<CSIDL_PROFILE> as
a fallback.  On modern Perls it does check C<USERPROFILE> on windows, but it does not
prior to 5.16.

=item L<File::Glob>

This module provides a function C<bsd_glob> which will expand C<~> to the home directory.
It appears to use essentially the same algorithm as C<< <~> >>.

=item L<File::HomeDir>

This module supports lot of esoteric and defunct platforms like MacOS 9.  It also provides
interfaces for finding application specific directories like Desktop and and Photo folders.
It has dynamic prereqs on macOS, which can be annoying if you are just looking for the home
directory and don't need the extra bells and whistles.  It also checks the C<HOME> environment
variable on Windows and does not use C<GetFolderPath> + C<CSIDL_PROFILE> as a fallback.

=item L<File::HomeDir::Tiny>

Wow.  This was intended to address the problems of L<File::HomeDir> being just too much most
of the time, while supporting older Windows Perls where C<< <~> >> returns the wrong value.
Unfortunately instead of special casing C<MSWin32> it special cases C<Win32> which is not
a platform that exists for Windows.  This is a bug which has gone unaddressed ans unanswered
since October 2018 as of this writing.

If this bug were fixed it would essentially provide the same algorithm as C<< <~> >> on all
versions of Windows Perl, but as it is it provides the same exact algorithm as C<< C<~> >>
including the fact that it does not work on older versions of Windows Perl.

=back

=cut

1;
