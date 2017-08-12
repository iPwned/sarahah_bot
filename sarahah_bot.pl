#!/usr/bin/perl 

use strict;
use warnings;
use WWW::Curl::Easy;
use Data::Dumper;

{
	my $curl = WWW::Curl::Easy->new;
	my $user = shift;
	my ($respHeaders, $respBody, $respCode, $retCode);
	my (@splitHeaders,@lines);
	my %cookies;
	my $userId;
	my $verificationToken;
	

	$curl->setopt(CURLOPT_URL, "https://$user.sarahah.com");
	$curl->setopt(CURLOPT_WRITEDATA, \$respBody);
	$curl->setopt(CURLOPT_HEADERDATA, \$respHeaders);
	$retCode = $curl->perform;

	if($retCode == 0)
	{
		$respCode=$curl->getinfo(CURLINFO_HTTP_CODE);
		unless($respCode == 200)
		{
			print "HTTP Response $respCode not handled\n";
			exit 1;
		}

		@splitHeaders = split /\n/, $respHeaders;
		foreach my $header(@splitHeaders)
		{
			if($header =~ m/Set-Cookie/)
			{
				$header =~ s/\s*Set-Cookie:\s*//;
				my ($cookieName, $cookieVal) = split /=/,$header;
				$cookies{$cookieName}=$cookieVal;
			}
		}

		@lines = split /\n/, $respBody;
		foreach my $line(@lines)
		{
			if($line =~ m/"RecipientId"\s+type="hidden"\s+value="(.*)"/)
			{
				$userId=$1;
			}
			elsif($line =~ m/"__RequestVerificationToken"\s+type="hidden"\s+value="(.*)"/)
			{
				$verificationToken=$1;
			}
		}
		print "user id=$userId\n";
		print "verification token=$verificationToken\n";
	}
	else
	{
		print "curl error $retCode not handled\n";
		exit 1;
	}
}

