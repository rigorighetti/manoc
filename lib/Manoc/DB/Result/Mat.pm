# Copyright 2011 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package Manoc::DB::Result::Mat;

use base 'DBIx::Class';
use Manoc::IpAddress::Ipv4;

use strict;
use warnings;

__PACKAGE__->load_components(qw/ Core InflateColumn/);
__PACKAGE__->table('mat');

__PACKAGE__->add_columns(
    'macaddr' => {
        data_type   => 'varchar',
        is_nullable => 0,
        size        => 17
    },
    'device' => {
        data_type      => 'varchar',
        is_nullable    => 0,
        size           => 15,
        is_foreign_key => 1,
    },
    'interface' => {
        data_type   => 'varchar',
        is_nullable => 0,
        size        => 64,
    },
    'firstseen' => {
        data_type   => 'int',
        is_nullable => 0,
        size        => 11
    },
    'lastseen' => {
        data_type     => 'int',
        default_value => 'NULL',
        is_nullable   => 1,
    },
    'vlan' => {
        data_type     => 'int',
        default_value => 1,
        is_nullable   => 0,
        size          => 11
    },
    'archived' => {
        data_type     => 'int',
        default_value => 0,
        is_nullable   => 0,
        size          => 1
    },
);

__PACKAGE__->set_primary_key( 'macaddr', 'device', 'firstseen', 'vlan' );

__PACKAGE__->belongs_to( 'device_entry' => 'Manoc::DB::Result::Device', 'device' );

__PACKAGE__->resultset_class('Manoc::DB::ResultSet::Mat');

__PACKAGE__->inflate_column(
			    device => {
				       inflate =>
				       sub { return Manoc::IpAddress::Ipv4->new({ padded => $_[0] }) if defined($_[0]) },
				       deflate => sub { return scalar $_[0]->padded if defined($_[0]) },
				      } 
			   );


sub sqlt_deploy_hook {
    my ( $self, $sqlt_schema ) = @_;

    $sqlt_schema->add_index( name => 'idx_device',  fields => ['device'] );
    $sqlt_schema->add_index( name => 'idx_macaddr', fields => ['macaddr'] );

    $sqlt_schema->add_index( name => 'idx_dev_iface', fields => [ 'device', 'interface' ] );

}

1;

