Set-StrictMode -Version Latest
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location "$here\.."
docker compose down -v
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
