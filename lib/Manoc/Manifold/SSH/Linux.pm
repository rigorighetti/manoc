# Copyright 2015 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.

package Manoc::Manifold::SSH::Linux;
use Moose;
with 'Manoc::ManifoldRole::SSH';

with 'Manoc::ManifoldRole::Base';
with 'Manoc::ManifoldRole::Host';

use Try::Tiny;

around '_build_username' => sub {
    my $orig = shift;
    my $self = shift;

    return $self->$orig() || 'root';
};


sub _build_boottime {
    my $self = shift;

    my $data = $self->cmd('cat /proc/uptime');
    my ( $seconds, undef ) = split /\s+/, $data;
    return time() - int($seconds);

}

sub _build_name {
    my $self = shift;
    return $self->cmd('uname -n');
}

sub _build_os {
    my $self = shift;
    return $self->cmd('uname -s');

    #if ( -e '/etc/debian_version' ) { $r = 'Debian'; }
    #if ( -e '/etc/gentoo-release' ) { $r = 'Gentoo'; }
    #if ( -e '/etc/fedora-release' ) { $r = 'Fedora'; }
    #if ( -e '/etc/redhat-release' ) { $r = 'RedHat'; }
    #if ( -e '/etc/SuSE-release' )   { $r = 'SuSE'; }
}

sub _build_os_ver {
    my $self = shift;

    return $self->cmd('uname -r');
}

sub _build_model {
    my $self = shift;

    my $model = $self->cmd("/bin/uname -m");
    return $model;
}


sub _build_cpu_count {
    my $self = shift;

    return $self->cpuinfo->{count} || 1;
}

sub _build_cpu_model {
    my $self = shift;

    return $self->cpuinfo->{model};
}

has cpuinfo => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    builder => '_build_cpuinfo'
);

sub _build_cpuinfo {
    my $self = shift;

    my @data;
    try {
        @data = $self->cmd('/bin/cat /proc/cpuinfo');
    }
    catch {
        $self->log->error( 'Error fetching cpuinfo: ', $self->get_error );
    };

    my $count = 0;
    my $model = 'Unknwown';

    foreach my $line (@data) {
        $count++     if $line =~ /processor\s+:\s+(\d+)/;
        $model = $1  if $line =~ /model name\s+:\s+(.+?)$/;
    }

    return {
        count => $count,
        model => $model
    };
}


sub _build_arp_table {
    my $self = shift;

    my %arp_table;
    my @data;
    try {
        @data = $self->cmd('/sbin/arp -n');

    }
    catch {
        $self->log->error( 'Error fetching arp table: ', $self->get_error );
        return undef;
    };

    # parse arp table
    # 192.168.1.1 ether 00:b6:aa:f5:bb:6e C eth1
    foreach my $line (@data) {
        if ( $line =~ /([0-9\.]+)\s+ether\s+([a-f0-9:]+)/ ) {
            my ( $ip, $mac ) = ( $1, $2 );
            $arp_table{$ip} = $mac;
        }
    }
    return \%arp_table;
}

sub _build_installed_sw {
    return [];
}

no Moose;
__PACKAGE__->meta->make_immutable;

# Local Variables:
# mode: cperl
# indent-tabs-mode: nil
# cperl-indent-level: 4
# cperl-indent-parens-as-block: t
# End:
