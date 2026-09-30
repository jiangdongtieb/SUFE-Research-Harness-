# 停止专用 Research Chrome
# 用法: powershell -ExecutionPolicy Bypass -File scripts\stop_research_chrome.ps1
# 通过 CDP 让 Chrome 正常退出（会写回会话与 Preferences），不暴力 kill。

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$cdpPort = 9222
$profileDir = Join-Path $env:USERPROFILE "ResearchHarness\chrome-profile"

# 1. 尝试通过 CDP 优雅关闭
try {
    $pages = Invoke-RestMethod -Uri "http://localhost:$cdpPort/json/list" -TimeoutSec 5
    $browserPage = $pages | Where-Object { $_.type -eq "page" } | Select-Object -First 1
    if ($browserPage) {
        # 发送 Browser.close 命令（通过 /json/close 只关标签，用 websocket 发 Browser.close 更彻底；
        # 这里简化：先提示用户手动关窗口是兜底方案）
        Write-Host "[*] Chrome 正在监听 CDP。为避免丢失会话，请直接关闭 Chrome 窗口。" -ForegroundColor Yellow
        Write-Host "[*] 或按 Ctrl+C 保持窗口，下次继续用。" -ForegroundColor Cyan
        exit 0
    }
} catch {
    Write-Host "[!] CDP 无响应（Chrome 可能已关闭）: $($_.Exception.Message)" -ForegroundColor Yellow
}

# 2. 兜底：检查是否有占用该 profile 的 Chrome 进程
$procs = Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -and $_.CommandLine.Contains($profileDir) }

if ($procs) {
    Write-Host "[*] 发现占用 profile 的 Chrome 进程 $($procs.Count) 个。" -ForegroundColor Yellow
    Write-Host "[*] 是否强制结束? 输入 Y 结束，其他任意键取消:" -ForegroundColor Yellow -NoNewline
    $ans = Read-Host
    if ($ans -eq "Y" -or $ans -eq "y") {
        $procs | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
        Write-Host "[OK] 已结束 Chrome 进程。" -ForegroundColor Green
    } else {
        Write-Host "[*] 已取消。Chrome 保持运行。" -ForegroundColor Cyan
    }
} else {
    Write-Host "[OK] 没有占用专用 profile 的 Chrome 进程。" -ForegroundColor Green
}
