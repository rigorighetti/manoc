# Copyright 2011 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package Manoc::DB::Result::Building;

use parent 'DBIx::Class::Core';
use strict;
use warnings;

__PACKAGE__->load_components(qw/PK::Auto Core/);

__PACKAGE__->table('buildings');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'int',
        is_nullable       => 0,
        is_auto_increment => 1,
    },
    name => {
        data_type => 'varchar',
        size      => '32',
    },
    description => {
        data_type => 'varchar',
        size      => '255',
    },
    notes => {
        data_type   => 'text',
        is_nullable => 1,
    },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( [qw/name/] );

__PACKAGE__->has_many(
    racks => 'Manoc::DB::Result::Rack',
    'building_id', { cascade_delete => 0 }
);

__PACKAGE__->has_many(
    warehouses => 'Manoc::DB::Result::Warehouse',
    'building_id', { cascade_delete => 0 }
);

sub label {
    my $self  = shift;
    my $label = $self->name;
    $self->description and $label .= " (" . $self->description . ")";
    return $label;
}

1;
