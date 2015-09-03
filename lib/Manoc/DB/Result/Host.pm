# Copyright 2011 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package Manoc::DB::Result::Host;


use parent 'DBIx::Class::Core';
use strict;
use warnings;

__PACKAGE__->load_components(qw/+Manoc::DB::InflateColumn::IPv4/);

__PACKAGE__->table('host');

__PACKAGE__->add_columns(
    'id' => {
        data_type         => 'int',
        is_nullable       => 0,
        is_auto_increment => 1,
    },
    'name' => {
        data_type   => 'varchar',
        is_nullable => 0,
        size        => 64,
    },
    'ipaddr' => {
        data_type   => 'varchar',
        is_nullable => 1,
        size        => 15,
	    ipv4_address => 1,
    },
    'macaddr' => {
        data_type   => 'varchar',
        is_nullable => 1,
        size        => 17
    },    
    'notes' => {
        data_type   => 'text',
        is_nullable => 1,
    },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( [ 'name' ] );


1;
