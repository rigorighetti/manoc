# Copyright 2015 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.

# A frontend for CISCO IOS devices still using telnet

package Manoc::Manifold::Telnet::IOS;

use Moose;

with 'Manoc::ManifoldRole::Base';
with 'Manoc::ManifoldRole::NetDevice';
with 'Manoc::ManifoldRole::FetchConfig';

with 'Manoc::Logger::Role';

use Try::Tiny;
use Net::Telnet::Cisco;
use Regexp::Common qw /net/;

has 'session' => (
    is     => 'ro',
    isa    => 'Object',
    writer => '_set_session',
);

has 'username' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder => '_build_username',
);

has 'password' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    lazy     => 1,
    builder  => '_build_password',
);

has 'enable_password' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder => '_build_enable_password',
);

sub _build_username {
    my $self = shift;

    return $self->credentials->{username};
}

sub _build_password {
    my $self = shift;
    return $self->credentials->{password} || '';
}

sub _build_eable_password {
    my $self = shift;
    return $self->credentials->{password2} || '';
}

sub connect {
    my $self = shift;

    my $host = self->host;

    #Connect and login in enable mode
    try {
        my $session = Net::Telnet::Cisco->new(
            Host    => $host,
            Timeout => 20,
        );

        $session->login( $self->username, $self->password ) or
            return undef;

        if ( $self->enable_password ) {
            my $enabled = $session->enable( $self->enable_password );
            if ( !$enabled ) {
                $self->log->error("Cannot enable session");
                return undef;
            }
        }
        $self->_set_session($session);
        return 1;
    }
    catch {
        $self->log->error("Error connecting to $host: $@");
        return undef;
    }
}

sub _build_arp_table {
    my $self    = shift;
    my $session = $self->session;

    my %arp_table;

    try {
        my @data = $self->cmd('show ip arp');
        chomp @data;

        # arp entries use to have this format
        # Internet  10.1.2.3   11   00aa.bbcc.ddee  ARPA Interface/0.1
        foreach my $line (@data) {
            $line =~ m/^Internet/ or next;

            my @fields = split m/\s+/, $line;
            $arp_table{ $fields[1] } = $fields[3];
        }

        return \%arp_table;
    };

    $self->log->error('Error fetching configuration');
    return undef;
}

sub _build_configuration {
    my $self;

    my $session = $self->session;

    try {
        my @data = $session->cmd("show running");
        chomp @data;

        return join( @data, '\n' );
    };
    $self->log->error('Error fetching configuration: $@');
    return undef;
}

sub close {
    shift->session->close();
}

no Moose;
__PACKAGE__->meta->make_immutable;

# Local Variables:
# mode: cperl
# indent-tabs-mode: nil
# cperl-indent-level: 4
# cperl-indent-parens-as-block: t
# End:
