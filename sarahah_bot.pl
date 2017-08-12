#!/usr/bin/perl 

use strict;
use warnings;
use WWW::Curl::Easy;
use WWW::Curl::Form;

{
	my $curl = WWW::Curl::Easy->new;
	my $user = shift;
	my $message=shift;
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
	}
	else
	{
		print "curl error $retCode not handled\n";
		exit 1;
	}

	my $cookieString='Cookie:';
	foreach my $key(keys %cookies)
	{
		$cookieString .= " $key=$cookies{$key};";
	}
	$cookieString =~ s/;$//;

	my $curlForm=WWW::Curl::Form->new;
	$curlForm->formadd('__RequestVerificationToken', $verificationToken);
	$curlForm->formadd('userId', $userId);
	$curlForm->formadd('text', $message);

	$curl=WWW::Curl::Easy->new; #create a new handle for the post.
	$curl->setopt(CURLOPT_URL,"https://$user.sarahah.com/Messages/SendMessage");
	$curl->setopt(CURLOPT_WRITEDATA, \$respBody);
	$curl->setopt(CURLOPT_HEADERDATA, \$respHeaders);
	$curl->setopt(CURLOPT_HTTPHEADER, [$cookieString, "Origin: https://$user.sarahah.com", 
		'Accept: */*', "Referer: https://$user.sarahah.com/", 'X-Requested-With: XMLHttpRequest']);
	$curl->setopt(CURLOPT_POST,1);
	$curl->setopt(CURLOPT_HTTPPOST,$curlForm);
	$retCode = $curl->perform;

	if($retCode == 0)
	{
		$respCode=$curl->getinfo(CURLINFO_HTTP_CODE);
		if($respCode != 200)
		{
			print "Unhandled HTTP $respCode\n";
			print "Response Headers:\n$respHeaders\n";
		}

	}
	else
	{
		print "curl error $retCode not handled\n"
	}
}

