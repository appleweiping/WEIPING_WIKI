#!/usr/bin/env node

import { google } from 'googleapis';
import { createServer } from 'http';
import { parse } from 'url';
import open from 'open';
import { existsSync, readFileSync } from 'fs';
import minimist from 'minimist';
import readline from 'readline';
import { listAccounts, saveTokens } from './auth-utils.js';
import { getAuthDir, getCredentialsPath } from './paths.js';

const CREDENTIALS_PATH = getCredentialsPath();
const REDIRECT_URI = 'http://localhost:3000/oauth2callback';
const SCOPES = [
  'https://www.googleapis.com/auth/gmail.modify',
  'https://www.googleapis.com/auth/gmail.compose',
  'https://www.googleapis.com/auth/gmail.send'
];

function promptEmail() {
  return new Promise((resolve) => {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });

    rl.question('Enter the email address for this account: ', (email) => {
      rl.close();
      resolve(email.trim());
    });
  });
}

async function setupOAuth(accountId, userEmail = null) {
  console.log('\nEmail Assistant OAuth Setup\n');

  if (accountId) {
    console.log(`Setting up account: ${accountId}\n`);
  }

  if (!existsSync(CREDENTIALS_PATH)) {
    console.error('Error: credentials.json not found.');
    console.log('\nPlease follow these steps:');
    console.log('1. Go to: https://console.cloud.google.com/');
    console.log('2. Create or select a project.');
    console.log('3. Enable Gmail API.');
    console.log('4. Create OAuth 2.0 credentials for a Desktop app.');
    console.log('5. Download credentials.json.');
    console.log(`6. Save it to: ${CREDENTIALS_PATH}\n`);
    console.log(`Auth directory: ${getAuthDir()}`);
    console.log('See docs/google-cloud-setup.md for detailed instructions.\n');
    process.exit(1);
  }

  const credentials = JSON.parse(readFileSync(CREDENTIALS_PATH, 'utf8'));
  const { client_id, client_secret } = credentials.installed || credentials.web;

  const oauth2Client = new google.auth.OAuth2(
    client_id,
    client_secret,
    REDIRECT_URI
  );

  const authUrl = oauth2Client.generateAuthUrl({
    access_type: 'offline',
    scope: SCOPES,
    prompt: 'consent'
  });

  console.log('Opening browser for authorization.');
  console.log("If the browser does not open, visit this URL:\n");
  console.log(`${authUrl}\n`);

  const email = userEmail || await promptEmail();

  const server = createServer(async (req, res) => {
    if (req.url.indexOf('/oauth2callback') === -1) return;

    const qs = parse(req.url, true).query;
    const code = qs.code;

    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end('Authorization successful. You can close this window and return to the terminal.');
    server.close();

    try {
      const { tokens } = await oauth2Client.getToken(code);
      const targetAccountId = accountId || 'default';
      saveTokens(targetAccountId, tokens, email);

      const accounts = listAccounts();

      console.log('\nSuccess. Tokens saved for account:', targetAccountId);
      console.log(`Email: ${email}`);
      console.log('\nAll configured accounts:');
      accounts.forEach(acc => {
        const marker = acc.isDefault ? '*' : ' ';
        console.log(`${marker} ${acc.id} (${acc.email})`);
      });

      console.log('\nYou can now use the email-assistant skill.\n');
      console.log('Next steps:');
      console.log('   - Add UMN: npm run setup -- --account umn --email <umn address>');
      console.log('   - Add vipinapple: npm run setup -- --account vipinapple --email <personal address>');
      console.log('   - List accounts: node scripts/manage-accounts.js --list\n');
    } catch (error) {
      console.error('\nError exchanging code for tokens:', error.message);
      process.exit(1);
    }
  }).listen(3000, () => {
    open(authUrl);
  });
}

const args = minimist(process.argv.slice(2));
const accountId = args.account || null;
const email = args.email || null;

setupOAuth(accountId, email).catch(error => {
  console.error(error.message);
  process.exit(1);
});
