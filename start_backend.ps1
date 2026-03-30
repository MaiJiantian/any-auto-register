param(
    [string]$VenvName = ".venv",
    [string]$BindHost = "0.0.0.0",
    [int]$Port = 8000,
    [switch]$RestartExisting = $true
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

# 检查 uv 是否安装
$uv = Get-Command uv -ErrorAction SilentlyContinue
if (-not $uv) {
    Write-Error "未找到 uv 命令。请先安装 uv: https://docs.astral.sh/uv/getting-started/installation/"
    exit 1
}

Write-Host "[INFO] 项目目录：$root"
Write-Host "[INFO] 使用 uv 虚拟环境：$VenvName"
$displayHost = if ($BindHost -eq "0.0.0.0") { "localhost" } else { $BindHost }
Write-Host "[INFO] 启动后端：http://$displayHost`:$Port"
Write-Host "[INFO] 按 Ctrl+C 可停止服务"

# 使用 uv 确保虚拟环境存在并获取 Python 路径
$pythonExe = (& uv python find).Trim()
if (-not $pythonExe) {
    Write-Error "无法通过 uv 找到 Python 解释器。请运行 'uv venv' 创建虚拟环境。"
    exit 1
}

if ($RestartExisting) {
    Write-Host "[INFO] 启动前先清理旧的后端 / Solver 进程"
    & "$root\stop_backend.ps1" -BackendPort $Port -SolverPort 8889 -FullStop 0
}

Write-Host "[INFO] Python: $pythonExe"
& uv run main.py
