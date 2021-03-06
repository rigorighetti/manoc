# Copyright 2011 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package Manoc::Search::Driver::Hostname;
use Moose;
use Manoc::Search::Item::Hostname;

extends 'Manoc::Search::Driver';

sub search_inventory {
    my ( $self, $query, $result ) = @_;
    my ( $it, $e );
    my $pattern = $query->sql_pattern;
    my $schema  = $self->engine->schema;

    $it = $schema->resultset('WinHostname')->search(
        { name => { '-like' => $pattern } },
        {
            order_by => 'name',
            group_by => 'ipaddr',
        }
    );

    while ( $e = $it->next ) {

        my $item = Manoc::Search::Item::Hostname->new( { hostname => $e } );
        $result->add_item($item);
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;
