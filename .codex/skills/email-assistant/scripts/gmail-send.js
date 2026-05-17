#!/usr/bin/env node

import { google } from 'googleapis';
import minimist from 'minimist';
import { getAuthClient, parseAccountArg } from './auth/auth-utils.js';
import { logAction } from './action-logger.js';
import { createEmailMessage } from './email-message.js';

async function sendEmail(args) {
  if (args['confirm-send'] !== 'YES_SEND') {
    throw new Error('Refusing to send without --confirm-send YES_SEND. Create a draft first unless the user explicitly approved sending.');
  }

  // Validate required args
  if (!args.to || !args.subject || !args.body) {
    throw new Error('Missing required arguments: --to, --subject, and --body are required');
  }

  // Get authenticated client for specified account (or default)
  const accountId = parseAccountArg(args);
  const oauth2Client = await getAuthClient(accountId);

  const gmail = google.gmail({ version: 'v1', auth: oauth2Client });

  // Create email
  const encodedMessage = createEmailMessage(
    args.to,
    args.subject,
    args.body,
    {
      cc: args.cc,
      bcc: args.bcc,
      html: args.html,
      replyTo: args['reply-to']
    }
  );

  // Send email
  const result = await gmail.users.messages.send({
    userId: 'me',
    requestBody: {
      raw: encodedMessage
    }
  });

  return {
    success: true,
    messageId: result.data.id,
    threadId: result.data.threadId,
    to: args.to,
    subject: args.subject,
    account: accountId || 'default'
  };
}

// Main execution
const args = minimist(process.argv.slice(2));
const startTime = Date.now();

sendEmail(args)
  .then(result => {
    // Log the action
    logAction('send', args, result, {
      account: result.account,
      duration: Date.now() - startTime
    });

    console.log(JSON.stringify(result, null, 2));
  })
  .catch(error => {
    const errorResult = {
      success: false,
      error: error.message
    };

    // Log the failed action
    logAction('send', args, errorResult, {
      account: args.account || 'default',
      duration: Date.now() - startTime,
      failed: true
    });

    console.error(JSON.stringify(errorResult, null, 2));
    process.exit(1);
  });
