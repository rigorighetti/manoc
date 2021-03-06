# Copyright 2016 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package Manoc::DB::ResultSet::HWAsset;

use base 'DBIx::Class::ResultSet';
use strict;
use warnings;

use Manoc::DB::Result::HWAsset;
use Carp;

sub unused_devices {
    my ($self) = @_;

    my $used_asset_ids = $self->result_source->schema->resultset('Device')->search(
        {
            'subquery.decommissioned' => 0,
            'subquery.hwasset_id'     => { -is_not => undef }
        },
        {
            alias => 'subquery',
        }
    )->get_column('hwasset_id');

    my $me = $self->current_source_alias;
    my $assets = $self->search(
        {
            "$me.type"     => Manoc::DB::Result::HWAsset::TYPE_DEVICE,
            "$me.location" => { '!=' => Manoc::DB::Result::HWAsset::LOCATION_DECOMMISSIONED },
            "$me.id"       => {
                -not_in => $used_asset_ids->as_query,
            }
        },
    );

    return $assets;
}

1;
