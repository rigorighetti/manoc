# Copyright 2016 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package Manoc::DB::Result::Group;

use parent 'DBIx::Class::Core';

use strict;
use warnings;

__PACKAGE__->load_components(qw(PK::Auto Core));

__PACKAGE__->table('groups');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'int',
        is_nullable       => 0,
        is_auto_increment => 1,
    },
    name => {
        data_type   => 'varchar',
        size        => 255,
        is_nullable => 0
    },
    description => {
        data_type   => 'text',
        is_nullable => 1,
    },
);
__PACKAGE__->set_primary_key(qw(id));
__PACKAGE__->add_unique_constraint( ['name'] );

__PACKAGE__->has_many( map_user_role => 'Manoc::DB::Result::GroupRole', 'group_id' );
__PACKAGE__->many_to_many( roles => 'map_user_role', 'role' );

__PACKAGE__->has_many( map_user_group => 'Manoc::DB::Result::UserGroup', 'group_id' );
__PACKAGE__->many_to_many( users => 'map_user_group', 'user' );

=head1 NAME

Manoc:DB::Group - A model object representing a group of users
the system.

=head1 DESCRIPTION

This is an object that represents a row in the 'groups' table of your
application database.  It uses DBIx::Class (aka, DBIC) to do ORM.

=cut

1;
