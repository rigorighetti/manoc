# Copyright 2015 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package Manoc::Controller::Server;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

with 'Manoc::ControllerRole::CommonCRUD';

use Manoc::Form::Server;
use Manoc::Form::Server::Decommission;
use Manoc::Form::ServerNWInfo;

=head1 NAME

Manoc::Controller::Server - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=cut

__PACKAGE__->config(
    # define PathPart
    action => {
        setup => {
            PathPart => 'server',
        }
    },
    class                   => 'ManocDB::Server',
    form_class              => 'Manoc::Form::Server',
    enable_permission_check => 1,
    view_object_perm        => undef,
    json_columns            => [ 'id', 'name' ],

    find_object_options => { prefetch => { installed_sw_pkgs => 'software_pkg' } },

    create_page_title => 'Create server',
    edit_page_title   => 'Edit server',
);

=head2 create

=cut

before 'create' => sub {
    my ( $self, $c ) = @_;

    my $serverhw_id = $c->req->query_parameters->{'serverhw'};
    my $vm_id       = $c->req->query_parameters->{'vm'};
    my %form_defaults;

    if ( defined($serverhw_id) ) {
        $c->log->debug("new server using hardware $serverhw_id") if $c->debug;
        $form_defaults{serverhw} = $serverhw_id;
        $form_defaults{type}     = 'p';
    }
    if ( defined($vm_id) ) {
        $c->log->debug("new server using vm $vm_id") if $c->debug;
        $form_defaults{vm}   = $vm_id;
        $form_defaults{type} = 'v';
    }
    %form_defaults and
        $c->stash( form_defaults => \%form_defaults );
};

=head2 edit

=cut

before 'edit' => sub {
    my ( $self, $c ) = @_;

    my $object    = $c->stash->{object};
    my $object_pk = $c->stash->{object_pk};

    # decommissioned objects cannot be edited
    if ( $object->decommissioned ) {
        $c->res->redirect( $c->uri_for_action( 'server/view', [$object_pk] ) );
        $c->detach();
    }
};

=head2 decommission

=cut

sub decommission : Chained('object') : PathPart('decommission') : Args(0) {
    my ( $self, $c ) = @_;

    $c->require_permission( $c->stash->{object}, 'edit' );

    my $form = Manoc::Form::Server::Decommission->new( { ctx => $c } );

    $c->stash(
        form   => $form,
        action => $c->uri_for( $c->action, $c->req->captures ),
    );
    return unless $form->process(
        item   => $c->stash->{object},
        params => $c->req->parameters,
    );

    $c->response->redirect( $c->uri_for_action( 'server/view', [ $c->stash->{object_pk} ] ) );
    $c->detach();
}

=head2 restore

=cut

sub restore : Chained('object') : PathPart('restore') : Args(0) {
    my ( $self, $c ) = @_;

    my $server = $c->stash->{object};
    $c->require_permission( $server, 'edit' );

    if ( !$server->decommissioned ) {
        $c->response->redirect( $c->uri_for_action( 'server/view', [ $server->id ] ) );
        $c->detach();
    }

    if ( $c->req->method eq 'POST' ) {
        $server->restore;
        $server->update();
        $c->flash( message => "Server restored" );
        $c->response->redirect( $c->uri_for_action( 'server/view', [ $server->id ] ) );
        $c->detach();
    }

    # show confirm page
    $c->stash(
        title           => 'Restore server',
        confirm_message => 'Restore decommissioned server ' . $server->label . '?',
        template        => 'generic_confirm.tt',
    );
}

=head2 nwinfo

=cut

sub nwinfo : Chained('object') : PathPart('nwinfo') : Args(0) {
    my ( $self, $c ) = @_;

    $c->require_permission( $c->stash->{object}, 'netwalker_config' );

    my $server_id = $c->stash->{object_pk};

    my $nwinfo = $c->model('ManocDB::ServerNWinfo')->find($server_id);
    $nwinfo or $nwinfo = $c->model('ManocDB::ServerNWInfo')->new_result( {} );

    my $form = Manoc::Form::ServerNWInfo->new(
        {
            server => $server_id,
            ctx    => $c,
        }
    );
    $c->stash( form => $form );
    return unless $form->process(
        params => $c->req->params,
        item   => $nwinfo
    );

    $c->response->redirect( $c->uri_for_action( 'server/view', [$server_id] ) );
    $c->detach();
}

=head2 refresh

=cut

sub refresh : Chained('object') : PathPart('refresh') : Args(0) {
    my ( $self, $c ) = @_;
    my $id = $c->stash->{object}->id;

    my $config = Manoc::Netwalker::Config->new( $c->config->{Netwalker} || {} );
    my $client = Manoc::Netwalker::ControlClient->new( config => $config );

    my $status = $client->enqueue_server($id);

    if ( !$status ) {
        $c->flash( error_msg => "An error occurred while scheduling server refresh" );
    }
    else {
        $c->flash( message => "Device refresh scheduled" );
    }

    $c->response->redirect( $c->uri_for_action( '/server/view', [$id] ) );
    $c->detach();
}

=head2 update_fromnwinfo

=cut

sub update_from_nwinfo : Chained('object') : PathPart('from_nwinfo') : Args(0) {
    my ( $self, $c ) = @_;

    my $server = $c->stash->{object};
    $c->require_permission( $server, 'edit' );

    my $response = {};
    $response->{success} = 0;

    if ( !$server->decommissioned &&
        defined( $server->netwalker_info ) &&
        $c->req->method eq 'POST' )
    {
        my $nwinfo = $server->netwalker_info;
        my $what   = lc( $c->req->params->{what} );
        $what eq 'hostname' and $server->hostname( $nwinfo->name );
        $what eq 'os'       and $server->os( $nwinfo->os );
        $what eq 'os_ver'   and $server->os_ver( $nwinfo->os_ver );
        $server->update();
        $response->{success} = 1;
    }

    $c->stash( json_data => $response );
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
