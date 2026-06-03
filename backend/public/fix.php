<?php
/**
 * ONE-TIME FIX SCRIPT — delete this file after running it once.
 * Access it at: https://kneayerng.seavminh.com/fix.php
 */

// Basic protection — only run from the same server or with a secret key
$secret = 'kysc_fix_2025';
if (($_GET['key'] ?? '') !== $secret) {
    http_response_code(403);
    die('<h2>403 Forbidden</h2><p>Add ?key=kysc_fix_2025 to the URL.</p>');
}

$basePath = dirname(__DIR__);
$envPath  = $basePath . '/.env';

$log = [];

// ── 1. Fix .env ────────────────────────────────────────────────────────────
if (!file_exists($envPath)) {
    die('<b>ERROR:</b> .env file not found at ' . htmlspecialchars($envPath));
}

$env = file_get_contents($envPath);

$fixes = [
    // Fix APP_URL
    '/^APP_URL=.*/m'                    => 'APP_URL=https://kneayerng.seavminh.com',
    // Fix APP_ENV
    '/^APP_ENV=.*/m'                    => 'APP_ENV=production',
    // Fix APP_DEBUG
    '/^APP_DEBUG=.*/m'                  => 'APP_DEBUG=false',
    // Fix AWS_URL to use production domain
    '/^AWS_URL=.*/m'                    => 'AWS_URL=https://kneayerng.seavminh.com/api/media',
    // Fix R2 path-style endpoint (required for Cloudflare R2)
    '/^AWS_USE_PATH_STYLE_ENDPOINT=.*/m' => 'AWS_USE_PATH_STYLE_ENDPOINT=true',
    // Disable SSL verify (avoids handshake issues inside containers)
    '/^AWS_SSL_VERIFY=.*/m'             => 'AWS_SSL_VERIFY=false',
    // Fix session domain
    '/^SESSION_DOMAIN=.*/m'             => 'SESSION_DOMAIN=null',
    // Fix session secure cookie
    '/^SESSION_SECURE_COOKIE=.*/m'      => 'SESSION_SECURE_COOKIE=false',
    // Fix Firebase credentials path
    '/^FIREBASE_CREDENTIALS=C:\\\\.*$/m' => 'FIREBASE_CREDENTIALS=/var/www/html/storage/app/firebase-credentials.json',
];

foreach ($fixes as $pattern => $replacement) {
    $new = preg_replace($pattern, $replacement, $env);
    if ($new !== $env) {
        $log[] = '✅ Fixed: ' . $replacement;
        $env = $new;
    }
}

file_put_contents($envPath, $env);
$log[] = '✅ .env saved';

// ── 2. Run artisan commands ─────────────────────────────────────────────────
$artisan = $basePath . '/artisan';

$commands = [
    'config:clear',
    'config:cache',
    'route:clear',
    'route:cache',
    'view:clear',
];

foreach ($commands as $cmd) {
    $output = shell_exec("cd " . escapeshellarg($basePath) . " && php artisan $cmd 2>&1");
    $log[] = "✅ php artisan $cmd<br><pre>" . htmlspecialchars((string)$output) . "</pre>";
}

// ── 3. Run seeder to ensure admin user exists ───────────────────────────────
$output = shell_exec("cd " . escapeshellarg($basePath) . " && php artisan db:seed --force 2>&1");
$log[] = "✅ php artisan db:seed --force<br><pre>" . htmlspecialchars((string)$output) . "</pre>";

// ── 4. Run migrations ───────────────────────────────────────────────────────
$output = shell_exec("cd " . escapeshellarg($basePath) . " && php artisan migrate --force 2>&1");
$log[] = "✅ php artisan migrate --force<br><pre>" . htmlspecialchars((string)$output) . "</pre>";

?><!DOCTYPE html>
<html>
<head>
  <title>Fix Applied</title>
  <style>
    body { font-family: monospace; background: #1a1a2e; color: #00ff88; padding: 30px; }
    h1 { color: #00d4ff; }
    pre { background: #0d1117; padding: 8px; border-radius: 4px; font-size: 12px; }
    .warn { color: #ffaa00; margin-top: 30px; border: 1px solid #ffaa00; padding: 15px; border-radius: 8px; }
  </style>
</head>
<body>
  <h1>✅ Fix Complete</h1>
  <?php foreach ($log as $line) echo "<p>$line</p>"; ?>
  <div class="warn">
    ⚠️ <strong>DELETE this file now!</strong><br>
    Remove <code>public/fix.php</code> from your server immediately for security.
  </div>
</body>
</html>
