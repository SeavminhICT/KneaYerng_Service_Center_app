<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ $appName }} OTP</title>
  </head>
  <body style="margin:0;padding:0;background:#f5f7fb;color:#0f172a;font-family:Arial,sans-serif;">
    <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background:#f5f7fb;padding:28px 12px;">
      <tr>
        <td align="center">
          <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="max-width:520px;background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 12px 30px rgba(15,23,42,0.08);">
            <tr>
              <td style="padding:24px;">
                <div style="font-size:16px;color:#0f172a;line-height:1.6;">
                  Hello,
                </div>
                <div style="margin-top:12px;font-size:16px;color:#0f172a;line-height:1.6;">
                  Your verification code is:
                </div>
                <div style="margin:14px 0;padding:12px 16px;background:#f8fafc;border:1px solid #e2e8f0;border-radius:10px;text-align:center;">
                  <span style="font-size:26px;letter-spacing:4px;font-weight:700;color:#0f172a;">{{ $otpCode }}</span>
                </div>
                <div style="font-size:14px;color:#475569;line-height:1.6;">
                  This code will expire in {{ $expiresMinutes }} minutes.
                </div>
                <div style="margin-top:16px;font-size:14px;color:#475569;">
                  Thank you.
                </div>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </body>
</html>
