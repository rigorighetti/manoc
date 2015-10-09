# Generated automatically with HTML::FormHandler::Generator::DBIC
# Using following commandline:
# form_generator.pl --rs_name=Host --label --schema_name=Manoc::DB --class_prefix=Manoc::Form --db_dsn=

package Manoc::Form::Contact;
use HTML::FormHandler::Moose;
extends 'Manoc::Form::Base';

with 'Manoc::Form::TraitFor::SaveButton';

use namespace::autoclean;

has '+item_class' => ( default => 'Contact' );
has '+name' => ( default => 'form-contact' );
has '+html_prefix' => ( default => 1 );

has_field 'name' => (
    type => 'Text',
    required => 1,
    label => 'Name',
    element_attr => { placeholder => 'Fullname' }
);

has_field 'email' => (
    label => 'Email',
    required => 0,
    type  => 'Email',
);


has_field telephone => ( 
    type         => 'Text',
    required     => 0,
    apply    => [
        'Str', {
     check => sub { $_[0] =~ /\d+/ },
     message => 'Invalid Telephone Number'
    }],
);

has_field 'notes' => ( 
    type => 'TextArea', 
    label => 'Notes', 
);


__PACKAGE__->meta->make_immutable;
no HTML::FormHandler::Moose;
