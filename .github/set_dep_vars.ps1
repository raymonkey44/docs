Set-StrictMode -version latest;
$ErrorActionPreference = "Stop";
$VerbosePreference="Continue";
#$input | foreach {
	#write-host "INPUT LINE $_"
#}
echo it is $env:DEPS


$arr=($env:DEPS).split()
$cnt=1
foreach ($dep in $arr) {
	if ($dep){

		echo "Dep$($cnt++)Name=$dep" >> $env:GITHUB_OUTPUT
	}
}