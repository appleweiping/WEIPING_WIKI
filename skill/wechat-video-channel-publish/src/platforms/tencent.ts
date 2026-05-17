/**
 * 微信视频号发布（Playwright）。
 * 登录逻辑与 Python get_tencent_cookie / cookie_auth 完全对齐。
 */
import fs from "node:fs";
import path from "node:path";
import { setTimeout as sleep } from "node:timers/promises";
import { type Page } from "playwright";
import {
  isHeadless,
  selectAllModifier,
} from "../config.js";
import {
  launchBrowser,
  applyStealthScript,
  gotoLoginPage,
  waitForUserLoginComplete,
} from "../browser.js";
import { emit } from "../progress.js";
import { resolveTencentCookiePath } from "../paths.js";

const CREATE_URL = "https://channels.weixin.qq.com/platform/post/create";

function formatDurationZh(ms: number): string {
  if (ms % 60_000 === 0) return `${ms / 60_000} 分钟`;
  const sec = Math.floor(ms / 1000);
  return `${sec} 秒`;
}

function pad2(n: number): string {
  return String(n).padStart(2, "0");
}

/** 发表页可能被重定向到 /platform 首页，需再次进入 create */
async function ensureTencentPostCreatePage(page: Page): Promise<void> {
  const onCreate = () => page.url().includes("/post/create");
  const onPlatformHome = () =>
    page.url() === "https://channels.weixin.qq.com/platform" ||
    page.url() === "https://channels.weixin.qq.com/platform/";

  const clickPublishEntryFromHome = async (): Promise<boolean> => {
    if (!onPlatformHome()) return false;
    const publishButton = page.getByRole("button", { name: "发表视频", exact: true }).first();
    if ((await publishButton.count()) === 0) return false;
    try {
      await publishButton.click({ timeout: 10_000 });
      await page.waitForURL(/\/platform\/post\/create/, { timeout: 90_000 });
      return true;
    } catch {
      return false;
    }
  };

  for (let i = 0; i < 3; i++) {
    if (onCreate()) return;
    await page.goto(CREATE_URL, { waitUntil: "load", timeout: 120_000 });
    await sleep(1500);
    try {
      await page.waitForLoadState("networkidle", { timeout: 15_000 });
    } catch {
      /* ignore */
    }
    if (onCreate()) return;
    if (await clickPublishEntryFromHome()) return;
    try {
      await page.waitForURL(/\/platform\/post\/create/, { timeout: 10_000 });
    } catch {
      /* continue retry */
    }
    if (onCreate()) return;
    await sleep(2000);
  }
  if (!onCreate()) {
    throw new Error(
      `无法进入视频发表页（期望路径含 /post/create），当前: ${page.url()}`
    );
  }
}

const SHORT_TITLE_SPECIAL = new Set([
  ..."《》",
  "\u201c",
  "\u201d",
  ":",
  "+",
  "?",
  "%",
  "°",
]);

function isShortTitleChar(ch: string): boolean {
  if (SHORT_TITLE_SPECIAL.has(ch)) return true;
  if (/^[a-zA-Z0-9]$/.test(ch)) return true;
  const code = ch.codePointAt(0) ?? 0;
  return code >= 0x4e00 && code <= 0x9fff;
}

export function formatShortTitle(origin: string): string {
  const filtered = [...origin]
    .map((ch) => {
      if (isShortTitleChar(ch)) return ch;
      if (ch === ",") return " ";
      return "";
    })
    .join("");
  let s = filtered;
  if (s.length > 16) s = s.slice(0, 16);
  else if (s.length < 6) s = s + " ".repeat(6 - s.length);
  return s;
}

// ─── cookie 校验（与 Python cookie_auth 完全一致）──────────────

export async function cookieAuth(storagePath: string): Promise<boolean> {
  if (!fs.existsSync(storagePath)) return false;
  const browser = await launchBrowser(true);
  try {
    const ctx = await browser.newContext({ storageState: storagePath });
    await applyStealthScript(ctx);
    const page = await ctx.newPage();
    await page.goto(CREATE_URL, {
      waitUntil: "domcontentloaded",
      timeout: 60_000,
    });
    await sleep(1500);
    const url = page.url();
    if (url.includes("/login")) return false;
    if (!url.includes("channels.weixin.qq.com/platform")) return false;
    const scanLoginVisible = await page
      .getByText("扫码登录", { exact: true })
      .first()
      .isVisible()
      .catch(() => false);
    if (scanLoginVisible) return false;
    return true;
  } finally {
    await browser.close();
  }
}

// ─── 登录（与 Python get_tencent_cookie 完全一致）──────────────
// Python 原版：打开 channels.weixin.qq.com → page.pause() → 保存 storageState
// 二维码由页面自然显示（iframe 中的微信扫码），不需要额外选择器操作

async function waitUntilTencentLoggedIn(page: Page): Promise<void> {
  const rawTimeout = process.env.SOCIAL_PUBLISH_TENCENT_LOGIN_TIMEOUT_MS;
  const parsedTimeout = rawTimeout ? Number(rawTimeout) : NaN;
  const timeoutMs =
    Number.isFinite(parsedTimeout) && parsedTimeout >= 30_000
      ? Math.floor(parsedTimeout)
      : 300_000;
  const timeoutLabel = formatDurationZh(timeoutMs);
  const pollMs = 500;
  const needStable = 3;
  const start = Date.now();
  let stable = 0;
  console.log(
    `[tencent] 请在 ${timeoutLabel} 内完成扫码登录，超时将回退到手动确认（Inspector Resume / 终端回车）`
  );
  console.log("[tencent] 正在轮询登录状态，扫码成功后将自动继续…");

  while (Date.now() - start < timeoutMs) {
    const url = page.url();
    const onChannels = url.includes("channels.weixin.qq.com/platform");
    const onLogin = url.includes("/login");
    const scanLoginVisible = await page
      .getByText("扫码登录", { exact: true })
      .first()
      .isVisible()
      .catch(() => false);

    if (onChannels && !onLogin && !scanLoginVisible) {
      stable += 1;
      if (stable >= needStable) {
        await sleep(800);
        console.log("[tencent] 已检测到登录成功");
        return;
      }
    } else {
      stable = 0;
    }
    await sleep(pollMs);
  }

  console.warn(
    `[tencent] 自动检测超时（${timeoutLabel}），回退到手动模式`
  );
  await waitForUserLoginComplete(page);
}

export async function loginAndSaveCookie(storagePath: string): Promise<void> {
  fs.mkdirSync(path.dirname(storagePath), { recursive: true });
  const browser = await launchBrowser(false);
  const ctx = await browser.newContext();
  await applyStealthScript(ctx);
  const page = await ctx.newPage();
  await gotoLoginPage(page, "https://channels.weixin.qq.com");
  console.log("请在浏览器中用微信扫码登录。");
  if (process.env.SOCIAL_PUBLISH_LOGIN_STDIN === "1") {
    await waitForUserLoginComplete(page);
  } else {
    await waitUntilTencentLoggedIn(page);
  }
  await sleep(2000);
  await ctx.storageState({ path: storagePath });
  await browser.close();
}

// ─── 以下为发布相关 ───────────────────────────────────────────

export type TencentPublishOptions = {
  account: string;
  videoFile: string;
  title: string;
  tags: string[];
  caption?: string;
  coverFile?: string;
  pinnedComment?: string;
  schedule?: Date | null;
  category?: string;
  draft?: boolean;
};

const TENCENT_FILE_TIMEOUT = 180_000;

/** 发表页为 SPA，file input 可能晚于 domcontentloaded 才挂载，或在 iframe 内 */
async function setTencentVideoFile(page: Page, videoPath: string): Promise<void> {
  await ensureTencentPostCreatePage(page);
  await page.waitForLoadState("load", { timeout: 90_000 }).catch(() => {});
  await page.waitForLoadState("networkidle", { timeout: 45_000 }).catch(() => {});
  await sleep(2000);
  if (!page.url().includes("/post/create")) {
    await ensureTencentPostCreatePage(page);
    await sleep(1500);
  }

  const pickFileInput = () => page.locator('input[type="file"]');

  try {
    await pickFileInput().first().waitFor({
      state: "attached",
      timeout: TENCENT_FILE_TIMEOUT,
    });
    await pickFileInput()
      .first()
      .setInputFiles(videoPath, { timeout: TENCENT_FILE_TIMEOUT });
    return;
  } catch {
    /* try fallbacks */
  }

  const videoInputs = page.locator(
    'input[type="file"][accept*="video"], input[accept*="mp4"]'
  );
  if ((await videoInputs.count()) > 0) {
    await videoInputs
      .first()
      .setInputFiles(videoPath, { timeout: TENCENT_FILE_TIMEOUT });
    return;
  }

  for (const frame of page.frames()) {
    const fin = frame.locator('input[type="file"]');
    if ((await fin.count()) > 0) {
      await fin
        .first()
        .setInputFiles(videoPath, { timeout: TENCENT_FILE_TIMEOUT });
      return;
    }
  }

  const triggerTexts = ["上传视频", "选择视频", "从相册选择", "点击上传"];
  for (const text of triggerTexts) {
    const btn = page.getByText(text, { exact: false }).first();
    if ((await btn.count()) === 0) continue;
    try {
      const [chooser] = await Promise.all([
        page.waitForEvent("filechooser", { timeout: 15_000 }),
        btn.click({ timeout: 5000 }),
      ]);
      await chooser.setFiles(videoPath);
      return;
    } catch {
      /* next */
    }
  }

  throw new Error(
    `视频号发表页未找到上传控件（当前 URL: ${page.url()}）。可尝试：SOCIAL_PUBLISH_HEADLESS=0 有界面重试；确认已进入发表页且未被安全验证拦截。`
  );
}

async function handleUploadError(page: Page, videoPath: string): Promise<void> {
  await page.locator('div.media-status-content div.tag-inner:has-text("删除")').click();
  await page.getByRole("button", { name: "删除", exact: true }).click();
  await setTencentVideoFile(page, videoPath);
}

async function addTitleTags(page: Page, title: string, tags: string[]): Promise<void> {
  await page.locator("div.input-editor").click();
  await page.keyboard.type(title);
  await page.keyboard.press("Enter");
  for (const tag of tags) {
    await page.keyboard.type(`#${tag}`);
    await page.keyboard.press("Space");
  }
}

async function fillCaption(page: Page, caption?: string): Promise<void> {
  if (!caption?.trim()) return;

  // The upstream uploader writes desc directly in the same rich editor after
  // title/tags. This is the most likely happy path on the current page.
  try {
    await page.keyboard.press("Enter");
    await page.keyboard.type(caption);
    emit(5, 8, "CAPTION", "已在主编辑区填写正文描述");
    return;
  } catch {
    /* fall through to explicit desc controls */
  }

  const candidates = [
    page.locator('textarea[placeholder*="介绍"]').first(),
    page.locator('textarea[placeholder*="描述"]').first(),
    page.locator('textarea[placeholder*="说点什么"]').first(),
    page.locator('[contenteditable="true"][data-placeholder*="介绍"]').first(),
    page.locator('[contenteditable="true"][data-placeholder*="描述"]').first(),
    page.locator('[class*="desc"] textarea').first(),
    page.locator('[class*="desc"] [contenteditable="true"]').first(),
  ];

  for (const locator of candidates) {
    if ((await locator.count()) === 0) continue;
    try {
      await locator.click({ timeout: 3000 });
      const tagName = await locator.evaluate((el) => el.tagName).catch(() => "");
      if (tagName === "TEXTAREA" || tagName === "INPUT") {
        await locator.fill(caption, { timeout: 5000 });
      } else {
        await page.keyboard.press(`${selectAllModifier()}+A`).catch(() => {});
        await page.keyboard.type(caption);
      }
      emit(5, 8, "CAPTION", "已填写正文描述");
      return;
    } catch {
      /* try next candidate */
    }
  }

  emit(5, 8, "CAPTION", "未定位到正文描述输入区，跳过", false);
}

async function selectCover(page: Page, coverFile?: string): Promise<void> {
  if (!coverFile) return;
  const coverPath = path.resolve(coverFile);
  if (!fs.existsSync(coverPath)) {
    emit(5, 8, "COVER", `封面文件不存在: ${coverPath}`, false);
    return;
  }

  // Align with the more complete upstream Tencent uploader flow:
  // open the 3:4 homepage card cover editor, upload into the dialog,
  // optionally confirm crop, then confirm the main dialog.
  const coverEntrySelectors = [
    'div.vertical-cover-wrap:has-text("个人主页卡片"):has-text("3:4")',
    'div.vertical-cover-wrap:has-text("3:4")',
    'div.vertical-cover-wrap:has-text("个人主页卡片")',
  ];

  for (const selector of coverEntrySelectors) {
    const entry = page.locator(selector).first();
    try {
      if ((await entry.count()) === 0) continue;
      await entry.waitFor({ state: "visible", timeout: 3000 });
      await entry.click();
      await sleep(500);
      break;
    } catch {
      /* try next selector */
    }
  }

  const coverDialog = page
    .locator("div.weui-desktop-dialog")
    .filter({ hasText: "编辑个人主页卡片" })
    .first();

  if ((await coverDialog.count()) > 0) {
    try {
      await coverDialog.waitFor({ state: "visible", timeout: 5000 });
      const fileInput = coverDialog
        .locator('.single-cover-uploader-wrap input[type="file"]')
        .first();
      await fileInput.waitFor({ state: "attached", timeout: 10_000 });
      await fileInput.setInputFiles(coverPath, { timeout: 15_000 });
      await sleep(1000);

      const cropDialog = page
        .locator("div.weui-desktop-dialog")
        .filter({ hasText: "裁剪封面图" })
        .first();
      if ((await cropDialog.count()) > 0) {
        try {
          await cropDialog.waitFor({ state: "visible", timeout: 10_000 });
          const cropConfirm = cropDialog
            .locator('div.weui-desktop-dialog__ft button.weui-desktop-btn_primary:has-text("确定")')
            .first();
          if ((await cropConfirm.count()) > 0) {
            await cropConfirm.waitFor({ state: "visible", timeout: 5000 });
            await cropConfirm.click();
            await sleep(1000);
          }
        } catch {
          /* continue to outer confirm */
        }
      }

      const confirm = coverDialog
        .locator('div.weui-desktop-dialog__ft button.weui-desktop-btn_primary:has-text("确认")')
        .first();
      if ((await confirm.count()) > 0) {
        await confirm.waitFor({ state: "visible", timeout: 10_000 });
        await confirm.click();
        emit(5, 8, "COVER", `已设置封面: ${path.basename(coverPath)}`);
        return;
      }
    } catch {
      /* fall through to generic cover probes */
    }
  }

  // Fallback: try common upload-entry patterns first, then detect keyframe UI.
  const uploadCoverCandidates = [
    page.getByText("上传封面", { exact: false }).first(),
    page.getByText("更换封面", { exact: false }).first(),
    page.locator('[class*="cover"] input[type="file"]').first(),
    page.locator('[class*="cover"] button').filter({ hasText: "上传" }).first(),
  ];

  for (const locator of uploadCoverCandidates) {
    if ((await locator.count()) === 0) continue;
    try {
      const inputType = await locator.getAttribute("type").catch(() => null);
      if (inputType === "file") {
        await locator.setInputFiles(coverPath, { timeout: 15_000 });
      } else {
        const [chooser] = await Promise.all([
          page.waitForEvent("filechooser", { timeout: 10_000 }),
          locator.click({ timeout: 5000 }),
        ]);
        await chooser.setFiles(coverPath);
      }
      emit(5, 8, "COVER", `已尝试上传封面: ${path.basename(coverPath)}`);
      await sleep(1500);
      await confirmCoverDialogs(page);
      return;
    } catch {
      /* try next candidate */
    }
  }

  const sliderCandidates = [
    page.locator('[class*="cover"] [class*="slider"]').first(),
    page.locator('[class*="slider"]').first(),
  ];
  for (const locator of sliderCandidates) {
    if ((await locator.count()) === 0) continue;
    emit(5, 8, "COVER", "检测到封面滑杆，但当前版本还未实现基于图片匹配的自动选帧", false);
    return;
  }

  emit(5, 8, "COVER", "未定位到封面控件，跳过", false);
}

async function confirmCoverDialogs(page: Page): Promise<void> {
  for (let round = 0; round < 3; round++) {
    const visibleDialog = page.locator("div.weui-desktop-dialog:visible").last();
    if ((await visibleDialog.count()) === 0) return;

    const primaryButtons = [
      visibleDialog
        .locator('div.weui-desktop-dialog__ft button.weui-desktop-btn_primary:has-text("确定")')
        .first(),
      visibleDialog
        .locator('div.weui-desktop-dialog__ft button.weui-desktop-btn_primary:has-text("确认")')
        .first(),
      visibleDialog.getByRole("button", { name: "确定" }).first(),
      visibleDialog.getByRole("button", { name: "确认" }).first(),
    ];

    let clicked = false;
    for (const button of primaryButtons) {
      if ((await button.count()) === 0) continue;
      try {
        await button.click({ timeout: 5000, force: true });
        await sleep(1000);
        clicked = true;
        break;
      } catch {
        /* try next button */
      }
    }

    if (!clicked) return;
  }
}

async function addCollection(page: Page): Promise<void> {
  const wrap = page.getByText("添加到合集").locator("xpath=following-sibling::div");
  const items = wrap.locator(".option-list-wrap > div");
  if ((await items.count()) > 1) {
    await wrap.click();
    await items.first().click();
  }
}

async function addOriginal(page: Page, category?: string): Promise<void> {
  const orig = page.getByLabel("视频为原创");
  if ((await orig.count()) > 0) await orig.check();

  const terms = page.locator('label:has-text("我已阅读并同意 《视频号原创声明使用条款》")');
  if (await terms.isVisible().catch(() => false)) {
    await page
      .getByLabel("我已阅读并同意 《视频号原创声明使用条款》")
      .check();
    await page.getByRole("button", { name: "声明原创" }).click();
  }

  if ((await page.locator('div.label span:has-text("声明原创")').count()) > 0 && category) {
    const cb = page.locator("div.declare-original-checkbox input.ant-checkbox-input");
    if ((await cb.count()) > 0 && !(await cb.isDisabled())) await cb.click();

    const checked = page.locator(
      "div.declare-original-dialog label.ant-checkbox-wrapper.ant-checkbox-wrapper-checked:visible"
    );
    if ((await checked.count()) === 0) {
      await page.locator("div.declare-original-dialog input.ant-checkbox-input:visible").click();
    }

    if (
      await page
        .locator('div.original-type-form > div.form-label:has-text("原创类型"):visible')
        .count()
        .then((n) => n > 0)
    ) {
      await page.locator("div.form-content:visible").click();
      await page
        .locator(
          `div.form-content:visible ul.weui-desktop-dropdown__list li.weui-desktop-dropdown__list-ele:has-text("${category}")`
        )
        .first()
        .click();
      await sleep(1000);
    }
    const btn = page.locator('button:has-text("声明原创"):visible');
    if ((await btn.count()) > 0) await btn.click();
  }
}

async function detectUploadStatus(page: Page, videoPath: string): Promise<void> {
  for (;;) {
    try {
      const pub = page.getByRole("button", { name: "发表" });
      const cls = (await pub.getAttribute("class")) ?? "";
      if (!cls.includes("weui-desktop-btn_disabled")) break;
      await sleep(2000);
      const err = await page.locator("div.status-msg.error").count();
      const del = await page
        .locator('div.media-status-content div.tag-inner:has-text("删除")')
        .count();
      if (err > 0 && del > 0) await handleUploadError(page, videoPath);
    } catch {
      await sleep(2000);
    }
  }
}

async function setScheduleTime(page: Page, publishDate: Date): Promise<void> {
  const mod = selectAllModifier();
  await confirmCoverDialogs(page);
  await page.locator("label").filter({ hasText: "定时" }).nth(1).click({ force: true });
  await page.click('input[placeholder="请选择发表时间"]');

  const m = publishDate.getMonth() + 1;
  const currentMonth = `${m < 10 ? "0" : ""}${m}月`;
  const pageMonth = await page
    .locator('span.weui-desktop-picker__panel__label:has-text("月")')
    .innerText();
  if (pageMonth.trim() !== currentMonth) {
    await page.click("button.weui-desktop-btn__icon__right");
  }

  const links = await page.locator("table.weui-desktop-picker__table a").all();
  const dayStr = String(publishDate.getDate());
  for (const el of links) {
    const c = (await el.getAttribute("class")) ?? "";
    if (c.includes("weui-desktop-picker__disabled")) continue;
    const text = (await el.innerText()).trim();
    if (text === dayStr) {
      await el.click();
      break;
    }
  }

  await page.click('input[placeholder="请选择时间"]');
  await page.keyboard.press(`${mod}+A`);
  await page.keyboard.type(`${pad2(publishDate.getHours())}:${pad2(publishDate.getMinutes())}`);
  await page.locator("div.input-editor").click();
}

async function addShortTitle(page: Page, title: string): Promise<void> {
  const short = page
    .getByText("短标题", { exact: true })
    .locator("..")
    .locator("xpath=following-sibling::div")
    .locator('span input[type="text"]');
  if ((await short.count()) > 0) await short.fill(formatShortTitle(title));
}

async function confirmSubmissionDialogs(page: Page): Promise<void> {
  for (let round = 0; round < 3; round++) {
    const visibleDialog = page.locator("div.weui-desktop-dialog:visible").last();
    if ((await visibleDialog.count()) === 0) return;

    const confirmButtons = [
      visibleDialog.getByRole("button", { name: "保存草稿" }).first(),
      visibleDialog.getByRole("button", { name: "继续发表" }).first(),
      visibleDialog.getByRole("button", { name: "发表" }).first(),
      visibleDialog.getByRole("button", { name: "确定" }).first(),
      visibleDialog.getByRole("button", { name: "确认" }).first(),
      visibleDialog.getByRole("button", { name: "我知道了" }).first(),
    ];

    let clicked = false;
    for (const button of confirmButtons) {
      if ((await button.count()) === 0) continue;
      try {
        await button.click({ timeout: 5000, force: true });
        await sleep(1000);
        clicked = true;
        break;
      } catch {
        /* try next button */
      }
    }
    if (!clicked) return;
  }
}

async function hasPostSubmitSuccess(page: Page, draft: boolean): Promise<boolean> {
  const url = page.url();
  if (/\/platform\/post\/list/.test(url)) return true;
  if (draft && /\/platform\/post\/draft/.test(url)) return true;

  const successTexts = draft
    ? ["保存成功", "已保存", "草稿已保存", "已存入草稿"]
    : ["发表成功", "发布成功", "已发表", "提交成功", "审核中"];
  for (const text of successTexts) {
    const visible = await page
      .getByText(text, { exact: false })
      .first()
      .isVisible()
      .catch(() => false);
    if (visible) return true;
  }
  return false;
}

async function visibleSubmissionError(page: Page): Promise<string | null> {
  const candidates = [
    "请选择发表时间",
    "请选择时间",
    "请填写",
    "不能为空",
    "保存失败",
    "发表失败",
    "上传失败",
  ];

  for (const text of candidates) {
    const locator = page.getByText(text, { exact: false }).first();
    if (await locator.isVisible().catch(() => false)) {
      return (await locator.innerText().catch(() => text)).trim() || text;
    }
  }
  return null;
}

async function collectSubmitDiagnostics(page: Page, actionName?: string): Promise<string> {
  const domDiagnostics = await page
    .evaluate(() => {
      const root = globalThis as any;
      const isVisible = (el: any) => {
        const style = root.getComputedStyle(el);
        const rect = el.getBoundingClientRect();
        return style.visibility !== "hidden" && style.display !== "none" && rect.width > 0 && rect.height > 0;
      };
      const buttons = Array.from(root.document.querySelectorAll("button"))
        .filter(isVisible)
        .map((button: any) => ({
          text: (button.textContent ?? "").trim().replace(/\s+/g, " "),
          className: button.className,
          disabled: button.disabled,
        }))
        .filter((button) => button.text);
      const dialogs = Array.from(root.document.querySelectorAll(".weui-desktop-dialog"))
        .filter(isVisible)
        .map((dialog: any) => (dialog.textContent ?? "").trim().replace(/\s+/g, " ").slice(0, 300));
      const inputs = Array.from(root.document.querySelectorAll("input, textarea"))
        .filter(isVisible)
        .map((el: any) => ({
          placeholder: el.placeholder,
          value: el.value,
          className: el.className,
        }))
        .filter((input) => input.placeholder || input.value);
      const submitLikeElements = Array.from(root.document.querySelectorAll("body *"))
        .filter(isVisible)
        .map((el: any) => {
          const text = (el.textContent ?? "").trim().replace(/\s+/g, " ");
          return {
            tag: el.tagName,
            text,
            className: el.className,
            role: el.getAttribute("role"),
            ariaDisabled: el.getAttribute("aria-disabled"),
          };
        })
        .filter((el) => el.text === "保存草稿" || el.text === "发表" || el.text.includes("保存草稿 手机预览 发表"))
        .slice(0, 50);
      return JSON.stringify({ buttons, dialogs, inputs, submitLikeElements }, null, 2);
    })
    .catch((err) => `diagnostics unavailable: ${err instanceof Error ? err.message : String(err)}`);

  const selectorDiagnostics: Record<string, unknown> = {};
  const selectors = [
    ".weui-desktop-btn",
    "[class*=btn]",
    "div.form-btns",
    actionName ? `text="${actionName}"` : "",
  ].filter(Boolean);
  for (const selector of selectors) {
    selectorDiagnostics[selector] = await page
      .locator(selector)
      .evaluateAll((els: any[]) =>
        els.slice(-20).map((el: any) => ({
          text: (el.textContent ?? "").trim().replace(/\s+/g, " "),
          className: el.className,
          disabled: el.disabled,
          ariaDisabled: el.getAttribute?.("aria-disabled"),
        }))
      )
      .catch((err) => `locator unavailable: ${err instanceof Error ? err.message : String(err)}`);
  }

  return JSON.stringify({ domDiagnostics, selectorDiagnostics }, null, 2);
}

async function writeSubmitDebugArtifacts(page: Page, reason: string): Promise<string | null> {
  if (process.env.SOCIAL_PUBLISH_DEBUG_ARTIFACTS !== "1") return null;

  const debugDir = process.env.SOCIAL_PUBLISH_DEBUG_DIR || "/tmp/wechat-video-channel-publish-skill";
  fs.mkdirSync(debugDir, { recursive: true });
  const stamp = new Date().toISOString().replace(/[:.]/g, "-");
  const base = path.join(debugDir, `submit-${stamp}`);
  const diagnostics = await collectSubmitDiagnostics(page);
  fs.writeFileSync(
    `${base}.json`,
    JSON.stringify({ reason, url: page.url(), diagnostics }, null, 2),
    "utf-8"
  );
  await page.screenshot({ path: `${base}.png`, fullPage: true }).catch(() => {});
  return base;
}

async function clickPublish(page: Page, draft: boolean): Promise<void> {
  const actionName = draft ? "保存草稿" : "发表";
  const startedAt = Date.now();
  const rawSubmitTimeout = process.env.SOCIAL_PUBLISH_SUBMIT_TIMEOUT_MS;
  const parsedSubmitTimeout = rawSubmitTimeout ? Number(rawSubmitTimeout) : NaN;
  const timeoutMs =
    Number.isFinite(parsedSubmitTimeout) && parsedSubmitTimeout >= 5000
      ? Math.floor(parsedSubmitTimeout)
      : 180_000;
  let clicks = 0;
  let lastError = "";
  let buttonSeen = false;

  while (Date.now() - startedAt < timeoutMs) {
    if (await hasPostSubmitSuccess(page, draft)) return;

    await confirmCoverDialogs(page);
    await confirmSubmissionDialogs(page);

    const validationError = await visibleSubmissionError(page);
    if (validationError) {
      throw new Error(`${actionName}前页面校验失败: ${validationError}`);
    }

    const submitCandidates = [
      page.locator(`div.form-btns .weui-desktop-btn:has-text("${actionName}")`).last(),
      page.locator(`.weui-desktop-btn:has-text("${actionName}")`).last(),
      page.locator(`div.form-btns [class*="btn"]:has-text("${actionName}")`).last(),
      page.locator(`[class*="btn"]:has-text("${actionName}")`).last(),
      page.locator("div.form-btns").getByRole("button", { name: actionName, exact: true }).last(),
      page.getByRole("button", { name: actionName, exact: true }).last(),
      page.locator("div.form-btns").getByText(actionName, { exact: true }).last(),
      page.getByText(actionName, { exact: true }).last(),
    ];

    if (clicks < 3) {
      for (const candidate of submitCandidates) {
        if ((await candidate.count()) === 0) continue;
        buttonSeen = true;
        clicks += 1;
        try {
          await candidate.scrollIntoViewIfNeeded({ timeout: 3000 }).catch(() => {});
          await candidate.click({ timeout: 8000, force: clicks > 1 });
          break;
        } catch (err) {
          lastError = err instanceof Error ? err.message : String(err);
        }
      }
    }

    try {
      await page.waitForURL(/\/platform\/post\/(list|draft)/, { timeout: 10_000 });
    } catch {
      /* keep polling explicit success/error states */
    }

    if (await hasPostSubmitSuccess(page, draft)) return;
    await sleep(1000);
  }

  const detail = [
    buttonSeen ? "" : " 未定位到提交按钮。",
    lastError ? ` 最后一次点击错误: ${lastError}` : "",
  ].join("");
  const diagnostics = await collectSubmitDiagnostics(page, actionName);
  const artifactBase = await writeSubmitDebugArtifacts(page, `${actionName} timeout`);
  const artifactDetail = artifactBase ? ` 调试快照: ${artifactBase}.json / ${artifactBase}.png。` : "";
  throw new Error(
    `${actionName}未在 ${formatDurationZh(timeoutMs)} 内确认成功，当前 URL: ${page.url()}。${detail}${artifactDetail}\n${diagnostics}`
  );
}

async function tryPostPinnedComment(page: Page, pinnedComment?: string): Promise<void> {
  if (!pinnedComment?.trim()) return;

  // Comments are typically only available after publish. This is a best-effort flow.
  try {
    const currentUrl = page.url();
    if (!currentUrl.includes("/post/list")) return;

    await page.waitForLoadState("networkidle", { timeout: 20_000 }).catch(() => {});
    const commentEntryCandidates = [
      page.getByText("评论", { exact: false }).first(),
      page.getByText("查看评论", { exact: false }).first(),
      page.locator('[class*="comment"]').first(),
    ];

    for (const locator of commentEntryCandidates) {
      if ((await locator.count()) === 0) continue;
      try {
        await locator.click({ timeout: 3000 });
        break;
      } catch {
        /* keep trying */
      }
    }

    await page.waitForTimeout(1500);

    const inputCandidates = [
      page.locator('textarea[placeholder*="评论"]').first(),
      page.locator('textarea[placeholder*="说点"]').first(),
      page.locator('[contenteditable="true"]').last(),
    ];
    for (const locator of inputCandidates) {
      if ((await locator.count()) === 0) continue;
      try {
        await locator.click({ timeout: 3000 });
        const tagName = await locator.evaluate((el) => el.tagName).catch(() => "");
        if (tagName === "TEXTAREA" || tagName === "INPUT") {
          await locator.fill(pinnedComment, { timeout: 5000 });
        } else {
          await page.keyboard.type(pinnedComment);
        }
        const sendBtn = page.getByRole("button", { name: /发送|发布|评论/ }).first();
        if ((await sendBtn.count()) > 0) {
          await sendBtn.click({ timeout: 5000 });
          emit(8, 8, "PIN_COMMENT", "已尝试发送置顶评论");
        } else {
          emit(8, 8, "PIN_COMMENT", "已填写评论，但未定位到发送按钮", false);
        }
        return;
      } catch {
        /* next candidate */
      }
    }
  } catch {
    emit(8, 8, "PIN_COMMENT", "置顶评论补发流程失败", false);
  }
}

export async function publishTencentVideo(opts: TencentPublishOptions): Promise<void> {
  const storagePath = resolveTencentCookiePath(opts.account);
  const videoPath = path.resolve(opts.videoFile);
  if (!fs.existsSync(videoPath)) throw new Error(`Video not found: ${videoPath}`);

  const total = 8;
  emit(1, total, "INIT", "检查参数");
  emit(1, total, "INIT", "OK", true);

  emit(2, total, "COOKIE_CHECK", "校验登录态");
  let valid = await cookieAuth(storagePath);
  if (!valid) {
    emit(2, total, "COOKIE_CHECK", "失效", false);
    emit(3, total, "COOKIE_REFRESH", "请登录（headed + pause）");
    await loginAndSaveCookie(storagePath);
    valid = await cookieAuth(storagePath);
    if (!valid) throw new Error("Cookie still invalid after login");
    emit(3, total, "COOKIE_REFRESH", "OK", true);
  } else emit(2, total, "COOKIE_CHECK", "有效", true);

  const headless = isHeadless();
  const browser = await launchBrowser(headless);
  const ctx = await browser.newContext({ storageState: storagePath });
  await applyStealthScript(ctx);
  const page = await ctx.newPage();

  try {
    emit(4, total, "OPEN_PUBLISH_PAGE", CREATE_URL);
    await page.goto(CREATE_URL, {
      waitUntil: "load",
      timeout: 120_000,
    });
    await ensureTencentPostCreatePage(page);

    emit(5, total, "UPLOAD_START", path.basename(videoPath));
    await setTencentVideoFile(page, videoPath);
    await addTitleTags(page, opts.title, opts.tags);
    await fillCaption(page, opts.caption);
    await addCollection(page);
    await addOriginal(page, opts.category);

    emit(6, total, "UPLOAD_TRANSFERRING", "等待转码");
    await detectUploadStatus(page, videoPath);
    await selectCover(page, opts.coverFile);

    if (opts.schedule && opts.draft) {
      emit(7, total, "SCHEDULE", "草稿模式跳过定时设置；视频号当前不稳定支持“定时 + 保存草稿”", false);
    } else if (opts.schedule) {
      await setScheduleTime(page, opts.schedule);
    }
    await addShortTitle(page, opts.title);

    emit(7, total, "PUBLISHING", opts.draft ? "草稿" : "发表");
    await clickPublish(page, !!opts.draft);

    await ctx.storageState({ path: storagePath });
    if (!opts.draft) {
      await tryPostPinnedComment(page, opts.pinnedComment);
    }
    emit(8, total, "DONE", "成功", true);
  } finally {
    await ctx.close();
    await browser.close();
  }
}
