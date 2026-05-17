#!/usr/bin/env node

import crypto from 'crypto';
import { existsSync, mkdirSync, readdirSync, readFileSync, renameSync, writeFileSync } from 'fs';
import { dirname, join, resolve } from 'path';
import { fileURLToPath } from 'url';
import minimist from 'minimist';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const ALLOWED_PLATFORMS = new Set(['wechat', 'whatsapp', 'qq', 'email', 'feishu']);
const ALLOWED_STATUSES = new Set(['drafted', 'prefilled', 'sent', 'canceled']);

function findRepoRoot(startDir) {
  let current = resolve(startDir);
  for (let i = 0; i < 10; i += 1) {
    if (existsSync(join(current, 'AGENTS.md')) && existsSync(join(current, '.wiki-schema.md'))) {
      return current;
    }
    const parent = dirname(current);
    if (parent === current) break;
    current = parent;
  }
  return resolve(__dirname, '..');
}

function runtimeRoot() {
  return process.env.COMMUNICATION_ASSISTANT_HOME
    ? resolve(process.env.COMMUNICATION_ASSISTANT_HOME)
    : join(findRepoRoot(__dirname), '.wiki-tmp', 'communication-assistant');
}

function runtimeDirs() {
  const root = runtimeRoot();
  return {
    root,
    config: join(root, 'config'),
    sessions: join(root, 'sessions'),
    outbox: join(root, 'outbox'),
    logs: join(root, 'logs')
  };
}

function ensureDirs() {
  const dirs = runtimeDirs();
  Object.values(dirs).forEach(dir => mkdirSync(dir, { recursive: true, mode: 0o700 }));
  return dirs;
}

function usage(exitCode = 0) {
  const text = `Communication Assistant Outbox

Usage:
  node scripts/outbox.js paths
  node scripts/outbox.js create --platform wechat --target "Alice" --message "..." [--context "..."] [--target-id "..."]
  node scripts/outbox.js list [--platform wechat] [--status drafted] [--json]
  node scripts/outbox.js show --id <id>
  node scripts/outbox.js mark --id <id> --status drafted|prefilled|sent|canceled
  node scripts/outbox.js cancel --id <id>

Platforms:
  wechat, whatsapp, qq, email, feishu
`;
  (exitCode === 0 ? console.log : console.error)(text);
  process.exit(exitCode);
}

function outboxPath(id) {
  return join(ensureDirs().outbox, `${id}.json`);
}

function readItem(id) {
  const path = outboxPath(id);
  if (!existsSync(path)) throw new Error(`Outbox item not found: ${id}`);
  return JSON.parse(readFileSync(path, 'utf8'));
}

function writeItem(item) {
  const path = outboxPath(item.id);
  const tmp = `${path}.tmp`;
  writeFileSync(tmp, `${JSON.stringify(item, null, 2)}\n`, { mode: 0o600 });
  renameSync(tmp, path);
}

function listItems(args) {
  const dirs = ensureDirs();
  const files = readdirSync(dirs.outbox).filter(name => name.endsWith('.json'));
  const items = files
    .map(name => JSON.parse(readFileSync(join(dirs.outbox, name), 'utf8')))
    .filter(item => !args.platform || item.platform === args.platform)
    .filter(item => !args.status || item.status === args.status)
    .sort((a, b) => b.createdAt.localeCompare(a.createdAt));

  if (args.json) {
    console.log(JSON.stringify(items, null, 2));
    return;
  }

  if (items.length === 0) {
    console.log('No outbox items found.');
    return;
  }

  items.forEach(item => {
    const preview = item.message.length > 100 ? `${item.message.slice(0, 100)}...` : item.message;
    console.log(`${item.id} [${item.platform}/${item.status}] ${item.target || '(no target)'}`);
    console.log(`  ${preview}`);
    if (item.context) console.log(`  context: ${item.context}`);
  });
}

function createItem(args) {
  const platform = String(args.platform || '').toLowerCase();
  const message = String(args.message || '');

  if (!ALLOWED_PLATFORMS.has(platform)) {
    throw new Error(`Invalid --platform. Use one of: ${Array.from(ALLOWED_PLATFORMS).join(', ')}`);
  }
  if (!message.trim()) {
    throw new Error('Missing required --message');
  }

  const now = new Date();
  const stamp = now.toISOString().replace(/[-:TZ.]/g, '').slice(0, 14);
  const random = crypto.randomBytes(4).toString('hex');
  const item = {
    id: `${stamp}-${platform}-${random}`,
    platform,
    target: args.target || '',
    targetId: args['target-id'] || '',
    message,
    context: args.context || '',
    status: 'drafted',
    createdAt: now.toISOString(),
    updatedAt: now.toISOString()
  };

  writeItem(item);
  console.log(JSON.stringify(item, null, 2));
}

function markItem(args) {
  const id = args.id;
  const status = args.status;
  if (!id) throw new Error('Missing required --id');
  if (!ALLOWED_STATUSES.has(status)) {
    throw new Error(`Invalid --status. Use one of: ${Array.from(ALLOWED_STATUSES).join(', ')}`);
  }

  const item = readItem(id);
  item.status = status;
  item.updatedAt = new Date().toISOString();
  writeItem(item);
  console.log(JSON.stringify(item, null, 2));
}

function showItem(args) {
  if (!args.id) throw new Error('Missing required --id');
  console.log(JSON.stringify(readItem(args.id), null, 2));
}

function main() {
  const args = minimist(process.argv.slice(2));
  const command = args._[0];

  try {
    switch (command) {
      case 'paths':
        console.log(JSON.stringify(ensureDirs(), null, 2));
        break;
      case 'create':
        createItem(args);
        break;
      case 'list':
        listItems(args);
        break;
      case 'show':
        showItem(args);
        break;
      case 'mark':
        markItem(args);
        break;
      case 'cancel':
        markItem({ ...args, status: 'canceled' });
        break;
      case 'help':
      case '--help':
      case undefined:
        usage(0);
        break;
      default:
        throw new Error(`Unknown command: ${command}`);
    }
  } catch (error) {
    console.error(`Error: ${error.message}`);
    process.exit(1);
  }
}

main();
