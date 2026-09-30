# 启动专用 Research Chrome（独立 profile + CDP 端口 9222）
# 用法: powershell -ExecutionPolicy Bypass -File scripts\start_research_chrome.ps1

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$profileDir = Join-Path $env:USERPROFILE "ResearchHarness\chrome-profile"
$cdpPort = 9222

# 1. 检查 Chrome
if (-not (Test-Path $chromePath)) {
    Write-Host "[!] 未找到 Chrome，请确认安装路径: $chromePath" -ForegroundColor Red
    exit 1
}

# 2. 创建 profile 目录
New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
Write-Host "[*] Profile: $profileDir" -ForegroundColor Cyan

# 3. 检查端口是否已被占用（Chrome 已在跑）
$inUse = Get-NetTCPConnection -LocalPort $cdpPort -State Listen -ErrorAction SilentlyContinue
if ($inUse) {
    Write-Host "[*] 端口 $cdpPort 已在监听，Chrome 可能已经启动。直接附着即可。" -ForegroundColor Yellow
} else {
    # 4. 启动专用 Chrome
    Start-Process $chromePath -ArgumentList `
        "--user-data-dir=$profileDir", `
        "--remote-debugging-port=$cdpPort", `
        "--restore-last-session", `
        "https://webvpn.sufe.edu.cn"
    Write-Host "[*] 已启动专用 Chrome，请在弹出的窗口里自己登录 WebVPN" -ForegroundColor Green
}

# 5. 等待并验证 CDP
Start-Sleep -Seconds 5
try {
    $ver = Invoke-RestMethod -Uri "http://localhost:$cdpPort/json/version" -TimeoutSec 5
    Write-Host "[OK] CDP 就绪: $($ver.Browser)" -ForegroundColor Green
    Write-Host "[*] 附着地址: http://localhost:$cdpPort"
} catch {
    Write-Host "[!] CDP 检查失败: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "[*] 等 5 秒再试，或手动确认 Chrome 是否启动" -ForegroundColor Yellow
}
