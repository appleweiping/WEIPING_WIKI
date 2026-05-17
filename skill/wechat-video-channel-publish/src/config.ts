import { homedir } from "node:os";
import path from "node:path";

/** Persistent data root: cookies, logs. Override with SOCIAL_PUBLISH_DATA_DIR. */
export function getDataDir(): string {
  const env = process.env.SOCIAL_PUBLISH_DATA_DIR?.trim();
  if (env) return path.resolve(env);
  return path.join(homedir(), ".social-publish-skills");
}

export function isHeadless(): boolean {
  const v = process.env.SOCIAL_PUBLISH_HEADLESS?.toLowerCase();
  if (v === "0" || v === "false") return false;
  return true;
}

/** System Chrome / Edge path for H.264 etc. Optional. */
export function getChromeExecutable(): string | undefined {
  return process.env.SOCIAL_PUBLISH_CHROME_PATH?.trim() || undefined;
}

export function selectAllModifier(): "Meta" | "Control" {
  return process.platform === "darwin" ? "Meta" : "Control";
}
