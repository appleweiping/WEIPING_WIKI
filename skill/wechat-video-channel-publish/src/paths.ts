import fs from "node:fs";
import path from "node:path";
import { getDataDir } from "./config.js";

function resolveCookiePath(platform: string, accountOrPath: string): string {
  const p = accountOrPath.trim();
  if (p.endsWith(".json") || path.isAbsolute(p) || p.includes("/") || p.includes("\\")) {
    return path.isAbsolute(p) ? p : path.resolve(process.cwd(), p);
  }
  const dir = path.join(getDataDir(), "cookies", platform);
  fs.mkdirSync(dir, { recursive: true });
  return path.join(dir, `${p}.json`);
}

export function resolveTencentCookiePath(accountOrPath: string): string {
  return resolveCookiePath("tencent", accountOrPath);
}

export function resolveDouyinCookiePath(accountOrPath: string): string {
  return resolveCookiePath("douyin", accountOrPath);
}

export function resolveKuaishouCookiePath(accountOrPath: string): string {
  return resolveCookiePath("kuaishou", accountOrPath);
}
