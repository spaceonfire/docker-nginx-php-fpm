#!/usr/bin/env php
<?php
function setupSsmtpConf() {
	$ssmtp = $_ENV['SSMTP_URI'];

	if (!$ssmtp) {
		echo 'SSMTP_URI env variable is empty. Skip ssmtp setup...' . "\n";
		exit(0);
	}

	$ssmtp = parse_url($ssmtp);

	if (!$ssmtp['scheme'] || !$ssmtp['host']) {
		echo 'Wrong URI format for SSMTP_URI!' . "\n";
		exit(1);
	}

	$conf = [
		'FromLineOverride=YES',
	];

	$conf[] = 'mailhub=' . $ssmtp['host'] . ($ssmtp['port'] ? ':' . $ssmtp['port'] : '');

	if ($ssmtp['user']) {
		$conf[] = 'AuthUser=' . $ssmtp['user'];
	}

	if ($ssmtp['pass']) {
		$conf[] = 'AuthPass=' . $ssmtp['pass'];
	}

	if ($_ENV['DOMAIN']) {
		$conf[] = 'RewriteDomain=' . $_ENV['DOMAIN'];
	}

	if ($_ENV['SSMTP_DEBUG']) {
		$conf[] = 'Debug=YES';
	}

	if (stripos($ssmtp['scheme'], 'tls') !== false) {
		$conf[] = 'UseTLS=YES';

		if ($_ENV['SSMTP_NO_STARTTLS']) {
			$conf[] = 'TLS_CA_File=/etc/ssl/certs/ca-certificates.crt';
		} else {
			$conf[] = 'UseSTARTTLS=YES';
		}
	}

	$conf[] = '';
	$conf = implode("\n", $conf);
	file_put_contents('/etc/ssmtp/ssmtp.conf', $conf, FILE_APPEND | LOCK_EX);
}

function setupRevAliases() {
	if (!$_ENV['SSMTP_DEFAULT_FROM']) {
		echo 'SSMTP_DEFAULT_FROM env variable is empty. Skip ssmtp revaliases setup...' . "\n";
		exit(0);
	}

	exec('cut -d: -f1 /etc/passwd', $users, $tmp);

	if ($tmp !== 0) {
		echo 'Cannot get system users list';
		exit($tmp);
	}

	unset($tmp);

	$ssmtp = parse_url($_ENV['SSMTP_URI']);

	$mailhub = $ssmtp['host'] . ($ssmtp['port'] ? ':' . $ssmtp['port'] : '');

	$users = array_map(static function ($user) use ($mailhub) {
		return $user . ':' . $_ENV['SSMTP_DEFAULT_FROM'] . ':' . $mailhub;
	}, $users);

	file_put_contents(
		'/etc/ssmtp/revaliases',
		implode("\n", $users),
		FILE_APPEND | LOCK_EX
	);
}

setupRevAliases();
setupSsmtpConf();
