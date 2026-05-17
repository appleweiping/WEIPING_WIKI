/**
 * 统一的浏览器启动与 stealth 注入工具。
 * 与 Python set_init_script(context) 等价：注入 stealth.min.js 规避自动化检测。
 */
import fs from "node:fs";
import readline from "node:readline";
import { fileURLToPath } from "node:url";
import path from "node:path";
import {
  chromium,
  type Browser,
  type BrowserContext,
  type LaunchOptions,
  type Page,
} from "playwright";
import { getChromeExecutable } from "./config.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const STEALTH_JS = path.join(__dirname, "stealth.min.js");

/** 与 Python channel="chrome" 对齐：优先用系统 Chrome */
export function buildLaunchOptions(headless: boolean): LaunchOptions {
  const exe = getChromeExecutable();
  if (exe) return { headless, executablePath: exe };
  return { headless, channel: "chrome" };
}

export async function launchBrowser(headless: boolean): Promise<Browser> {
  return chromium.launch(buildLaunchOptions(headless));
}

/** 注入 stealth.min.js，与 Python set_init_script 等价 */
export async function applyStealthScript(
  ctx: BrowserContext
): Promise<BrowserContext> {
  if (!fs.existsSync(STEALTH_JS)) {
    throw new Error(
      `缺少 stealth.min.js（期望路径: ${STEALTH_JS}）。请执行 npm run build。`
    );
  }
  await ctx.addInitScript({ path: STEALTH_JS });
  return ctx;
}

/**
 * 登录页导航：用 domcontentloaded，避免微信/抖音等站「load」事件迟迟不触发导致一直停在 about:blank。
 */
export async function gotoLoginPage(page: Page, url: string): Promise<void> {
  console.log(`[navigate] 正在打开: ${url}`);
  try {
    await page.goto(url, {
      waitUntil: "domcontentloaded",
      timeout: 120_000,
    });
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    throw new Error(`打开登录页失败: ${msg}`);
  }
  console.log(`[navigate] 当前地址: ${page.url()}`);
}

/**
 * 扫码完成后如何继续（由各平台 login 调用）：
 * - 抖音：默认在 `douyin.ts` 内轮询登录态，成功则自动继续；超时后才会落到本函数的 pause/说明。
 * - 其它平台 / 显式关闭轮询：SOCIAL_PUBLISH_LOGIN_NO_POLL=1 或未实现轮询时 → 默认 page.pause()（Inspector 点 Resume）。
 * - SOCIAL_PUBLISH_LOGIN_STDIN=1：在本终端按 Enter（不依赖 Inspector）。
 *
 * 注意：若设置了 PWDEBUG=1，Inspector 可能在 goto 之前就暂停，窗口会先显示 about:blank，
 * 需先点一次 Resume 才会执行「打开网址」。
 */
export async function waitForUserLoginComplete(page: Page): Promise<void> {
  if (process.env.SOCIAL_PUBLISH_LOGIN_STDIN === "1") {
    console.log("登录完成后，在本终端按 Enter 保存 cookie…");
    await new Promise<void>((resolve) => {
      const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout,
      });
      rl.question("", () => {
        rl.close();
        resolve();
      });
    });
    return;
  }
  console.log(
    "登录完成后，在 Playwright Inspector 中点击 Resume。"
  );
  console.log(
    "[提示] 若浏览器一直停在 about:blank：① 设置了 PWDEBUG=1 时，请先在 Inspector 点一次 Resume 才会开始加载页面；② 或去掉 PWDEBUG=1 再运行；③ 或设置 SOCIAL_PUBLISH_LOGIN_STDIN=1 用终端回车结束。"
  );
  await page.pause();
}
