#!/usr/bin/perl 

use strict;
use warnings;
use WWW::Curl::Easy;

{
	my $curl = WWW::Curl::Easy->new;
	my $respBody;
	my $user = shift;
	my $retCode;

	$curl->setopt(CURLOPT_HEADER, 1);
	$curl->setopt(CURLOPT_URL, "https://$user.sarahah.com");
	$curl->setopt(CURLOPT_WRITEDATA, \$respBody);
	$retCode = $curl->perform;

	if($retCode == 0)
	{
		print "curl call succeeded\n";

		my $respCode=$curl->getinfo(CURLINFO_HTTP_CODE);
		print "HTTP Response code: $respCode\n";
		print "Response:\n$respBody\n";
	}
	else
	{
		print "curl error $retCode\n";
	}
}

