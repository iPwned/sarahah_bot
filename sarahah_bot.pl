#!/usr/bin/perl 

use strict;
use warnings;
use WWW::Curl::Easy;

{
	my $curl = WWW::Curl::Easy->new;
	my $user = shift;
	my ($respHeaders, $respBody, $respCode, $retCode);

	$curl->setopt(CURLOPT_URL, "https://$user.sarahah.com");
	$curl->setopt(CURLOPT_WRITEDATA, \$respBody);
	$curl->setopt(CURLOPT_HEADERDATA, \$respHeaders);
	$retCode = $curl->perform;

	if($retCode == 0)
	{
		print "curl call succeeded\n";

		$respCode=$curl->getinfo(CURLINFO_HTTP_CODE);
		print "HTTP Response code: $respCode\n";
		print "Headers:\n$respHeaders\n";
		print "Response:\n$respBody\n";
	}
	else
	{
		print "curl error $retCode\n";
	}
}

