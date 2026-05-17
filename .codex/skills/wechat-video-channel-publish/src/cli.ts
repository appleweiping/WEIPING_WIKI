#!/usr/bin/env node
import { Command } from "commander";
import {
  cookieAuth as tencentCookieAuth,
  loginAndSaveCookie as tencentLogin,
  publishTencentVideo,
} from "./platforms/tencent.js";
import { resolveTencentCookiePath } from "./paths.js";

async function loginThenVerifyCookie(opts: {
  label: string;
  path: string;
  skipVerify: boolean;
  login: (p: string) => Promise<void>;
  check: (p: string) => Promise<boolean>;
}): Promise<void> {
  await opts.login(opts.path);
  console.log(`[${opts.label}] saved ${opts.path}`);
  if (opts.skipVerify) {
    console.log(`[${opts.label}] skipped post-login cookie check (--skip-verify)`);
    return;
  }
  console.log(`[${opts.label}] post-login cookie check (headless)...`);
  const ok = await opts.check(opts.path);
  console.log(`[${opts.label}] cookie_check: ${ok ? "valid" : "invalid"}`);
  if (!ok) process.exit(1);
}

function parseTags(s?: string): string[] {
  if (!s) return [];
  return s
    .split(",")
    .map((x) => x.trim().replace(/^#/, ""))
    .filter(Boolean);
}

function parseSchedule(raw?: string): Date | undefined {
  if (!raw?.trim()) return undefined;
  const m = raw.trim().match(/^(\d{4})-(\d{2})-(\d{2})\s+(\d{1,2}):(\d{2})$/);
  if (!m) throw new Error(`Invalid --schedule "${raw}". Use YYYY-MM-DD HH:mm`);
  const [, y, mo, d, h, mi] = m;
  return new Date(Number(y), Number(mo) - 1, Number(d), Number(h), Number(mi), 0, 0);
}

const program = new Command();
program
  .name("wechat-video-channel-publish")
  .description("WeChat Channels publish CLI (TypeScript + Playwright)");

const tencent = program.command("tencent").description("微信视频号");

tencent
  .command("check")
  .requiredOption("--account <name>", "账号名或 cookie JSON 路径")
  .action(async (opts) => {
    const p = resolveTencentCookiePath(opts.account);
    const ok = await tencentCookieAuth(p);
    console.log(ok ? "valid" : "invalid");
    process.exit(ok ? 0 : 1);
  });

tencent
  .command("login")
  .requiredOption("--account <name>", "账号名")
  .option("--skip-verify", "仅保存 storageState，保存后不跑无头校验")
  .action(async (opts) => {
    const p = resolveTencentCookiePath(opts.account);
    await loginThenVerifyCookie({
      label: "tencent",
      path: p,
      skipVerify: Boolean(opts.skipVerify),
      login: tencentLogin,
      check: tencentCookieAuth,
    });
  });

tencent
  .command("upload")
  .requiredOption("--account <name>", "账号名")
  .requiredOption("--file <path>", "视频文件")
  .requiredOption("--title <t>", "标题")
  .option("--tags <csv>", "逗号分隔话题")
  .option("--caption <text>", "正文描述")
  .option("--cover <path>", "封面图片路径")
  .option("--pinned-comment <text>", "发布后尝试补评论")
  .option("--schedule <t>", "定时 YYYY-MM-DD HH:mm")
  .option("--category <c>", "原创类型（可选）")
  .option("--draft", "存草稿")
  .action(async (opts) => {
    await publishTencentVideo({
      account: opts.account,
      videoFile: opts.file,
      title: opts.title,
      tags: parseTags(opts.tags),
      caption: opts.caption,
      coverFile: opts.cover,
      pinnedComment: opts.pinnedComment,
      schedule: parseSchedule(opts.schedule),
      category: opts.category,
      draft: Boolean(opts.draft),
    });
  });

program.parseAsync(process.argv);
