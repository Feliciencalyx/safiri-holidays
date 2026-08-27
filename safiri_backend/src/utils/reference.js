import { randomUUID } from 'crypto';

export function generatePaymentReference() {
  const timestamp = Date.now();
  const suffix = randomUUID().replace(/-/g, '').substring(0, 8).toUpperCase();
  return `SH-${timestamp}-${suffix}`;
}
