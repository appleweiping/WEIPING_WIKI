import { existsSync, mkdirSync } from 'fs';
import { dirname, join, resolve } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

function findRepoRoot(startDir) {
  let current = resolve(startDir);

  for (let i = 0; i < 10; i += 1) {
    if (
      existsSync(join(current, 'AGENTS.md')) &&
      existsSync(join(current, '.wiki-schema.md'))
    ) {
      return current;
    }

    const parent = dirname(current);
    if (parent === current) break;
    current = parent;
  }

  return null;
}

export function getSkillRoot() {
  return resolve(__dirname, '..', '..');
}

export function getRepoRoot() {
  return findRepoRoot(__dirname);
}

export function getAuthDir() {
  const envDir = process.env.EMAIL_ASSISTANT_AUTH_DIR;
  const authDir = envDir
    ? resolve(envDir)
    : join(getRepoRoot() || getSkillRoot(), '.wiki-tmp', 'email-assistant', 'auth');

  if (!existsSync(authDir)) {
    mkdirSync(authDir, { recursive: true, mode: 0o700 });
  }

  return authDir;
}

export function getLogDir() {
  const envDir = process.env.EMAIL_ASSISTANT_LOG_DIR;
  const logDir = envDir
    ? resolve(envDir)
    : join(getRepoRoot() || getSkillRoot(), '.wiki-tmp', 'email-assistant', 'logs');

  if (!existsSync(logDir)) {
    mkdirSync(logDir, { recursive: true, mode: 0o700 });
  }

  return logDir;
}

export function getCredentialsPath() {
  return join(getAuthDir(), 'credentials.json');
}

export function getTokenPath() {
  return join(getAuthDir(), 'tokens.json');
}
