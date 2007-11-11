=head1 NAME

Parse::Apache::ServerStatus - Simple module to parse apache's server-status.

=head1 SYNOPSIS

    use Parse::Apache::ServerStatus;

    my $prs = Parse::Apache::ServerStatus->new(
       url     => 'http://localhost/server-status',
       timeout => 30
    );

    my $stat = $prs->get or die $prs->errstr;

    # or

    my $prs = Parse::Apache::ServerStatus->new;

    foreach my $url (@urls) {
        $prs->request(url => $url, timeout => 30) or die $prs->errstr;
        my $stat = $prs->parse or die $prs->errstr;
    }

    # or both in one step

    foreach my $url (@urls) {
        my $stat = $prs->get(url => $url, timeout => 30)
            or die $prs->errstr;
    }

=head1 DESCRIPTION

This module parses the content of apache's server-status and countes the
current status by each process. It works nicely with apache versions 1.3
and 2.x.

=head1 METHODS

=head2 new()

Call C<new()> to create a new Parse::Apache::ServerStatus object.

=head2 request()

This method requests the url and safes the content into the object.

=head2 parse()

Call C<parse()> to parse the server status. This method returns a hash reference with
the parsed content. There are diffenrent keys that contains the following counts:

    p    Parents
    r    Requests currenty being processed
    i    Idle workers
    _    Waiting for Connection
    S    Starting up
    R    Reading Request
    W    Sending Reply
    K    Keepalive (read)
    D    DNS Lookup
    C    Closing connection
    L    Logging
    G    Gracefully finishing
    I    Idle cleanup of worker
    .    Open slot with no current process

    The following keys are only available if extended server-status is activated.

    ta   Total accesses
    tt   Total traffic

It's possible to call C<parse()> with the content as argument.

    my $stat = $prs->parse($content);

If no argument is passed then C<parse()> looks into the object for the content that is
stored by C<request()>.

=head2 get()

C<get()> calls C<request()> and C<parse()> in one step. It's possible to set the options
C<url> and C<timeout> and it returns the hash reference that is returned by C<parse()>.

=head2 content()

Call C<content()> if you need the full content of server-status.

    my $content = $prs->content;

=head2 errstr()

C<errstr()> contains the error string if the requests fails.

=head2 ua()

Access the C<LWP::UserAgent> object if you want to set your own properties.

=head1 OPTIONS

There are only two options: C<url> and C<timeout>.

Set C<url> with the complete url like C<http://localhost/server-status>.
There is only http supported by default, not https or other protocols.

Set C<timeout> to define the time in seconds to abort the request if there is no
response. The default is set to 180 seconds if the options isn't set.

=head1 EXAMPLE

    use strict;
    use warnings;
    use Parse::Apache::ServerStatus;

    $|++;
    my $prs = Parse::Apache::ServerStatus->new(
        url => 'http://localhost/server-status',
        timeout => 10
    );
    my @order    = qw/p r i _ S R W K D C L G I . ta tt/;
    my $interval = 10;
    my $header   = 20;

    while ( 1 ) {
        print map { sprintf("%8s", $_) } @order;
        print "\n";
        for (my $i = 0; $i <= $header; $i++) {
            my $stat = $prs->get or die $prs->errstr;
            exists $stat->{tt} or $stat->{tt} = 'n/a';
            exists $stat->{ta} or $stat->{ta} = 'n/a';
            print map { sprintf("%8s", $stat->{$_}) } @order;
            print "\n";
            sleep($interval);
        }
    }

=head1 EXAMPLE CONFIGURATION FOR APACHE

This is just an example to activate the handler server-status for localhost.

    <Location /server-status>
        SetHandler server-status
        Order Deny,Allow
        Deny from all
        Allow from localhost
    </Location>

If you want to activate extended server-status you have to set

    Extended On

into the configuration file.

=head1 PREREQUISITES

    LWP::UserAgent
    Params::Validate
    Class::Accessor::Fast

=head1 EXPORTS

No exports.

=head1 REPORT BUGS

Please report all bugs to <jschulz.cpan(at)bloonix.de>.

=head1 AUTHOR

Jonny Schulz <jschulz.cpan(at)bloonix.de>.

=head1 COPYRIGHT

Copyright (C) 2007 by Jonny Schulz. All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

package Parse::Apache::ServerStatus;
our $VERSION = '0.05';

use strict;
use warnings;
use LWP::UserAgent;
use Params::Validate;
use base qw/Class::Accessor::Fast/;
__PACKAGE__->mk_accessors(qw/ua/);
use vars qw/$ERRSTR/;
$ERRSTR = defined;

sub new {
    my $class = shift || __PACKAGE__;
    my $self  = bless { }, $class;

    # EXAMPLE apache
    # Server Version: Apache/1.3.34 (Ubuntu)<br>
    # Server Built: Mar  8 2007 00:01:35<br>
    # <hr>
    # Current Time: Saturday, 13-Oct-2007 20:41:00 CEST<br>
    # Restart Time: Saturday, 13-Oct-2007 20:30:09 CEST<br>
    # Parent Server Generation: 0 <br>
    # Server uptime:  10 minutes 51 seconds<br>
    # Total accesses: 239409 - Total Traffic: 1.7 MB<br>
    # CPU Usage: u.32 s.21 cu0 cs0 - .0814% CPU load<br>
    # 368 requests/sec - 2733 B/second - 7 B/request<br>
    # 
    # 1 requests currently being processed, 32 idle servers
    # <PRE>___________W____........._________________......................
    # ................................................................
    # ................................................................
    # </PRE>

    $self->{rx}->{1} = qr{
        Parent\s+Server\s+Generation:\s+(\d+)\s+<br>.+?
        (?:(?:Total\s+accesses:\s+(\d+)\s+\-\s+Total\s+Traffic:\s+([0-9\.]+\s+[kmg]{0,1}B)<br>).+?|)
        (\d+)\s+requests\s+currently\s+being\s+processed,\s+(\d+)\s+idle\s+servers.+?
        <PRE>([_SRWKDCLGI.\n]+)
        </PRE>
    }xsi;

    # EXAMPLE apache2
    # <dl><dt>Server Version: Apache/2.2.3 (Debian) mod_fastcgi/2.4.2 mod_ssl/2.2.3 OpenSSL/0.9.8c</dt>
    # <dt>Server Built: Jun 17 2007 20:24:06
    # </dt></dl><hr /><dl>
    # <dt>Current Time: Saturday, 13-Oct-2007 19:30:20 CEST</dt>
    # <dt>Restart Time: Thursday, 11-Oct-2007 18:00:42 CEST</dt>
    # <dt>Parent Server Generation: 0</dt>
    # <dt>Server uptime:  2 days 1 hour 29 minutes 38 seconds</dt>
    # <dt>Total accesses: 845 - Total Traffic: 3.8 MB</dt>
    # <dt>CPU Usage: u.26 s.06 cu0 cs0 - .00018% CPU load</dt>
    # <dt>.00474 requests/sec - 22 B/second - 4758 B/request</dt>
    # <dt>1 requests currently being processed, 9 idle workers</dt>
    # </dl><pre>_.__.__W__.__...................................................
    # ................................................................
    # ................................................................
    # ................................................................
    # </pre>

    $self->{rx}->{2} = qr{
        <dt>Parent\s+Server\s+Generation:\s+(\d+)</dt>.+?
        (?:(?:Total\s+accesses:\s+(\d+)\s+\-\s+Total\s+Traffic:\s+([0-9\.]+\s+[kmg]{0,1}B)</dt>).+?|)
        <dt>(\d+)\s+requests\s+currently\s+being\s+processed,\s+(\d+)\s+idle\s+workers</dt>.+
        </dl><pre>([_SRWKDCLGI\.\s\n]+)
        </pre>
    }xsi;

    $self->ua(LWP::UserAgent->new);
    $self->ua->protocols_allowed(['http']);
    $self->_set(@_) if @_;
    return $self;
}

sub get {
    my $self = shift;
    $self->request(@_) or return undef;
    return $self->parse;
}

sub request {
    my $self = shift;
    $self->_set(@_) if @_;

    unless ($self->{url}) {
        return $self->_raise_error("missing mandatory option 'url'");
    }

    $self->ua->timeout($self->{timeout});
    my $response = $self->ua->get($self->{url});

    unless ($response->is_success()) {
        return $self->_raise_error($response->status_line());
    }

    $self->{content} = $response->content();
    return $self->{content} ? 1 : undef;
}

sub content { $_[0]->{content} }

sub parse {
    my $self = shift;
    my $content = $_[0] ? shift : $self->{content};

    unless ($content) {
        return $self->_raise_error("no content received");
    }

    my ($version) = $content =~ m{Server\s+Version:\s+Apache/(\d)};

    unless ($version) {
        return $self->_raise_error("unable to match the server version of apache");
    }

    my $regex = $self->{rx};
    my %data = map { $_ => 0 } qw/p r i _ S R W K D C L G I ./;

    unless (exists $regex->{$version}) {
        return $self->_raise_error("apache/$version is not supported");
    }

    my ($ta, $tt, $rest);
    ($data{p}, $ta, $tt, $data{r}, $data{i}, $rest) =
        $content =~ $regex->{$version};

    unless ($rest) {
        return $self->_raise_error("the content couldn't be parsed");
    }

    $data{$_}++ for (split //, $rest);

    if (defined $ta) {
        @data{qw/ta tt/} = ($ta, $tt);
    }

    return \%data;
}

sub errstr { $ERRSTR }

#
# private stuff
#

sub _set {
    my $self = shift;
    my %opts = Params::Validate::validate(@_, {
        url => {
            type  => Params::Validate::SCALAR,
            regex => qr{^http://.+},
        },
        timeout => {
            type    => Params::Validate::SCALAR,
            regex   => qr/^\d+\z/,
            default => 180,
        },
    });
    $self->{url} = $opts{url};
    $self->{timeout} = $opts{timeout};
}

sub _raise_error {
    $ERRSTR = $_[1];
    return undef;
}

1;
