use strict;
use warnings;
use Test::More tests => 12;
use Parse::Apache::ServerStatus;

my $status1 = <<EOT;
Server Version: Apache/1.3.34 (Ubuntu)<br>
Server Built: Mar  8 2007 00:01:35<br>
<hr>
Current Time: Saturday, 13-Oct-2007 20:41:00 CEST<br>
Restart Time: Saturday, 13-Oct-2007 20:30:09 CEST<br>
Parent Server Generation: 0 <br>
Server uptime:  10 minutes 51 seconds<br>
Total accesses: 239409 - Total Traffic: 1.7 MB<br>
CPU Usage: u.32 s.21 cu0 cs0 - .0814% CPU load<br>
368 requests/sec - 2733 B/second - 7 B/request<br>

1 requests currently being processed, 32 idle servers
<PRE>___________W____........._________________......................
................................................................
................................................................
</PRE>
Scoreboard Key: <br>
"<B><code>_</code></B>" Waiting for Connection, 
"<B><code>S</code></B>" Starting up, 
"<B><code>R</code></B>" Reading Request,<BR>
"<B><code>W</code></B>" Sending Reply, 
"<B><code>K</code></B>" Keepalive (read), 
"<B><code>D</code></B>" DNS Lookup,<BR>
"<B><code>L</code></B>" Logging, 
"<B><code>G</code></B>" Gracefully finishing, 
"<B><code>.</code></B>" Open slot with no current process<P>
<P>
<p>
EOT

my $status2 = <<EOT;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<html><head>
<title>Apache Status</title>
</head><body>
<h1>Apache Server Status for localhost</h1>

<dl><dt>Server Version: Apache/2.2.3 (Debian) mod_fastcgi/2.4.2 mod_ssl/2.2.3 OpenSSL/0.9.8c</dt>
<dt>Server Built: Jun 17 2007 20:24:06
</dt></dl><hr /><dl>
<dt>Current Time: Saturday, 13-Oct-2007 19:30:20 CEST</dt>
<dt>Restart Time: Thursday, 11-Oct-2007 18:00:42 CEST</dt>
<dt>Parent Server Generation: 2</dt>
<dt>Server uptime:  2 days 1 hour 29 minutes 38 seconds</dt>
<dt>Total accesses: 845 - Total Traffic: 3.8 MB</dt>
<dt>CPU Usage: u.26 s.06 cu0 cs0 - .00018% CPU load</dt>
<dt>.00474 requests/sec - 22 B/second - 4758 B/request</dt>
<dt>1 requests currently being processed, 9 idle workers</dt>
</dl><pre>_.__.__W__.__...................................................
................................................................
................................................................
................................................................
</pre>
<p>Scoreboard Key:<br />
"<b><code>_</code></b>" Waiting for Connection, 
"<b><code>S</code></b>" Starting up, 
"<b><code>R</code></b>" Reading Request,<br />
"<b><code>W</code></b>" Sending Reply, 
"<b><code>K</code></b>" Keepalive (read), 
"<b><code>D</code></b>" DNS Lookup,<br />
"<b><code>C</code></b>" Closing connection, 
"<b><code>L</code></b>" Logging, 
"<b><code>G</code></b>" Gracefully finishing,<br /> 
"<b><code>I</code></b>" Idle cleanup of worker, 
"<b><code>.</code></b>" Open slot with no current process</p>
<p />
EOT

my $prs = new Parse::Apache::ServerStatus;

# testing apache v1
my ($p, $ta, $tt, $r, $i, $rest) = $status1 =~ $prs->{rx}->{1};
ok($p == 0, "parents apache");
ok($ta == 239409, "total accesses apache");
ok($tt == 1.7, "total traffic apache");
ok($r == 1, "requests apache");
ok($i == 32, "idles apache");
ok($rest, "rest apache");

# testing apache v2
($p, $ta, $tt, $r, $i, $rest) = $status2 =~ $prs->{rx}->{2};
ok($p == 2, "parents apache2");
ok($ta == 845, "total accesses apache2");
ok($tt == 3.8, "total traffic apache2");
ok($r == 1, "requests apache2");
ok($i == 9, "idles apache2");
ok($rest, "rest apache2");
