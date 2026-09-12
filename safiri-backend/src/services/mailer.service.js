const nodemailer = require('nodemailer');

let transporter = null;

function getTransporter() {
  if (transporter) return transporter;

  const host = process.env.SMTP_HOST;
  const user = process.env.SMTP_USER;
  const pass = process.env.SMTP_PASS;
  const port = parseInt(process.env.SMTP_PORT || '587', 10);

  if (!host || !user || !pass) {
    return null;
  }

  transporter = nodemailer.createTransport({
    host,
    port,
    secure: port === 465,
    auth: { user, pass },
    tls: {
      rejectUnauthorized: false,
    },
  });

  return transporter;
}

async function sendOtpEmail({ to, code, type, name }) {
  const mailTransporter = getTransporter();
  const isSignup = type === 'signup';
  const actionTitle = isSignup ? 'Confirm Your Account' : 'Reset Your Password';
  const actionDescription = isSignup
    ? 'Thank you for choosing Safiri Holidays. Please use the 6-digit confirmation code below to complete your account registration.'
    : 'We received a request to reset your Safiri Holidays account password. Please use the confirmation code below to proceed.';

  if (!mailTransporter) {
    console.warn('====================================================');
    console.warn('[MAILER NOTICE] SMTP credentials not configured!');
    console.warn('  To send real emails to inboxes, set in .env / Railway:');
    console.warn('  SMTP_HOST=smtp.gmail.com');
    console.warn('  SMTP_PORT=587');
    console.warn('  SMTP_USER=your_email@gmail.com');
    console.warn('  SMTP_PASS=your_google_app_password');
    console.warn('  OTP Code for ' + to + ' is: ' + code);
    console.warn('====================================================');
    return {
      delivered: false,
      reason: 'SMTP not configured on server',
      code,
    };
  }

  const fromAddress = process.env.SMTP_FROM || ('"Safiri Holidays" <' + process.env.SMTP_USER + '>');

  const htmlContent = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${actionTitle} - Safiri Holidays</title>
</head>
<body style="margin: 0; padding: 0; background-color: #f4f6f9; font-family: 'Montserrat', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color: #f4f6f9; padding: 40px 15px;">
    <tr>
      <td align="center">
        <table width="100%" cellpadding="0" cellspacing="0" border="0" style="max-width: 540px; background-color: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.08);">
          <tr>
            <td align="center" style="background: linear-gradient(135deg, #0D1B2A 0%, #1B3B6F 100%); padding: 36px 24px;">
              <h1 style="margin: 0; color: #ffffff; font-size: 24px; font-weight: 800; letter-spacing: 2px; text-transform: uppercase;">
                SAFIRI HOLIDAYS
              </h1>
              <p style="margin: 6px 0 0 0; color: #C5A059; font-size: 13px; font-weight: 600; letter-spacing: 1px;">
                LUXURY TRAVEL &amp; CONCIERGE
              </p>
            </td>
          </tr>
          <tr>
            <td style="padding: 36px 32px;">
              <h2 style="margin: 0 0 16px 0; color: #0D1B2A; font-size: 20px; font-weight: 700;">
                ${actionTitle}
              </h2>
              <p style="margin: 0 0 24px 0; color: #4A5568; font-size: 14px; line-height: 1.6;">
                Hello ${name || 'Traveler'},
              </p>
              <p style="margin: 0 0 28px 0; color: #4A5568; font-size: 14px; line-height: 1.6;">
                ${actionDescription}
              </p>
              <table width="100%" cellpadding="0" cellspacing="0" border="0" style="margin-bottom: 28px;">
                <tr>
                  <td align="center" style="background-color: #F8FAFC; border: 2px dashed #CBD5E1; border-radius: 12px; padding: 24px 16px;">
                    <span style="display: block; color: #64748B; font-size: 12px; font-weight: 700; letter-spacing: 1.5px; text-transform: uppercase; margin-bottom: 8px;">
                      Verification Code
                    </span>
                    <span style="display: inline-block; color: #0D1B2A; font-size: 36px; font-weight: 800; letter-spacing: 8px; font-family: 'Courier New', monospace;">
                      ${code}
                    </span>
                  </td>
                </tr>
              </table>
              <p style="margin: 0 0 12px 0; color: #64748B; font-size: 12px; line-height: 1.5;">
                This code is valid for 10 minutes. Never share this code with anyone.
              </p>
              <p style="margin: 0; color: #94A3B8; font-size: 12px; line-height: 1.5;">
                If you did not make this request, you can safely ignore this email.
              </p>
            </td>
          </tr>
          <tr>
            <td style="background-color: #F8FAFC; padding: 20px 32px; border-top: 1px solid #E2E8F0; text-align: center;">
              <p style="margin: 0 0 4px 0; color: #94A3B8; font-size: 11px;">
                Safiri Holidays Ltd. Kigali, Rwanda. All rights reserved.
              </p>
              <p style="margin: 0; color: #94A3B8; font-size: 11px;">
                Need assistance? Contact us at support@safiriholidays.com
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
`;

  try {
    const info = await mailTransporter.sendMail({
      from: fromAddress,
      to,
      subject: `${code} is your Safiri Holidays verification code`,
      text: `Your Safiri Holidays verification code is: ${code}. It expires in 10 minutes.`,
      html: htmlContent,
    });

    console.log('[EMAIL DELIVERED SUCCESS] Message ID:', info.messageId, 'To:', to);
    return { delivered: true, messageId: info.messageId };
  } catch (err) {
    console.error('[EMAIL DISPATCH ERROR]', err.message);
    return { delivered: false, error: err.message };
  }
}

module.exports = { sendOtpEmail };
