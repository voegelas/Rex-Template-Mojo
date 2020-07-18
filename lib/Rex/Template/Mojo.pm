#
# (c) James King<yiming.jin@live.com>
#
# vim: set ts=4 sw=4 tw=0:
# vim: set expandtab:

=head1 NAME

Rex::Template::Mojo - Use Mojo::Template with Rex

=head1 SYNOPSIS

    # Rexfile
    use Rex -feature => ['1.4'];
    use Rex::Template::Mojo;

    task 'mytask', 'server1', sub {
      my $content = template('@krb5.conf',
        kerberos => {
          default_realm      => 'ATHENA.MIT.EDU',
          permitted_enctypes => [ 'des3-cbc-sha1', 'arcfour-hmac-md5' ],
          domain_realm       => { 'mit.edu' => 'ATHENA.MIT.EDU' }
        }
      );
      file "/etc/krb5.conf", content => $content;
    };

    __DATA__
    @krb5.conf
    % my $data = shift;
    % my $kerberos = $data->{kerberos};
    [libdefaults]
    default_realm = <%= $kerberos->{default_realm} %>
    permitted_enctypes = <%= join ' ', @{$kerberos->{permitted_enctypes}} %>
    forwardable = <%= $kerberos->{forwardable} // 'true' %>

    [domain_realm]
    % for my $domain (sort keys %{$kerberos->{domain_realm}}) {
    %   my $realm = $kerberos->{domain_realm}->{$domain};
        <%= $domain %> = <%= $realm %>
    % }
    @end

=head1 DESCRIPTION

This module enables the use of Mojo::Template for Rex, the friendly automation
framework.

If Rex::Template::Mojo is included into your I<Rexfile>, all templates are
rendered with Mojo::Template instead of Rex::Template.

=head2 Pragmas

Pragmas change the way that Rex::Template::Mojo functions.  Example:

    use Rex::Template::Mojo qw(-vars);

The current list of pragmas is as follows:

=over 4

=item -no_vars

The template variables are passed in a hash. This is the default setting.
An example template:

    % my $data = shift;
    <%= $data->{operating_system} %>

=item -vars

The template variables are passed as named variables. For example:

    <%= $operating_system %>

=back

=head2 Configuration Management Database

Template variables can be set in the configuration management database.  See
Rex::CMDB for more information.  An example YAML file is shown below:

    ---
    kerberos:
      default_realm: 'ATHENA.MIT.EDU'
      permitted_enctypes:
        - 'des3-cbc-sha1'
        - 'arcfour-hmac-md5'
      domain_realm:
        'mit.edu': 'ATHENA.MIT.EDU'

=head1 SEE ALSO

Rex::Commands::File, Rex::CMDB, Mojo::Template

=cut

package Rex::Template::Mojo;

use strict;
use warnings;

our $VERSION = "1.001";

use Mojo::Template;
use Rex -base;
use 5.010;

our $PASS_NAMED_VARS = 0;

sub _render {
    my ( $content, $vars ) = @_;

    my $t = Mojo::Template->new;
    $t->vars($PASS_NAMED_VARS);
    my $output = $t->render( $content, $vars );
    if ( ref $output ) {
        die $output;
    }
    return $output;
}

sub import {
    my ( $class, @params ) = @_;

    for (@params) {
        $PASS_NAMED_VARS = 0, next if /^-no_?vars$/;
        $PASS_NAMED_VARS = 1, next if /^-vars$/;
    }

    set template_function => \&_render;
}

1;

