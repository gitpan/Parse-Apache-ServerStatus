=head1 NAME

Parse::Apache::ServerStatus - Simple module to parse apache's server-status.

=head1 SYNOPSIS

    use Parse::Apache::ServerStatus;

    my $prs = new Parse::Apache::ServerStatus;

    $prs->request(
       url     => 'http://localhost/server-status',
       timeout => 30
    ) or die $prs->errstr;

    my $stat = $prs->parse or die $prs->errstr;

    # or both in one step

    my $stat = $prs->get(
       url     => 'http://localhost/server-status',
       timeout => 30
    ) or die $prs->errstr;

=head1 DESCRIPTION

This module parses the content of apache's server-status and countes the
current status by each process. It works nicely with apache versions 1.3
and 2.x.

=head1 METHODS

=head2 new()

Call C<new()> to create a new Parse::Apache::ServerStatus object.

=head2 request()

This method excepts one or two arguments: C<url> and C<timeout>. It requests the url
and safes the content into the object. The option C<timeout> is set to 180 seconds if
it is not set.

=head2 parse()

Call C<parse()> to parse the server status. This method returns a hash reference with
the parsed content. There are diffenrent keys that contains the following counts:

   r    Requests currenty being processed
   i    Idle workers
   p    Parents
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

It's possible to call C<parse()> with the content as argument.

    my $stat = $prs->parse($content);

If no argument is passed then C<parse()> looks into the object for the content that is
stored by C<request()>.

=head2 get()

Call C<get()> to C<request()> and C<parse()> in one step. It except the same options like
C<request()> and returns the hash reference that is returned by C<parse()>.

=head2 content()

Call C<content()> if you need the full content of server-status.

    my $content = $prs->content;

=head2 errstr()

C<errstr()> contains the error string if the requests fails.

=head1 OPTIONS

There are only two options: C<url> and C<timeout>.

Set C<url> with the complete url like C<http://localhost/server-status>.
There is only http supported, not https or other protocols.

Set C<timeout> to define the time in seconds to abort the request if there is no
response. The default is set to 180 secondes if the options isn't set.

=head1 EXAMPLE CONFIGURATION FOR APACHE

This is just an example to activate the handler server-status for localhost.

    <Location /server-status>
        SetHandler server-status
        Order Deny,Allow
        Deny from all
        Allow from localhost
    </Location>

=head1 DEPENDENCIES

    Carp
    LWP::UserAgent
    Params::Validate

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

our $VERSION = '0.01';

use strict;
use warnings;
use Carp qw(croak);
use LWP::UserAgent;
use Params::Validate;

sub new {
   my $class = shift;
   my %self  = ();

   $self{rx}{1} = qr{
      Parent\s+Server\s+Generation:\s+(\d+)\s+<br>.+
      (\d+)\s+requests\s+currently\s+being\s+processed,\s+(\d+)\s+idle\s+servers.+?
      <PRE>([_SRWKDCLGI.\n]+)
      </PRE>
   }xs;

   $self{rx}{2} = qr{
      <dt>Parent\s+Server\s+Generation:\s+(\d+)</dt>.+
      <dt>(\d+)\s+requests\s+currently\s+being\s+processed,\s+(\d+)\s+idle\s+workers</dt>.+
      </dl><pre>([_SRWKDCLGI.\n]+)
      </pre>
   }xs;

   $self{ua} = LWP::UserAgent->new();
   $self{ua}->protocols_allowed(['http']);

   return bless \%self, $class;
}

sub get {
   my $self = shift;
   $self->request(@_) or return undef;
   return $self->parse;
}

sub request {
   my $self = shift;

   my %opts = Params::Validate::validate(@_, {
      url => {
         type => Params::Validate::SCALAR,
         regex => qr{^http://.+},
      },
      timeout => {
         type => Params::Validate::SCALAR,
         regex => qr/^\d+$/,
         default => 180,
      },
   });

   $self->{ua}->timeout($opts{timeout});
   my $response = $self->{ua}->get($opts{url});

   return $self->_raise_error($response->status_line())
      unless $response->is_success();

   $self->{content} = $response->content();

   return $self->{content} ? 1 : undef;
}

sub content {
   my $self = shift;
   return $self->{content};
}

sub parse {
   my $self    = shift;
   my $content = $_[0] ? shift : $self->{content};
   $self->_raise_error("no content received") unless $content;
   my $regexes = $self->{rx};
   my %data    = map { $_ => 0 } qw(r i p _ S R W K D C L G I .);

   my ($version) = $content =~ m{Server\s+Version:\s+Apache/(\d)};

   return $self->_raise_error("unable to match the server version of apache")
      unless $version;

   return $self->_raise_error("apache/$version is not supported")
      unless exists $regexes->{$version};

   my $rest = ();

   ($data{p}, $data{r}, $data{i}, $rest) =
      $content =~ $regexes->{$version};

   $rest =~ s/\n//g;
   $data{$_}++ for (split //, $rest);

   return \%data;
}

sub errstr { return $__PACKAGE__::errstr }

#
# private stuff
#

sub _raise_error {
   my $self   = shift;
   my $class  = ref($self);
   my $errstr = shift;
   $__PACKAGE__::errstr = $errstr || '';
   return undef;
}

1;
