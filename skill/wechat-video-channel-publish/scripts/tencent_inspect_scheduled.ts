import fs from "node:fs";
import path from "node:path";
import { launchBrowser, applyStealthScript } from "../src/browser.js";
import { isHeadless } from "../src/config.js";
import { resolveTencentCookiePath } from "../src/paths.js";

const LIST_URL = "https://channels.weixin.qq.com/platform/post/list";

function stamp(): string {
  return new Date().toISOString().replace(/[:.]/g, "-");
}

async function main(): Promise<void> {
  const account = process.argv[2] || "my_account";
  const outDir = process.argv[3] || "/tmp/wechat-video-channel-list-inspect";
  fs.mkdirSync(outDir, { recursive: true });
  const outBase = path.join(outDir, `inspect-${stamp()}`);
  const storagePath = resolveTencentCookiePath(account);

  const browser = await launchBrowser(isHeadless());
  try {
    const ctx = await browser.newContext({ storageState: storagePath });
    await applyStealthScript(ctx);
    const page = await ctx.newPage();
    await page.goto(LIST_URL, { waitUntil: "load", timeout: 120_000 });
    await page.waitForLoadState("networkidle", { timeout: 30_000 }).catch(() => {});
    await page.waitForTimeout(4000);

    await page.screenshot({ path: `${outBase}.png`, fullPage: true });
    const texts = await page.locator("body").first().evaluate((el) =>
      (el.textContent || "").replace(/\s+/g, " ").trim()
    ).catch(() => "");
    const candidates = await page
      .locator("text=/待发布|待发表|定时|草稿|删除|撤销|取消/")
      .evaluateAll((els) =>
        els.map((el) => ({
          text: (el.textContent || "").replace(/\s+/g, " ").trim(),
          className: (el as HTMLElement).className || "",
        }))
      )
      .catch(() => []);
    const frameTexts = [];
    for (const frame of page.frames()) {
      try {
        const bodyText = await frame
          .locator("body")
          .first()
          .evaluate((el) => (el.textContent || "").replace(/\s+/g, " ").trim());
        frameTexts.push({
          url: frame.url(),
          text_excerpt: bodyText.slice(0, 2000),
        });
      } catch {
        // ignore frame read failures
      }
    }
    fs.writeFileSync(
      `${outBase}.json`,
      JSON.stringify(
        {
          url: page.url(),
          candidates,
          frame_texts: frameTexts,
          text_excerpt: texts.slice(0, 4000),
        },
        null,
        2
      ),
      "utf-8"
    );
    console.log(`${outBase}.png`);
    console.log(`${outBase}.json`);
  } finally {
    await browser.close();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
