# Copyright 2011-2015 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package Manoc::ControllerRole::ObjectForm;

use Moose::Role;
use MooseX::MethodAttributes::Role;
use namespace::autoclean;

with 'Manoc::ControllerRole::Object';

has 'form_class' => (
    is  => 'rw',
    isa => 'ClassName'
);

has 'form_success_url' => (
    is  => 'rw',
    isa => 'Str'
);

has 'object_updated_message' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'Updated',
);

=head1 ACTIONS

=head2 form

Handle creation and editing of resources. Form defaults can be
injected using form_defaults in stash. Form is created by get_form method.

=cut

sub form : Private {
    my ( $self, $c ) = @_;

    my $item = $c->stash->{object};
    my $form = $self->get_form($c);

    $c->stash(
        form => $form,
        action => $c->uri_for( $c->action, $c->req->captures ),
    );
    unless ( $c->stash->{template} ) {
        $c->stash( template => $c->namespace . "/form.tt" );
    }

    # the "process" call has all the saving logic,
    #   if it returns False, then a validation error happened
    my %process_params;
    $process_params{item}   = $c->stash->{object};
    $process_params{params} = $c->req->parameters;
    if ( $c->stash->{form_defaults} ) {
        $process_params{defaults}              = $c->stash->{form_defaults};
        $process_params{use_defaults_over_obj} = 1;
    }

    if ( $self->can("get_form_process_params") ) {
        %process_params = $self->get_form_process_params( $c, %process_params );
    }
    my $process_status = $form->process(%process_params);

    if ( $c->stash->{is_xhr} ) {
        my $json_data = {};

        # render as a fragment
        $c->stash->{no_wrapper} = 1;

        $json_data->{form_ok} = $process_status ? 1 : 0;

        if ($process_status) {
            $c->stash->{object_id} = $form->item_id;

            $json_data->{message}      = $self->object_updated_message;
            $json_data->{redirect}     = $self->get_form_success_url($c);
            $json_data->{object_id}    = $form->item_id;
            $json_data->{object_label} = $form->item->label
                if $form->item->can('label');

        }
        else {
            my $template_name = $c->stash->{ajax_form_template};
            $template_name ||= $c->namespace . "/form.tt";
            $json_data->{html} =
                $c->forward( "View::TT", "render", [ $template_name, $c->stash ] );
        }
        $c->stash->{json_data} = $json_data;
        $c->detach('View::JSON');
    }

    return unless $process_status;
    $c->stash->{object_id} = $form->item_id;
    $c->stash->{message}   = $self->object_updated_message;

    $c->res->redirect( $self->get_form_success_url($c) );
    $c->detach();
}

=head1 METHODS

=head2 get_form

Create a new form using form_class configuration parameter.

=cut

sub get_form {
    my ( $self, $c ) = @_;

    my $class = $c->stash->{form_class} || $self->form_class;
    $class or die "Form class not set (use form_class)";

    my $parameters = $c->stash->{form_parameters} || {};
    return $class->new( ctx => $c, %$parameters );
}

=head2 get_form_success_url

Get the URL to redirect after successful editing.

=cut

sub get_form_success_url {
    my ( $self, $c ) = @_;

    my $form_success_url = $c->stash->{form_success_url} ||
        $self->form_success_url ||
        $c->uri_for_action( $c->namespace . "/view", [ $c->stash->{object_id} ] );

    return $form_success_url;
}

1;
# Local Variables:
# mode: cperl
# indent-tabs-mode: nil
# cperl-indent-level: 4
# cperl-indent-parens-as-block: t
# End:
