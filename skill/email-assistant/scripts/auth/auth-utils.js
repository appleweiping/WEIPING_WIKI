#!/usr/bin/env node

import { google } from 'googleapis';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import { getCredentialsPath, getTokenPath } from './paths.js';

const TOKEN_PATH = getTokenPath();
const CREDENTIALS_PATH = getCredentialsPath();

export function loadTokenConfig() {
  if (!existsSync(TOKEN_PATH)) {
    return {
      defaultAccount: null,
      accounts: {}
    };
  }

  const content = readFileSync(TOKEN_PATH, 'utf8');
  const data = JSON.parse(content);

  if (data.access_token && !data.accounts) {
    const migratedConfig = {
      defaultAccount: 'default',
      accounts: {
        default: data
      }
    };
    saveTokenConfig(migratedConfig);
    return migratedConfig;
  }

  if (!data.accounts) data.accounts = {};
  if (!Object.hasOwn(data, 'defaultAccount')) data.defaultAccount = null;
  return data;
}

export function saveTokenConfig(config) {
  writeFileSync(TOKEN_PATH, JSON.stringify(config, null, 2), { mode: 0o600 });
}

export function getDefaultAccount() {
  const config = loadTokenConfig();
  return config.defaultAccount || Object.keys(config.accounts)[0] || null;
}

export function setDefaultAccount(accountId) {
  const config = loadTokenConfig();
  if (!config.accounts[accountId]) {
    throw new Error(`Account '${accountId}' not found`);
  }
  config.defaultAccount = accountId;
  saveTokenConfig(config);
}

export function listAccounts() {
  const config = loadTokenConfig();
  return Object.entries(config.accounts).map(([id, data]) => ({
    id,
    email: data.email || 'unknown',
    scope: data.scope || '',
    isDefault: id === config.defaultAccount
  }));
}

export function loadTokens(accountId = null) {
  const config = loadTokenConfig();
  const targetAccount = accountId || config.defaultAccount;

  if (!targetAccount || !config.accounts[targetAccount]) {
    const available = Object.keys(config.accounts).join(', ') || 'none';
    throw new Error(
      `Account '${targetAccount || 'default'}' not found. Available accounts: ${available}. Run: pnpm run setup -- --account umn or pnpm run setup -- --account vipinapple`
    );
  }

  return config.accounts[targetAccount];
}

export function saveTokens(accountId, tokens, email = null) {
  const config = loadTokenConfig();

  const existingEmail = config.accounts[accountId]?.email;
  config.accounts[accountId] = {
    ...tokens,
    ...(email && { email }),
    ...(!email && existingEmail && { email: existingEmail })
  };

  if (!config.defaultAccount || Object.keys(config.accounts).length === 1) {
    config.defaultAccount = accountId;
  }

  saveTokenConfig(config);
}

export function removeAccount(accountId) {
  const config = loadTokenConfig();

  if (!config.accounts[accountId]) {
    throw new Error(`Account '${accountId}' not found`);
  }

  delete config.accounts[accountId];

  if (config.defaultAccount === accountId) {
    const remaining = Object.keys(config.accounts);
    config.defaultAccount = remaining.length > 0 ? remaining[0] : null;
  }

  saveTokenConfig(config);
}

function needsRefresh(tokens) {
  if (!tokens.expiry_date) return false;
  const expiryTime = new Date(tokens.expiry_date);
  const now = new Date();
  const fiveMinutes = 5 * 60 * 1000;
  return (expiryTime - now) < fiveMinutes;
}

export async function refreshTokenIfNeeded(accountId = null) {
  const tokens = loadTokens(accountId);
  const targetAccount = accountId || getDefaultAccount();

  if (!needsRefresh(tokens)) {
    return tokens;
  }

  if (!tokens.refresh_token) {
    throw new Error(`No refresh token available for account '${targetAccount}'. Please re-authenticate.`);
  }

  if (!existsSync(CREDENTIALS_PATH)) {
    throw new Error(`Credentials file not found at ${CREDENTIALS_PATH}`);
  }

  const credentials = JSON.parse(readFileSync(CREDENTIALS_PATH, 'utf8'));
  const { client_id, client_secret } = credentials.installed || credentials.web;

  const oauth2Client = new google.auth.OAuth2(client_id, client_secret);
  oauth2Client.setCredentials(tokens);

  try {
    const { credentials: newTokens } = await oauth2Client.refreshAccessToken();
    const refreshedTokens = {
      access_token: newTokens.access_token,
      refresh_token: newTokens.refresh_token || tokens.refresh_token,
      scope: newTokens.scope || tokens.scope,
      token_type: newTokens.token_type || 'Bearer',
      expiry_date: newTokens.expiry_date
    };

    saveTokens(targetAccount, refreshedTokens);
    return refreshedTokens;
  } catch (error) {
    throw new Error(`Failed to refresh token for account '${targetAccount}': ${error.message}`);
  }
}

export async function getAuthClient(accountId = null) {
  const tokens = await refreshTokenIfNeeded(accountId);

  if (!existsSync(CREDENTIALS_PATH)) {
    throw new Error(`Credentials file not found at ${CREDENTIALS_PATH}`);
  }

  const credentials = JSON.parse(readFileSync(CREDENTIALS_PATH, 'utf8'));
  const { client_id, client_secret } = credentials.installed || credentials.web;

  const oauth2Client = new google.auth.OAuth2(client_id, client_secret);
  oauth2Client.setCredentials(tokens);

  return oauth2Client;
}

export function parseAccountArg(args) {
  return args.account || null;
}
