#!/usr/bin/perl
use WWW::Mechanize ();
use HTTP::CookieJar::LWP ();
use IO::Socket::SSL;
use Time::HiRes qw ( sleep );
use strict;
use warnings;

my($thread, $cookie, $lastpage) = @ARGV;
our $base    = "www.kastenwagenforum.de";
our $threads = "forum/threads";
my @range = ( 0.5 .. 15.0 );

if (!$lastpage) {
  die "Usage: $0 <thread.threadid> <value of xf_session cookie> <last-page-number>\n";
}

my $head = qq~
<!DOCTYPE html>
<html lang="de-DE">
<head>
	<meta charset="utf-8" />
	<meta http-equiv="X-UA-Compatible" content="IE=Edge,chrome=1" />
	<meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type="text/css">
       .avatarHolder    { display: none; }
       .extraUserInfo   { display: none; }
       .signature       { display: none; }
       .report          { display: none; }
       .publicControls  { display: none; }
       .report          { display: none; }
       .authorEnd       { display: none; }
       .editDate        { display: none; }
       .LikeText        { display: none; }
       .attachmentInfo  { display: none; }
       .AttributionLink { display: none; }
       .quoteExpand     { display: none; }
       .message         { border-bottom: 1px solid #c4c4c4; }
       .quote           { border-left: 5px solid #ccc; padding-left: 5px; }
       .quote .image    { display: none; }
    </style>
</head>
<body>
~;

my $foot = "</body></html>";

$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;

my $jar = HTTP::CookieJar::LWP->new;
$jar->add("https://${base}/", "xf_session=${cookie}; Path=/; Domain=${base}");
my $mech = WWW::Mechanize->new(autocheck => 1, cookie_jar => $jar);
$mech->agent_alias( 'Windows IE 6' );

my $uri = "https://${base}/${threads}/${thread}";

open my $index,">:utf8","index.html" or die $!;
print $index $head;

foreach my $page (1 .. $lastpage) {
  debug("fetching ${uri}/page-${page}");
  $mech->get( "${uri}/page-${page}" );
  my $content = $mech->content();

  # only use visible part
  $content =~ s/.+?<form[^>]+?>//s;
  $content =~ s/<\/form>.*//s;

  # remove extranous whitespace
  $content =~ s/^\s*$//gm;

  # Download linked image and embed it directly:
  $content =~ s/(<a href=.+?<\/a>)/imager($1)/seg;

  # save
  print $index $content;

  # save to singular file as well
  open my $pg,">:utf8","${page}.html" or die $!;
  print $pg $head;
  print $pg $content;
  print $pg $foot;
  close $pg;

  # simulate idling
  debug("done with page ${page}.");
  waitms() unless($page == $lastpage);
}

print $index $foot;
close $index;



sub imager {
  # extract images from image links
  my $html = shift;

  # turn to oneliner
  $html =~ s/\R//gs;

  if ($html =~ /(attachments\/.+?\/)/) {
    # embedded or attached attachment
    my $imguri = $1;
    my $img    = $imguri;
    $img =~ s/\/$//;
    $img =~ s/.*\///;

    my $suffix = 'jpg';
    if ($img =~ /png/) {
      $suffix = 'png';
    }
    $img = "${img}.${suffix}";

    if (! -e $img) {
      debug("   fetchging https://${base}/forum/$imguri");
      $mech->get("https://${base}/forum/$imguri");
      open I, ">$img";
      print I $mech->content;
      close I;
    }

    return "<img class=\"image\" src=\"$img\"/>";
  }
  elsif ($html =~ /(\d{2}\.\d{2}\.\d{4} um \d{2}:\d{2} Uhr)/) {
    # post date
    return "<b>$1</b>";
  }
  else {
    # ordinary other link
    return $html;
  }
}

sub waitms {
  # wait a little
  my $wait = $range[rand(@range)];
  debug("=> waiting $wait ...");
  sleep $wait;
}

sub debug {
  my $msg = shift;
  print STDERR "$msg\n";
}
