# Copyright 2011 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.

package Manoc::DataDumper::Converter::v1;

use Moose;
use Data::Dumper;

extends 'Manoc::DataDumper::Converter::Base';

# check for spurious data
sub upgrade_winlogon {
    my ( $self, $data ) = @_;
    my $count = 0;
    my ( $i, $name );
    return 0 unless ( defined($data) );

    for ( $i = 0; $i < scalar( @{$data} ); $i++ ) {
        $name = $data->[$i]->{'user'};
        if ( $name =~ m/^\W$/ ) {
            $count++;
            splice( @{$data}, $i, 1 );
        }
    }
    return $count;
}

no Moose;    # Clean up the namespace.
__PACKAGE__->meta->make_immutable();
1;
