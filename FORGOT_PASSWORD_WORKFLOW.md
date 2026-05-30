# Forgot Password Workflow

This flow resets a mobile user's password with either phone number or email.
The mobile app never calls UniMTX directly. It only calls the Laravel API.

## Mobile Flow

1. Login screen opens `ForgotPasswordScreen`.
2. User selects Phone or Email and enters an identifier.
3. App validates:
   - required value
   - email format: `name@example.com`
   - phone format: 8-15 digits, allowing spaces, dashes, and `+`
4. App calls `POST /api/auth/forgot-password/send-otp`.
5. On success, app navigates to `OtpVerifyScreen`.
6. User enters the 6-digit OTP.
7. App calls `POST /api/auth/forgot-password/verify-otp`.
8. On success, backend returns `resetPasswordToken`.
9. App navigates to `ResetPasswordNewScreen`.
10. User enters and confirms the new password.
11. App calls `POST /api/auth/forgot-password/reset-password`.
12. On success, app returns to Login and shows:
    `Password reset successfully. Please login.`

## API Endpoints

Base path: `/api`

### Send OTP

`POST /auth/forgot-password/send-otp`

Request:

```json
{
  "identifier": "+85512345678"
}
```

or:

```json
{
  "identifier": "customer@example.com"
}
```

Success response:

```json
{
  "message": "If this account exists, an OTP was sent.",
  "expiresInSec": 300,
  "expires_in_sec": 300,
  "resendInSec": 60,
  "resend_in_sec": 60
}
```

Validation error:

```json
{
  "message": "Enter a valid phone number or email address.",
  "errors": {
    "identifier": ["Enter a valid phone number or email address."]
  }
}
```

### Verify OTP

`POST /auth/forgot-password/verify-otp`

Request:

```json
{
  "identifier": "+85512345678",
  "otp": "123456"
}
```

Success response:

```json
{
  "message": "OTP verified. You can reset your password.",
  "resetPasswordToken": "secure-token",
  "reset_token": "secure-token",
  "expiresInSec": 900,
  "expires_in_sec": 900
}
```

Wrong OTP:

```json
{
  "message": "Invalid OTP. Please try again."
}
```

Expired OTP:

```json
{
  "message": "OTP expired. Please request a new code."
}
```

Too many attempts:

```json
{
  "message": "Too many invalid attempts. Please request a new code."
}
```

### Reset Password

`POST /auth/forgot-password/reset-password`

Request:

```json
{
  "resetPasswordToken": "secure-token",
  "newPassword": "NewPassword123!"
}
```

Success response:

```json
{
  "message": "Password reset successfully. Please login."
}
```

Invalid or expired reset token:

```json
{
  "message": "Invalid or expired reset token."
}
```

## Backend Logic

- `ForgotPasswordController@sendOtp`
  - detects whether `identifier` is email or phone
  - checks if the user exists
  - returns a neutral success response if not found
  - generates a 6-digit OTP when found
  - stores only the hashed OTP in `otp_verifications`
  - sends phone OTP through backend UniMTX SMS
  - sends email OTP through Laravel mail

- `ForgotPasswordController@verifyOtp`
  - verifies the hashed OTP
  - enforces expiry and max attempt rules
  - marks the OTP as used
  - returns a short-lived `resetPasswordToken`

- `ForgotPasswordController@resetPassword`
  - verifies `resetPasswordToken`
  - hashes and updates the new password
  - deletes the reset token
  - deletes the used forgot-password OTP rows

## Security Rules

- OTPs are generated and sent only by the backend.
- OTP hashes are saved with HMAC SHA-256 using `APP_KEY`.
- OTP expiry defaults to `OTP_TTL_SECONDS=300`.
- Resend cooldown defaults to `OTP_RESEND_COOLDOWN_SECONDS=60`.
- Verify attempts default to `OTP_MAX_ATTEMPTS=5`.
- Request rate limits are enforced per IP and destination.
- Reset tokens are stored in cache using a hashed cache key.
- UniMTX API credentials stay in backend environment variables only.

## UniMTX Configuration

Set these in `backend/.env`:

```env
UNIMATRIX_BASE_URL=https://api.unimtx.com
UNIMATRIX_ACCESS_KEY_ID=your_access_key_id
UNIMATRIX_ACCESS_KEY_SECRET=your_access_key_secret
UNIMATRIX_SIGNATURE=YourSenderName
UNIMATRIX_TIMEOUT=15
UNIMATRIX_VERIFY=true
```

The backend sends phone OTPs using UniMTX `otp.send` with the backend-generated
custom code and TTL. Generic SMS fallback still uses `sms.message.send`, but the
forgot-password OTP path does not require a custom SMS template.
