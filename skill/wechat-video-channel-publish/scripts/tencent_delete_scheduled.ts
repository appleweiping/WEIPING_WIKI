import fs from "node:fs";
import { launchBrowser, applyStealthScript } from "../src/browser.js";
import { isHeadless } from "../src/config.js";
import { resolveTencentCookiePath } from "../src/paths.js";

const LIST_URL = "https://channels.weixin.qq.com/platform/post/list";

async function confirmDeleteDialog(page: any): Promise<void> {
  const dialog = page.locator("div.weui-desktop-dialog:visible").last();
  if ((await dialog.count()) === 0) return;

  const buttons = [
    dialog.getByRole("button", { name: "删除", exact: true }).first(),
    dialog.getByRole("button", { name: "确认", exact: true }).first(),
    dialog.getByRole("button", { name: "确定", exact: true }).first(),
  ];

  for (const button of buttons) {
    if ((await button.count()) === 0) continue;
    try {
      await button.click({ timeout: 5000, force: true });
      await page.waitForTimeout(1500);
      return;
    } catch {
      // try next button
    }
  }
}

async function searchTitle(page: any, title: string): Promise<void> {
  const search = page.locator('input[placeholder*="搜索"]').first();
  if ((await search.count()) === 0) return;
  await search.fill(title);
  await page.keyboard.press("Enter").catch(() => {});
  await page.waitForTimeout(2500);
}

async function main(): Promise<void> {
  const account = process.argv[2] || "my_account";
  const titlesPath = process.argv[3];
  if (!titlesPath) {
    throw new Error("usage: npx tsx scripts/tencent_delete_scheduled.ts <account> <titles.txt>");
  }

  const titles = fs
    .readFileSync(titlesPath, "utf-8")
    .split("\n")
    .map((line) => line.trim())
    .filter(Boolean);

  const browser = await launchBrowser(isHeadless());
  try {
    const ctx = await browser.newContext({ storageState: resolveTencentCookiePath(account) });
    await applyStealthScript(ctx);
    const page = await ctx.newPage();
    await page.goto(LIST_URL, { waitUntil: "domcontentloaded", timeout: 120_000 });
    await page.waitForURL(/channels\.weixin\.qq\.com\/platform(?:\/|$)/, {
      timeout: 60_000,
    }).catch(() => {});
    await page.waitForTimeout(5000);

    for (const title of titles) {
      await searchTitle(page, title);
      const rows = page.locator(".post-feed-item").filter({ hasText: title });
      const beforeCount = await rows.count();
      if (beforeCount === 0) {
        console.log(`MISS ${title}`);
        continue;
      }
      const row = rows.first();

      await row.scrollIntoViewIfNeeded().catch(() => {});
      const deleteAction = row
        .locator(".opr-item-wrap")
        .filter({ hasText: "删除" })
        .first();
      if ((await deleteAction.count()) === 0) {
        console.log(`NO_DELETE ${title}`);
        continue;
      }

      await deleteAction.click({ timeout: 5000, force: true });
      await confirmDeleteDialog(page);
      await page.waitForFunction(
        ([expectedTitle, previousCount]) => {
          const rowsNow = Array.from(document.querySelectorAll(".post-feed-item")).filter(
            (node) => (node.textContent || "").includes(expectedTitle)
          ).length;
          return rowsNow < previousCount;
        },
        [title, beforeCount],
        { timeout: 15_000 }
      );
      const afterCount = await rows.count();
      console.log(`DELETED ${title} (${beforeCount} -> ${afterCount})`);
      await page.waitForTimeout(2000);
    }
  } finally {
    await browser.close();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
