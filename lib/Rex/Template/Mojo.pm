#
# (c) James King<yiming.jin@live.com>
#
# vim: set ts=4 sw=4 tw=0:
# vim: set expandtab:

=head1 NAME

Rex::Template::Mojo - Use Mojo::Template with Rex

=head1 DESCRIPTION

This module enables the use of Mojo::Template for Rex Templates.

=head1 USAGE

Just include the file into your I<Rexfile>.

 # Rexfile
 use Rex::Template::Mojo;
    
 task prepare => sub {
    
    file "/a/file/on/the/remote/machine.conf",
       content => template("path/to/your/template.tt", 
                              var1  => $var1,
                              arr1  => \@arr1,
                              hash1 => \%hash1,
                          );
                       
 };

=cut

package Rex::Template::Mojo;

use strict;
use warnings;

our $VERSION = "1.0";

use Mojo::Template;
use Rex -base;
use 5.010;

sub _render {
    my ( $content, $vars ) = @_;

    my $t = Mojo::Template->new;
    my $output = $t->render( $content, $vars );
    if ( ref $output ) {
        die $output;
    }
    return $output;
}

sub import {
    set template_function => \&_render;
}

1;

