# Copyright 2011 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package Manoc::Search::Driver::WinLogon;
use Moose;
extends 'Manoc::Search::Driver';

use Manoc::Search::Item::IpAddr;

sub search_logon {
    my ( $self, $query, $result ) = @_;

    my $pattern = $query->sql_pattern;
    my $schema  = $self->engine->schema;
    my ( $e, $it );

    my $conditions = {};
    $conditions->{'user'} = { '-like', $pattern };
    if ( $query->limit ) {
        $conditions->{lastseen} = { '>=', $query->start_date };
    }

    $it = $schema->resultset('WinLogon')->search(
        $conditions,
        {
            select   => [ 'user', 'ipaddr', { max => 'lastseen' } ],
            as       => [ 'user', 'ipaddr', 'lastseen' ],
            group_by => 'ipaddr',
        }
    );

    while ( my $e = $it->next ) {
        my $item = Manoc::Search::Item::IpAddr->new(
            {
                match     => lc( $e->user ),
                addr      => $e->ipaddr->address,
                timestamp => $e->get_column('lastseen'),
            }
        );
        $result->add_item($item);
    }
}
