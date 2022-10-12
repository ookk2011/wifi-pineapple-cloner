<?php

//download url:
// http://standards-oui.ieee.org/oui/oui.txt
// https://github.com/vcrhonek/hwdata/blob/master/oui.txt
$oui_download_url = 'http://standards-oui.ieee.org/oui/oui.txt';


echo "[+] Downloading updated oui.txt...\n";
$remote_file = file_get_contents($oui_download_url);
file_put_contents('oui.original', $remote_file);


echo "[+] Processing oui.txt...\n";
@unlink('oui.txt');

$flag	= '(base 16)';
$total	= 0;
$output	= [];
foreach (file('oui.original') as $line) {
	if (strpos($line, $flag) !== false){
		$total++;
		$parts = explode($flag, $line);
		$output[] = trim($parts[0]) . ucwords(mb_strtolower(trim($parts[1])));
	}
}

sort($output);
$output[] = '';

file_put_contents('oui.txt', implode("\n", $output));
unlink('oui.original');

echo "[+] Processing complete!\n";
echo "[*] File: oui.txt - Lines: {$total}\n";
