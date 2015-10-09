# Generated automatically with HTML::FormHandler::Generator::DBIC
# Using following commandline:
# form_generator.pl --rs_name=Host --label --schema_name=Manoc::DB --class_prefix=Manoc::Form --db_dsn=

package Manoc::Form::Host;
use HTML::FormHandler::Moose;
extends 'Manoc::Form::Base';

with 'Manoc::Form::TraitFor::SaveButton';

use namespace::autoclean;

use HTML::FormHandler::Types ('IPAddress');

has '+item_class' => ( default => 'Host' );
has '+name' => ( default => 'form-host' );
has '+html_prefix' => ( default => 1 );

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
    required => 1,
    label    => 'Address',
    element_attr => { placeholder => 'e.g. 192.168.1.1' },
);

has_field 'contact_name' => (
    type => 'Text',
    required => 0,
    label => 'Assigned to',
    element_attr => { placeholder => 'Contact name' }
);

has_field 'contact_id' => (
    type         => 'Select',
    empty_select => '---Select owner---',
    required     => 1,
    label        => 'Owner',
);

has_field 'notes' => ( 
    type => 'TextArea', 
    label => 'Notes', 
);

sub options_contact_id {
    my $self = shift;
    return unless $self->schema;
    my @contacts = $self->schema->resultset('Contact')->search( {}, { order_by => 'name' } )->all();
    return map { label => $_->name, value => $_->id }, @contacts;
}

 # around 'update_model' => sub {
 #    my $orig = shift;
 #    my $self = shift;
 #    my $item = $self->item;
 #    $self->schema->txn_do( sub {
 #        $self->$orig(@_);  

 #    });
 # };
__PACKAGE__->meta->make_immutable;
no HTML::FormHandler::Moose;
