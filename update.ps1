cd c:\repo\WIN64LinuxBuild
c:\linux\cp -r -t c:\temp\gh_test\ *.sh *.ini *.ps1 build patches vs_debug_help .github 
cd c:\temp\gh_test
git status
git add -u .
git commit -m "r"
