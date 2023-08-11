Set-StrictMode -version latest;
$ErrorActionPreference = "Stop";
$VerbosePreference="Continue";
$input | foreach {
	write-host "INPUT LINE $_"
}