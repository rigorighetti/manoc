# Copyright 2011 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package Manoc::DB::Result::Uplink;
use base 'DBIx::Class';
use strict;
use warnings;

__PACKAGE__->load_components(qw/ Core InflateColumn/);
__PACKAGE__->table('uplinks');

__PACKAGE__->add_columns(
    'device' => {
        data_type      => 'int',
        is_foreign_key => 1,
        is_nullable    => 0,
    },
    'interface' => {
        data_type   => 'varchar',
        is_nullable => 0,
        size        => 64
    },
);

__PACKAGE__->belongs_to( device_info => 'Manoc::DB::Result::Device', 'device' );
__PACKAGE__->set_primary_key( 'device', 'interface' );

__PACKAGE__->inflate_column(
			    device => {
				       inflate =>
				       sub { return Manoc::IpAddress::Ipv4->new({ padded => $_[0] }) if defined($_[0]) },
				       deflate => sub { return scalar $_[0]->padded if defined($_[0]) },
				      }
			   );


1;
