# Copyright 2011 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.

package Manoc::DataDumper::Converter::v2;

use Moose;
use Data::Dumper;
use Manoc::Utils::IPAddress qw(padded_ipaddr check_addr);
extends 'Manoc::DataDumper::Converter::Base';

# Convert Ip addresses in zero-padded ip addresses
sub _upgrade_ipcolumn {
    my ( $col_name, $data ) = @_;
    my ( $i, $ip );
    return 0 if ( !defined($data) );
    return 0 if ( !defined($col_name) );

    for ( $i = 0; $i < scalar( @{$data} ); $i++ ) {
        next if ( !defined( $data->[$i]->{$col_name} ) );
        $ip = padded_ipaddr( $data->[$i]->{$col_name} )
            if ( check_addr( $data->[$i]->{$col_name} ) );
        $data->[$i]->{$col_name} = $ip;
    }
}

sub upgrade_devices {
    my ( $self, $data ) = @_;
    $self->log->debug("Start converting devices...");
    _upgrade_ipcolumn( "id", $data );
}

sub upgrade_uplinks {
    my ( $self, $data ) = @_;
    $self->log->debug("Start converting uplinks...");
    _upgrade_ipcolumn( "device", $data );
}

sub upgrade_arp {
    my ( $self, $data ) = @_;
    $self->log->debug("Start converting arp entries...");
    _upgrade_ipcolumn( "ipaddr", $data );
}

sub upgrade_mat {
    my ( $self, $data ) = @_;
    $self->log->debug("Start converting mat entries...");
    _upgrade_ipcolumn( "device", $data );
}

sub upgrade_ip_notes {
    my ( $self, $data ) = @_;
    $self->log->debug("Start converting ip_notes entries...");
    _upgrade_ipcolumn( "ipaddr", $data );
}

sub upgrade_win_hostname {
    my ( $self, $data ) = @_;
    $self->log->debug("Start converting win_hostname entries...");
    _upgrade_ipcolumn( "ipaddr", $data );
}

sub upgrade_win_logon {
    my ( $self, $data ) = @_;
    $self->log->debug("Start converting win_log entries...");
    _upgrade_ipcolumn( "ipaddr", $data );
}

sub upgrade_dhcp_reservation {
    my ( $self, $data ) = @_;
    $self->log->debug("Start converting dhcp_reservation entries...");
    _upgrade_ipcolumn( "ipaddr", $data );
}

sub upgrade_dhcp_lease {
    my ( $self, $data ) = @_;
    $self->log->debug("Start converting dhcp_lease entries...");
    _upgrade_ipcolumn( "ipaddr", $data );
}

sub upgrade_ip_range {
    my ( $self, $data ) = @_;
    $self->log->debug("Start converting ip_range entries...");
    _upgrade_ipcolumn( "network",   $data );
    _upgrade_ipcolumn( "netmask",   $data );
    _upgrade_ipcolumn( "from_addr", $data );
    _upgrade_ipcolumn( "to_addr",   $data );
}

sub upgrade_if_status {
    my ( $self, $data ) = @_;
    $self->log->debug("Start converting if_status entries...");
    _upgrade_ipcolumn( "device", $data );
}

sub upgrade_if_notes {
    my ( $self, $data ) = @_;
    $self->log->debug("Start converting if_notes entries...");
    _upgrade_ipcolumn( "device", $data );
}

sub upgrade_cdp_neigh {
    my ( $self, $data ) = @_;
    my $i;
    $self->log->debug("Start converting cdp entries...");
    _upgrade_ipcolumn( "from_device", $data );

    for ( $i = 0; $i < scalar( @{$data} ); $i++ ) {
        next
            if ( !defined( $data->[$i]->{"to_device"} ) or
            $data->[$i]->{"to_device"} ne 'no-ip' );
        $data->[$i]->{"to_device"} = "0.0.0.0";
    }
    _upgrade_ipcolumn( "to_device", $data );
}

sub upgrade_ssid_list {
    my ( $self, $data ) = @_;
    $self->log->debug("Start converting ssid entries...");
    _upgrade_ipcolumn( "device", $data );
}

sub upgrade_dot11_assoc {
    my ( $self, $data ) = @_;
    $self->log->debug("Start converting  dot11_assoc entries...");
    _upgrade_ipcolumn( "device", $data );
    _upgrade_ipcolumn( "ipaddr", $data );
}

sub upgrade_dot11client {
    my ( $self, $data ) = @_;
    $self->log->debug("Start converting dot11client entries...");
    _upgrade_ipcolumn( "device", $data );
    _upgrade_ipcolumn( "ipaddr", $data );
}

sub upgrade_deleted_devices {
    my ( $self, $data ) = @_;
    $self->log->debug("Start converting dot11client entries...");
    _upgrade_ipcolumn( "ipaddr", $data );
}

sub upgrade_device_config {
    my ( $self, $data ) = @_;
    $self->log->debug("Start converting device configurations entries...");
    _upgrade_ipcolumn( "device", $data );
}

no Moose;    # Clean up the namespace.
__PACKAGE__->meta->make_immutable();
1;
