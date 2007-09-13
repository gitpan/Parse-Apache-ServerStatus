use strict;
use warnings;
use Test::More tests => 12;
use Parse::Apache::ServerStatus;

my $status1 = <<EOT;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<HTML><HEAD>
<TITLE>Apache Status</TITLE>
</HEAD><BODY>
<H1>Apache Server Status for localhost</H1>

Server Version: Apache/1.3.34 (Ubuntu)<br>
Server Built: Mar  8 2007 00:01:35<br>
<hr>
Current Time: Thursday, 13-Sep-2007 13:19:05 CEST<br>
Restart Time: Thursday, 13-Sep-2007 13:13:20 CEST<br>
Parent Server Generation: 1 <br>
Server uptime:  5 minutes 45 seconds<br>
Total accesses: 2 - Total Traffic: 3 kB<br>
CPU Usage: u0 s0 cu0 cs0<br>
.0058 requests/sec - 0 B/second - 0 B/request<br>

2 requests currently being processed, 7 idle servers
<PRE>_SRWKDCLGI.
_SRWKDCLGI.
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

<table border=0><tr><th>Srv<th>PID<th>Acc<th>M<th>CPU
<th>SS<th>Req<th>Conn<th>Child<th>Slot<th>Client<th>VHost<th>Request</tr>

<tr><td><b>0-1</b><td>12604<td>0/0/2<td><b>W</b>
<td>0.00<td>3<td>0<td>0.0<td>0.00<td>0.000
<td nowrap><font face="Arial,Helvetica" size="-1">127.0.0.1</font><td nowrap><font face="Arial,Helvetica" size="-1">localhost</font><td nowrap><font face="Arial,Helvetica" size="-1">GET /server-status HTTP/1.1</font></tr>

</table>
 <hr> <table>
 <tr><th>Srv<td>Child Server number - generation
 <tr><th>PID<td>OS process ID
 <tr><th>Acc<td>Number of accesses this connection / this child / this slot
 <tr><th>M<td>Mode of operation
 <tr><th>CPU<td>CPU usage, number of seconds
 <tr><th>SS<td>Seconds since beginning of most recent request
 <tr><th>Req<td>Milliseconds required to process most recent request
 <tr><th>Conn<td>Kilobytes transferred this connection
 <tr><th>Child<td>Megabytes transferred this child
 <tr><th>Slot<td>Total megabytes transferred this slot
 </table>
<HR>
<ADDRESS>Apache/1.3.34 Server at localhost Port 80</ADDRESS>
</BODY></HTML>
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
<dt>Current Time: Thursday, 13-Sep-2007 13:07:35 CEST</dt>
<dt>Restart Time: Thursday, 13-Sep-2007 13:07:31 CEST</dt>
<dt>Parent Server Generation: 1</dt>
<dt>Server uptime:  3 seconds</dt>
<dt>Total accesses: 2 - Total Traffic: 3 kB</dt>
<dt>CPU Usage: u0 s0 cu0 cs0<dt>0 requests/sec - 0 B/second - </dt>
<dt>2 requests currently being processed, 7 idle workers</dt>
</dl><pre>_SRWKDCLGI.
_SRWKDCLGI.
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


<table border="0"><tr><th>Srv</th><th>PID</th><th>Acc</th><th>M</th><th>CPU
</th><th>SS</th><th>Req</th><th>Conn</th><th>Child</th><th>Slot</th><th>Client</th><th>VHost</th><th>Request</th></tr>

<tr><td><b>0-0</b></td><td>30976</td><td>0/0/0</td><td><b>W</b>
</td><td>0.00</td><td>0</td><td>24285699</td><td>0.0</td><td>0.00</td><td>0.00
</td><td>87.230.108.20</td><td nowrap>www.bloonix.de</td><td nowrap>GET /server-status HTTP/1.1</td></tr>

</table>
 <hr /> <table>
 <tr><th>Srv</th><td>Child Server number - generation</td></tr>
 <tr><th>PID</th><td>OS process ID</td></tr>
 <tr><th>Acc</th><td>Number of accesses this connection / this child / this slot</td></tr>
 <tr><th>M</th><td>Mode of operation</td></tr>
<tr><th>CPU</th><td>CPU usage, number of seconds</td></tr>
<tr><th>SS</th><td>Seconds since beginning of most recent request</td></tr>
 <tr><th>Req</th><td>Milliseconds required to process most recent request</td></tr>
 <tr><th>Conn</th><td>Kilobytes transferred this connection</td></tr>
 <tr><th>Child</th><td>Megabytes transferred this child</td></tr>
 <tr><th>Slot</th><td>Total megabytes transferred this slot</td></tr>
 </table>
<hr>
<table cellspacing=0 cellpadding=0>
<tr><td bgcolor="#000000">
<b><font color="#ffffff" face="Arial,Helvetica">SSL/TLS Session Cache Status:</font></b>
</td></tr>
<tr><td bgcolor="#ffffff">
cache type: <b>SHMCB</b>, shared memory: <b>512000</b> bytes, current sessions: <b>0</b><br>sub-caches: <b>32</b>, indexes per sub-cache: <b>133</b><br>index usage: <b>0%</b>, cache usage: <b>0%</b><br>total sessions stored since starting: <b>0</b><br>total sessions expired since starting: <b>0</b><br>total (pre-expiry) sessions scrolled out of the cache: <b>0</b><br>total retrieves since starting: <b>0</b> hit, <b>0</b> miss<br>total removes since starting: <b>0</b> hit, <b>0</b> miss<br></td></tr>
</table>
</body></html>
EOT

my $prs = new Parse::Apache::ServerStatus;

# testing apache v1
my ($p, $ta, $tt, $r, $i, $rest) = $status1 =~ $prs->{rx}->{1};
ok($p == 1, "parents apache");
ok($ta == 2, "total accesses apache");
ok($tt == 3, "total traffix apache");
ok($r == 2, "requests apache");
ok($i == 7, "idles apache");
ok($rest, "rest apache");

# testing apache v2
($p, $ta, $tt, $r, $i, $rest) = $status2 =~ $prs->{rx}->{2};
ok($p == 1, "parents apache2");
ok($r == 2, "requests apache2");
ok($ta == 2, "total accesses apache2");
ok($tt == 3, "total traffix apache2");
ok($i == 7, "idles apache2");
ok($rest, "rest apache2");
