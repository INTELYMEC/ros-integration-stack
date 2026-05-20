Set-StrictMode -Version Latest
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location "$here\.."
$ErrorActionPreference = 'Stop'

docker compose build

docker compose up -d robot_p3at_sim_ros1 robot_p3at_sim_ros2 ros_bridge

$rc = 0
try {
    docker compose run --rm ros_tests
    $rc = $LASTEXITCODE
} catch {
    $rc = $LASTEXITCODE
} finally {
    docker compose down -v
}

if ($rc -ne 0) { exit $rc }
