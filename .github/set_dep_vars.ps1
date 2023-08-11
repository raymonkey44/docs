Set-StrictMode -version latest;
$ErrorActionPreference = "Stop";
$VerbosePreference="Continue";

$arr=($env:DEPS).split()
$cnt=1
foreach ($dep in $arr) {
	if ($dep){
		Write-Host Running "Dep$($cnt)Name=$dep >>  $env:GITHUB_OUTPUT"
		echo "Dep$($cnt)Name=$dep" >> $env:GITHUB_OUTPUT
		$cnt++
		
	}
}
cat $env:GITHUB_OUTPUT