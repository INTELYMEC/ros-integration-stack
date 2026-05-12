Set-StrictMode -Version Latest
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location "$here\.."
docker exec -it robot_p3at_sim bash
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
