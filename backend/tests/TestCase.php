<?php

namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;
use PDO;
use RuntimeException;

abstract class TestCase extends BaseTestCase
{
    protected function setUp(): void
    {
        $this->configureTestingDatabase();

        parent::setUp();
    }

    private function configureTestingDatabase(): void
    {
        $connection = $this->environmentValue('DB_CONNECTION', 'sqlite');

        if ($connection === 'sqlite' && extension_loaded('pdo_sqlite')) {
            $this->setEnvironmentValue(
                'DB_DATABASE',
                $this->environmentValue('DB_DATABASE', ':memory:')
            );

            return;
        }

        if ($connection === 'sqlite' && ! extension_loaded('pdo_sqlite')) {
            if (! extension_loaded('pdo_mysql')) {
                throw new RuntimeException(
                    'Tests require either the pdo_sqlite or pdo_mysql PHP extension.'
                );
            }

            $this->configureMysqlTestingDatabase();

            return;
        }

        if (in_array($connection, ['mysql', 'mariadb'], true)) {
            $this->configureMysqlTestingDatabase();
        }
    }

    private function configureMysqlTestingDatabase(): void
    {
        $baseDatabase = $this->environmentValue('DB_DATABASE', 'laravel');
        $testDatabase = $this->environmentValue(
            'DB_TEST_DATABASE',
            str_ends_with($baseDatabase, '_test') ? $baseDatabase : $baseDatabase.'_test'
        );

        $this->setEnvironmentValue('DB_CONNECTION', 'mysql');
        $this->setEnvironmentValue('DB_DATABASE', $testDatabase);

        $host = $this->environmentValue('DB_HOST', '127.0.0.1');
        $port = $this->environmentValue('DB_PORT', '3306');
        $username = $this->environmentValue('DB_USERNAME', 'root');
        $password = $this->environmentValue('DB_PASSWORD', '');
        $charset = $this->environmentValue('DB_CHARSET', 'utf8mb4');

        $dsn = sprintf('mysql:host=%s;port=%s;charset=%s', $host, $port, $charset);
        $pdo = new PDO($dsn, $username, $password, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        ]);

        $quotedDatabase = str_replace('`', '``', $testDatabase);
        $pdo->exec("CREATE DATABASE IF NOT EXISTS `{$quotedDatabase}` CHARACTER SET {$charset} COLLATE utf8mb4_unicode_ci");
    }

    private function setEnvironmentValue(string $key, string $value): void
    {
        putenv("{$key}={$value}");
        $_ENV[$key] = $value;
        $_SERVER[$key] = $value;
    }

    private function environmentValue(string $key, string $default = ''): string
    {
        $value = env($key);
        if ($value !== null && $value !== false && $value !== '') {
            return (string) $value;
        }

        $dotenvValue = $this->dotenvValue($key);
        if ($dotenvValue !== null && $dotenvValue !== '') {
            return $dotenvValue;
        }

        return $default;
    }

    private function dotenvValue(string $key): ?string
    {
        static $values;

        if ($values === null) {
            $values = [];
            $baseDir = dirname(__DIR__);
            foreach ([$baseDir.'/.env.testing', $baseDir.'/.env'] as $path) {
                if (! is_file($path)) {
                    continue;
                }

                $parsed = parse_ini_file($path, false, INI_SCANNER_RAW);
                if (is_array($parsed)) {
                    $values = array_merge($values, $parsed);
                }
            }
        }

        $value = $values[$key] ?? null;
        if (! is_string($value)) {
            return null;
        }

        return trim($value, " \t\n\r\0\x0B\"'");
    }
}
