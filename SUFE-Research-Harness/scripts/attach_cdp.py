# -*- coding: utf-8 -*-
"""CDP 附着到专用 Research Chrome (默认 9222)，列出页面并确认登录态。
用法: python scripts/attach_cdp.py [port]
"""
import sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

port = sys.argv[1] if len(sys.argv) > 1 else "9222"

from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.connect_over_cdp(f"http://localhost:{port}")
    for ctx in browser.contexts:
        for pg in ctx.pages:
            print(f"  [{pg.title()[:50]}] {pg.url}")
    # 找 WebVPN 或知网页面
    for ctx in browser.contexts:
        for pg in ctx.pages:
            if "webvpn" in pg.url or "cnki" in pg.url:
                print("\n登录态页面确认: OK")
                print("URL:", pg.url)
                browser.close()
                sys.exit(0)
    print("\n未找到 WebVPN / 知网页面，请先登录")
    browser.close()
