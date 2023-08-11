Set-StrictMode -version latest;
$ErrorActionPreference = "Stop";
$VerbosePreference="Continue";
#$input | foreach {
	#write-host "INPUT LINE $_"
#}
echo it is $env:DEPS


$arr=($env:DEPS).split()
$arr | foreach {WriteHost 'ITS: ' + $_}