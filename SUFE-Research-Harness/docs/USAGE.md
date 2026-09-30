# 使用说明

## 前置准备

- Windows + Chrome
- Python 3.11+，装了 playwright 库：
  ```powershell
  python -m pip install playwright
  ```

## 一、启动专用 Research Chrome

```powershell
powershell -ExecutionPolicy Bypass -File scripts\start_research_chrome.ps1
```

脚本做的事：

1. 检查 `C:\Program Files\Google\Chrome\Application\chrome.exe` 是否存在
2. 创建专用 profile：`%USERPROFILE%\ResearchHarness\chrome-profile`（和你日常浏览器完全隔离）
3. 以 `--remote-debugging-port=9222 --restore-last-session` 启动，并打开 WebVPN
4. 打印 CDP 端口状态

**注意：** 别关这个 Chrome 窗口。登录态、机构访问都靠它。

## 二、登录（人工闸门，必须自己来）

在弹出的 Chrome 里完成：

1. WebVPN 登录：学号/工号 + 密码 + 验证码
2. 之后访问具体数据库时，如果遇到滑块验证码，自己拖一下

脚本永远不会帮你填密码、拖滑块。

## 三、CDP 附着确认

```powershell
python scripts\attach_cdp.py
```

能看到当前打开的标签页列表、标题和 URL，确认登录态正常。

## 四、按数据库访问

### 知网（不走 WebVPN！）

学校的 WebVPN 包装知网地址有 bug（详见 WEBVPN_BUGS.md），所以：

1. 在专用 Chrome 里直接打开 `https://www.cnki.net/`
2. 用**个人账号**登录（用户名/手机号 + 密码，不是学校统一认证）
3. 登录后检索、下载都走自己的账号权限

### ScienceDirect 和其他英文库（走 WebVPN）

1. 从 WebVPN 工作台进「数据库导航」
2. 点 ScienceDirect，地址会变成 `https://www-sciencedirect-com-s.webvpn.sufe.edu.cn/`，机构访问生效
3. 检索、打开文章页、点下载

## 五、检索纪律（重要）

- 两次检索至少间隔 20 秒
- 每天下载控制在 15 篇以内（自己根据学校规则调）
- 同一篇论文一天内最多下 2 次
- 下载的文件核对标题/DOI 后再归档
- 原始文件保留，算 SHA-256 存档

这些数字不是随便定的，是为了不让你学校账号被出版商标记为异常流量。你账号被拉了黑名单，难受的是自己。

## 六、收尾

```powershell
powershell -ExecutionPolicy Bypass -File scripts\stop_research_chrome.ps1
```

脚本会通过 CDP 让 Chrome 正常退出（会话和 cookie 会写回 profile，下次还能用）。如果限时内没退出，会如实报告，不会假装已停止。
