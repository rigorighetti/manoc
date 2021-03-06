# Copyright 2015 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.

package Manoc::Form::TraitFor::Theme;
use Moose::Role;

with 'HTML::FormHandler::Widget::Theme::Bootstrap3';

# widget wrapper must be set before the fields are built in BUILD

sub build_do_form_wrapper { 1 }

sub build_form_tags {
    { wrapper_tag => 'div', };
}

1;
# Local Variables:
# mode: cperl
# indent-tabs-mode: nil
# cperl-indent-level: 4
# cperl-indent-parens-as-block: t
# End:
