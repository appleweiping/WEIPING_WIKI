#!/usr/bin/env node

import { appendFileSync, existsSync, mkdirSync } from 'fs';
import { dirname, join } from 'path';
import { getLogDir } from './auth/paths.js';

const LOG_FILE = join(getLogDir(), 'action-log.jsonl');

function ensureLogDirectory() {
  const logDir = dirname(LOG_FILE);
  if (!existsSync(logDir)) {
    mkdirSync(logDir, { recursive: true, mode: 0o700 });
  }
}

export function logAction(action, params, result, metadata = {}) {
  ensureLogDirectory();

  const logEntry = {
    timestamp: new Date().toISOString(),
    action,
    params: sanitizeParams(params),
    result: sanitizeResult(result),
    metadata: {
      ...metadata,
      skill: 'email-assistant'
    }
  };

  try {
    appendFileSync(LOG_FILE, `${JSON.stringify(logEntry)}\n`, 'utf8');
  } catch (error) {
    console.error('Warning: failed to write email-assistant action log:', error.message);
  }
}

function sanitizeParams(params) {
  const sanitized = { ...params };
  const sensitiveFields = [
    'password',
    'token',
    'access_token',
    'refresh_token',
    'body',
    'html',
    'message',
    'raw'
  ];

  sensitiveFields.forEach(field => {
    if (Object.hasOwn(sanitized, field)) {
      sanitized[field] = '[REDACTED]';
    }
  });

  Object.keys(sanitized).forEach(key => {
    if (typeof sanitized[key] === 'string' && sanitized[key].length > 160) {
      sanitized[key] = `${sanitized[key].substring(0, 160)}... [truncated]`;
    }
  });

  return sanitized;
}

function sanitizeResult(result) {
  const sanitized = { ...result };

  if (sanitized.messages && Array.isArray(sanitized.messages)) {
    sanitized.messageCount = sanitized.messages.length;
    sanitized.messageSummary = sanitized.messages.slice(0, 3).map(msg => ({
      id: msg.id,
      threadId: msg.threadId,
      from: msg.from,
      subject: msg.subject,
      date: msg.date,
      labels: msg.labels
    }));
    delete sanitized.messages;
  }

  if (sanitized.labels && Array.isArray(sanitized.labels)) {
    sanitized.labelCount = sanitized.labels.length;
    sanitized.labelNames = sanitized.labels.map(l => l.name || l.id).slice(0, 10);
    delete sanitized.labels;
  }

  delete sanitized.body;
  delete sanitized.html;
  delete sanitized.raw;
  delete sanitized.thread;
  delete sanitized.snippet;

  if (sanitized.error && sanitized.error.length > 500) {
    sanitized.error = `${sanitized.error.substring(0, 500)}... [truncated]`;
  }

  return sanitized;
}

export function getLogFilePath() {
  return LOG_FILE;
}
