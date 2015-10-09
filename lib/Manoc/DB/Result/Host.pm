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
        data_type     => 'varchar',
        is_nullable   => 0,
        size          => 64,
    },
    'ipaddr' => {
        data_type     => 'varchar',
        is_nullable   => 0,
        size          => 15,
	    ipv4_address  => 1,
    },
    'macaddr' => {
        data_type     => 'varchar',
        is_nullable   => 1,
        size          => 17
    }, 
    'contact_id' => {
        data_type     => 'int',
        default_value => 'NULL',
        is_nullable   => 1,
    }, 
    'contact_name' => {
        data_type     => 'varchar',
        is_nullable   => 1,
        default_value => 'NULL',
        size          => 256,
        accessor => '_contact_name',
    },
    'notes' => {
        data_type     => 'text',
        is_nullable   => 1,
    },
);

sub contact_name {
  my $self = shift;

  if (@_) {
     $self->_contact_name(@_);
  }

  return $self->contact_id ? $self->contact_entry->name : $self->_contact_name;
}

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( [ 'name', 'ipaddr' ] );

__PACKAGE__->belongs_to( contact_entry => 'Manoc::DB::Result::Contact',
                                          {'foreign.id' => 'self.contact_id'},
                                          { join_type => 'LEFT' }
                        );


1;
