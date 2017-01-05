# Copyright 2011-2015 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package Manoc::ControllerRole::JQDatatable;

use Moose::Role;
use MooseX::MethodAttributes::Role;
use namespace::autoclean;

=head1 NAME

Manoc::ControllerRole::JQDatatable - Support for DataTables Table jQuery

=head1 DESCRIPTION

Catalyst controller role for helping managing ajax request for datatables.
See L<http://datatables.net/examples/data_sources/server_side.html>

=cut

has datatable_search_columns => (
    is      => 'rw',
    isa     => 'ArrayRef[Str]',
    lazy    => 1,
    builder => '_build_datatable_search_columns'
);

has datatable_columns => (
    is  => 'rw',
    isa => 'ArrayRef[Str]',
);

# used add options if needed (JOIN, PREFETCH, ...)
has datatable_search_options => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },
);

has datatable_search_callback => ( is => 'rw', );

has datatable_row_callback => ( is => 'rw', );

sub _build_datatable_search_columns {
    my $self = shift;
    $self->datatable_columns or return [];
    return [ @{ $self->datatable_columns } ];
}

sub get_datatable_resultset {
    my ( $self, $c ) = @_;

    return $c->stash->{'resultset'};
}

sub datatable_source : Chained('base') : PathPart('datatable_source') : Args(0)
    {
    my ( $self, $c ) = @_;

    my $start  = $c->request->param('start') || 0;
    my $length = $c->request->param('length');
    my $draw   = $c->request->param('draw') || 0;
    my $search = $c->request->param("search[value]");

    my $rs = $c->stash->{'datatable_resultset'} ||
        $self->get_datatable_resultset($c);

    my $col_names = $c->stash->{'datatable_columns'} ||
        $self->datatable_columns;

    my $search_columns = $c->stash->{'datatable_search_columns'} ||
        $self->datatable_search_columns;

    my $search_callback = $c->stash->{'datatable_search_callback'} ||
        $self->datatable_search_callback;


    my $row_callback = $c->stash->{'datatable_row_callback'} ||
        $self->datatable_row_callback;

    # create  search filter (WHERE clause)
    my $search_filter = {};
    if ($search) {
        $search_filter = [];

        foreach my $col (@$search_columns) {
            push @$search_filter, { $col => { -like => "%$search%" } };
            $c->log->debug("$col like $search");
        }
    }

    my $total_rows = $rs->count();

    my $search_attrs = { %{ $self->datatable_search_options } };

    # paging (LIMIT clause)
    if ($length) {
        my $page = $length > 0 ? ( $start + 1 ) / $length : 1;
        $page == int($page) or $page = int($page) + 1;

        $search_attrs->{page} = $page;
        $search_attrs->{rows} = $length;
        $c->log->debug("page = $page length = $length");
    }

    my $sort_column_i = $c->request->param('order[0][column]');
    if ( defined($sort_column_i) ) {
        my $column = $col_names->[$sort_column_i];
        my $dir = $c->request->param("order[0][dir]") eq 'desc' ? '-desc' : '-asc';

        $search_attrs->{order_by} = { $dir => $column };
        $c->log->debug("order by $column $dir");
    }

    $search_callback and
        $self->$search_callback( $c, $search_filter, $search_attrs );

    my $search_rs = $rs->search_rs( $search_filter, $search_attrs );
    my $filtered_rows = $rs->search_rs->count();

    # search
    my @rows;
    while ( my $item = $search_rs->next ) {
        my $row;
        if ($row_callback) {
            $row = $self->$row_callback( $c, $item );
        }
        else {
            $row = {};

            foreach my $name (@$col_names) {
                # default accessor is preferred
                my $v = $item->can($name) ? $item->$name : $item->get_column($name);
                $row->{$name} = $v;
            }
        }
        push @rows, $row;
    }

    my $data = {
        draw            => int($draw),
        data            => \@rows,
        recordsTotal    => $total_rows,
        recordsFiltered => $filtered_rows,
    };

    $c->stash( 'json_data' => $data );
    $c->forward('View::JSON');
}

1;
# Local Variables:
# mode: cperl
# indent-tabs-mode: nil
# cperl-indent-level: 4
# cperl-indent-parens-as-block: t
# End:
