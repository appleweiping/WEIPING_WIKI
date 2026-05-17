export function createEmailMessage(to, subject, body, options = {}) {
  const { cc, bcc, html, replyTo } = options;

  const headers = [
    `To: ${to}`,
    `Subject: ${subject}`,
  ];

  if (cc) headers.push(`Cc: ${cc}`);
  if (bcc) headers.push(`Bcc: ${bcc}`);
  if (replyTo) headers.push(`Reply-To: ${replyTo}`);

  headers.push('Content-Type: text/html; charset=utf-8');
  headers.push('');

  const message = headers.join('\r\n') + (html || body);

  return Buffer.from(message)
    .toString('base64')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '');
}
