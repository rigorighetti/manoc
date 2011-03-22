# Copyright 2011 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.

package Manoc::DataDumper::Converter;

use Moose;
use Class::MOP;

has 'log' => (
    is       => 'ro',
    required => 1,
);

sub get_converter_class {
    my ( $self, $release ) = @_;

    my $class_name;
    
    $release eq '1.000000' and $class_name = 'Converter_1000000';

    $class_name or return undef;
    $class_name = "Manoc::DataDumper::Converter::$class_name";
    Class::MOP::load_class($class_name) or return undef;
    return $class_name;
}

sub upgrade_table {
    my ( $self, $data, $table ) = @_;

    my $method_name = "upgrade_$table";
    return 0 unless $self->can($method_name);

    $self->log->info("Running converter for table $table");
    return $self->$method_name($data);
}

no Moose;    # Clean up the namespace.
__PACKAGE__->meta->make_immutable();

# Local Variables:
# mode: cperl
# indent-tabs-mode: nil
# cperl-indent-level: 4
# cperl-indent-parens-as-block: t
# End: