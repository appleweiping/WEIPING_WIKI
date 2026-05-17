#!/usr/bin/env node

import minimist from 'minimist';
import {
  getDefaultAccount,
  listAccounts,
  removeAccount,
  setDefaultAccount
} from './auth/auth-utils.js';

function printUsage() {
  console.log(`
Email Assistant Account Manager

Usage:
  node scripts/manage-accounts.js --list
  node scripts/manage-accounts.js --info
  node scripts/manage-accounts.js --set-default <id>
  node scripts/manage-accounts.js --remove <id>

Expected account IDs:
  umn
  vipinapple
`);
}

async function main() {
  const args = minimist(process.argv.slice(2));

  try {
    if (args.list || args.l) {
      const accounts = listAccounts();

      if (accounts.length === 0) {
        console.log('\nNo accounts configured.');
        console.log('Run: pnpm run setup -- --account umn --email <umn address>');
        console.log('Run: pnpm run setup -- --account vipinapple --email <personal address>\n');
        return;
      }

      console.log('\nConfigured Gmail Accounts:\n');
      accounts.forEach(acc => {
        const marker = acc.isDefault ? '*' : ' ';
        console.log(`${marker} ${acc.id}`);
        console.log(`  Email: ${acc.email}`);
        console.log(`  Scopes: ${acc.scope}`);
        console.log('');
      });

      console.log(`Total accounts: ${accounts.length}`);
      console.log(`Default: ${accounts.find(a => a.isDefault)?.id || 'none'}\n`);
      return;
    }

    if (args.info || args.i) {
      const accounts = listAccounts();
      const defaultId = getDefaultAccount();

      console.log('\nAccount Information:\n');
      console.log(JSON.stringify({
        totalAccounts: accounts.length,
        defaultAccount: defaultId,
        accounts
      }, null, 2));
      console.log('');
      return;
    }

    if (args['set-default']) {
      const accountId = args['set-default'];
      setDefaultAccount(accountId);
      console.log(`\nDefault account set to: ${accountId}\n`);
      return;
    }

    if (args.remove) {
      const accountId = args.remove;
      const accounts = listAccounts();
      const account = accounts.find(a => a.id === accountId);

      if (!account) {
        console.error(`\nAccount '${accountId}' not found.\n`);
        process.exit(1);
      }

      if (account.isDefault && accounts.length > 1) {
        console.log(`\nRemoving default account '${accountId}'.`);
        console.log('A new default will be automatically assigned.\n');
      }

      removeAccount(accountId);
      console.log(`Account '${accountId}' (${account.email}) removed.\n`);

      const remaining = listAccounts();
      if (remaining.length > 0) {
        console.log('Remaining accounts:');
        remaining.forEach(acc => {
          const marker = acc.isDefault ? '*' : ' ';
          console.log(`${marker} ${acc.id} (${acc.email})`);
        });
        console.log('');
      }

      return;
    }

    printUsage();
  } catch (error) {
    console.error(`\nError: ${error.message}\n`);
    process.exit(1);
  }
}

main();
