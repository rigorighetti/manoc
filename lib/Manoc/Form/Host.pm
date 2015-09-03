# Generated automatically with HTML::FormHandler::Generator::DBIC
# Using following commandline:
# form_generator.pl --rs_name=Host --label --schema_name=Manoc::DB --class_prefix=Manoc::Form --db_dsn=

package Manoc::Form::Host;
use HTML::FormHandler::Moose;
extends 'Manoc::Form::Base';

with 'Manoc::Form::Base::SaveButton';

use namespace::autoclean;
use HTML::FormHandler::Types ('IPAddress');

has '+item_class' => ( default => 'Host' );
has '+name' => ( default => 'form-host' );
has '+html_prefix' => ( default => 1 );

sub build_render_list {[   'name','macaddr','ipaddr', 'notes','save' ]}

has_field 'name' => (
    type => 'Text',
    required => 1,
    label => 'Name',
    element_attr => { placeholder => 'Hostname' }
);

has_field 'macaddr' => ( 
    type => 'Text', 
    size => 17, 
    label => 'Mac Address', 
    apply => [
         {  check   => qr/([0-9a-f]{2}:){5}[0-9a-f]{2}/,
            message => "Bad Mac Address format" }
      ],
    element_attr => { placeholder => 'e.g. aa:bb:cc:dd:ee:ff' }
);

has_field 'ipaddr' => (
    apply => [ IPAddress ],
    size => 15,
    required => 0,
    label    => 'Address',
    element_attr => { placeholder => 'e.g. 192.168.1.1' },
);


has_field 'notes' => ( 
    type => 'TextArea', 
    label => 'Notes', 
);


__PACKAGE__->meta->make_immutable;
no HTML::FormHandler::Moose;



# Copyright 2011-2015 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
# package Manoc::Form::IPNetwork;

# use HTML::FormHandler::Moose;
# extends 'Manoc::Form::Base';
# with 'Manoc::Form::Base::SaveButton';
# with 'Manoc::Form::Base::Horizontal';

# use namespace::autoclean;
# use HTML::FormHandler::Types ('IPAddress');

# has '+name' => ( default => 'form-ipnetwork' );
# has '+html_prefix' => ( default => 1 );

# has '+item_class' => (
#     default => 'IPNetwork'
# );

# sub build_render_list {[ 'network_block', 'name', 'vlan_id', 'description', 'save' ]}

# has_block 'network_block' => (
#     render_list => ['address', 'prefix'],
#     tag => 'div',
#     class => [ 'form-group' ],
# );

# has_field 'address' => (
#     apply => [ IPAddress ],
#     size => 15,
#     required => 1,
#     label    => 'Address',
#     do_wrapper => 0,

#     # we set wrapper=>0 so we don't have the inner div too!
#     tags => {
#         before_element => '<div class="col-sm-6">' , after_element => '</div>'
#     },
#     label_class =>  [ 'col-sm-2' ],
#     element_attr => { placeholder => 'IP Address' }
# );

# has_field 'prefix' => (
#     type => 'Integer',
#     required => 1,
#     size     => 2,
#     label    => 'Prefix',
#     do_wrapper => 0,
#     tags => {
#         before_element => '<div class="col-sm-2">' , after_element => '</div>'
#     },
#     label_class =>  [ 'col-sm-2' ],
#     element_attr => { placeholder => '24' }
# );

# has_field 'name' => (
#     type => 'Text',
#     required => 1,
#     label => 'Name',
#     element_attr => { placeholder => 'Network name' }
# );

# has_field 'vlan_id' => (
#     type => 'Select',
#     label => 'Vlan',
#     empty_select => '---Choose a VLAN---',
# );

# has_field 'description' => (
#     type => 'TextArea',
#     label => 'Description',
# );

# sub options_vlan_id {
#     my $self = shift;

#     return unless $self->schema;
#     my $rs = $self->schema->resultset('Vlan')->search( {}, { order_by => 'id' } );
#     return map +{ value => $_->id, label => $_->name . " (" . $_->id . ")" }, $rs->all();
# }

# __PACKAGE__->meta->make_immutable;
# no HTML::FormHandler::Moose;
# 1;
# Local Variables:
# mode: cperl
# indent-tabs-mode: nil
# cperl-indent-level: 4
# cperl-indent-parens-as-block: t
# End:
