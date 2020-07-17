use strict;
use warnings;

use Test::More;

use Rex::Config;
use Rex::Template::Mojo;

BEGIN {
    eval "use Test::Exception";
    plan skip_all => "Test::Exception needed" if $@;
}

plan tests => 2;

my $tf = Rex::Config->get_template_function();

my $tmpl_ok = <<'TMPL_OK';
% my $name = shift;
Hello, <%= $name %>\
TMPL_OK

my $tmpl_broken = <<'TMPL_BROKEN';
Hello, <%= name %>\
TMPL_BROKEN

lives_and { is $tf->($tmpl_ok, 'Larry'), 'Hello, Larry' }
    'a valid template is rendered';
throws_ok { $tf->($tmpl_broken) } 'Mojo::Exception',
    'a broken template throws an exception';
