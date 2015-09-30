# Copyright 2011 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package Manoc::DB::Result::Contact;


use parent 'DBIx::Class::Core';
use strict;
use warnings;

__PACKAGE__->load_components();

__PACKAGE__->table('contact');

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
    'email' => {
        data_type   => 'varchar',
        size        => 128,
        is_nullable => 1
    },   
    'phone' => {
        data_type   => 'varchar',
        size        => 56,
        is_nullable => 1
    },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( [ 'name' ] );


1;
