Set-StrictMode -Version Latest
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location "$here\.."
docker exec -it ros2_bridge bash
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
