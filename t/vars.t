use strict;
use warnings;

use Test::More tests => 1;

use Rex::Config;
use Rex::Template::Mojo qw(-vars);

my $tf = Rex::Config->get_template_function();

my $tmpl = <<'TMPL';
[libdefaults]
default_realm = <%= $kerberos->{default_realm} %>
permitted_enctypes = <%= join ' ', @{$kerberos->{permitted_enctypes}} %>
forwardable = <%= $kerberos->{forwardable} // 'true' %>

[domain_realm]
% for my $domain (sort keys %{$kerberos->{domain_realm}}) {
%   my $realm = $kerberos->{domain_realm}->{$domain};
    <%= $domain %> = <%= $realm %>
% }
TMPL

my $vars = {
    kerberos => {
        default_realm      => 'ATHENA.MIT.EDU',
        permitted_enctypes => [ 'des3-cbc-sha1', 'arcfour-hmac-md5' ],
        domain_realm       => { 'mit.edu' => 'ATHENA.MIT.EDU' },
    }
};

my $output = <<'OUTPUT';
[libdefaults]
default_realm = ATHENA.MIT.EDU
permitted_enctypes = des3-cbc-sha1 arcfour-hmac-md5
forwardable = true

[domain_realm]
    mit.edu = ATHENA.MIT.EDU
OUTPUT

is( $tf->( $tmpl, $vars ), $output, 'pass named variables' );
