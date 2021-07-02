use Test2::V0 -no_srand => 1;
use Test2::Tools::Compare qw( check_set );
use File::Home;

delete $ENV{$_} for qw( HOME USERPROFILE HOMEDRIVE HOMEPATH );

if($^O eq 'MSWin32')
{
  {
    local $ENV{USERPROFILE} = 'C:\\Foo';
    is home(), 'C:\\Foo', 'home function works with USERPROFILE environment variable.';
  }
  {
    local $ENV{HOMEDRIVE} = 'X:';
    local $ENV{HOMEPATH}  = '\\Bar\\Baz';
    is home(), 'X:\\Bar\\Baz', 'home function works with HOMEDRIVE+HOMEPATH environment variables.';
  }
}
else
{
  local $ENV{HOME} = '/foo/bar';
  is home(), '/foo/bar', 'home function works with HOME environment variable.';
}

is home(), check_set(D(), !string('')), 'home function works in fallback mode.';
note "home in fallback: @{[ home() ]}";

done_testing;


