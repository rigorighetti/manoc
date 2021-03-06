# Copyright 2011-2015 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package Manoc::Controller::DiscoverSession;
use Moose;
use namespace::autoclean;

use Manoc::Form::DiscoverSession;

BEGIN { extends 'Catalyst::Controller'; }
with "Manoc::ControllerRole::CommonCRUD" => { -exclude => qw/update/ };

=head1 NAME

Manoc::Controller::DiscoverSession - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

__PACKAGE__->config(
    # define PathPart
    action => {
        setup => {
            PathPart => 'autodiscover',
        }
    },
    class                   => 'ManocDB::DiscoverSession',
    form_class              => 'Manoc::Form::DiscoverSession',
    enable_permission_check => 1,
    view_object_perm        => undef,

);

sub get_object_list {
    my ( $self, $c ) = @_;

    my $rs = $c->stash->{resultset};
    return [
        $rs->search(
            {},
            {
                join      => 'discovered_hosts',
                distinct  => 1,
                '+select' => [ { count => 'discovered_hosts.id' } ],
                '+as'     => [qw/num_hosts/],

            }
        )
    ];
}

=head2 get_object

=cut

sub get_object {
    my ( $self, $c, $pk ) = @_;
    return $c->stash->{resultset}->find(
        $pk,
        {
            join     => 'discovered_hosts',
            prefetch => 'discovered_hosts',
        }
    );
}

sub command : Chained('base') : PathPart('command') : POST {
    my ( $self, $c ) = @_;

    my $id = $c->request->body_parameters->{session};
    my $session = $self->get_object( $c, $id );
    if ( !$session ) {
        $c->detach('/error/http_404');
    }

    my $cmd = lc( $c->request->body_parameters->{command} );

    # check permissions
    $cmd ~~ qw(restart|start|stop) and
        $c->require_permission( $session, 'edit' );
    $cmd eq 'delete' and
        $c->require_permission( $session, 'delete' );

    my $result = {};
    if ( $cmd eq 'restart' ) {
        $session->restart();
        $session->update();
        $result->{status} = 'success';
    }
    elsif ( $cmd eq 'stop' ) {
        if ( $session->is_waiting || $session->is_running ) {
            $session->status( $session->STATUS_STOPPED );
            $session->update();
        }
        $result->{status} = 'success';
    }
    elsif ( $cmd eq 'start' ) {
        if ( $session->is_stopped ) {
            $session->status( $session->STATUS_WAITING );
            $session->update();
        }
        $result->{status} = 'success';
    }
    elsif ( $cmd eq 'delete' ) {
        $session->delete();
        $result->{status} = 'success';
    }
    else {
        $result->{status}  = 'error';
        $result->{message} = 'command not found';
    }

    $c->stash( json_data => $result );
    $c->forward('View::JSON');
}

=head1 AUTHOR

The Manoc Team

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
# Local Variables:
# mode: cperl
# indent-tabs-mode: nil
# cperl-indent-level: 4
# cperl-indent-parens-as-block: t
# End:
