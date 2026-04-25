<?php

namespace App\Services;

use InvalidArgumentException;

class KhqrGenerator
{
    private const EMV = [
        'payloadFormatIndicator' => '00',
        'defaultPayloadFormatIndicator' => '01',
        'pointOfInitiationMethod' => '01',
        'staticQR' => '11',
        'dynamicQR' => '12',
        'merchantAccountInformationIndividual' => '29',
        'merchantAccountInformationMerchant' => '30',
        'bakongAccountIdentifier' => '00',
        'merchantAccountInformationMerchantId' => '01',
        'individualAccountInformation' => '01',
        'merchantAccountInformationAcquiringBank' => '02',
        'merchantCategoryCode' => '52',
        'defaultMerchantCategoryCode' => '5999',
        'transactionCurrency' => '53',
        'transactionAmount' => '54',
        'countryCode' => '58',
        'defaultCountryCode' => 'KH',
        'merchantName' => '59',
        'merchantCity' => '60',
        'defaultMerchantCity' => 'Phnom Penh',
        'additionalDataTag' => '62',
        'billNumberTag' => '01',
        'additionalDataFieldMobileNumber' => '02',
        'storeLabelTag' => '03',
        'terminalTag' => '07',
        'purposeOfTransaction' => '08',
        'timestampTag' => '99',
        'creationTimestamp' => '00',
        'expirationTimestamp' => '01',
        'crc' => '63',
        'crcLength' => '04',
    ];

    private const INVALID_LENGTH = [
        'khqr' => 12,
        'merchantName' => 25,
        'bakongAccount' => 32,
        'amount' => 13,
        'countryCode' => 3,
        'merchantCategoryCode' => 4,
        'merchantCity' => 15,
        'timestamp' => 13,
        'transactionAmount' => 14,
        'transactionCurrency' => 3,
        'billNumber' => 25,
        'storeLabel' => 25,
        'terminalLabel' => 25,
        'purposeOfTransaction' => 25,
        'merchantId' => 32,
        'acquiringBank' => 32,
        'mobileNumber' => 25,
        'accountInformation' => 32,
    ];

    private const CRC_TABLE = [
        0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50A5, 0x60C6, 0x70E7,
        0x8108, 0x9129, 0xA14A, 0xB16B, 0xC18C, 0xD1AD, 0xE1CE, 0xF1EF,
        0x1231, 0x0210, 0x3273, 0x2252, 0x52B5, 0x4294, 0x72F7, 0x62D6,
        0x9339, 0x8318, 0xB37B, 0xA35A, 0xD3BD, 0xC39C, 0xF3FF, 0xE3DE,
        0x2462, 0x3443, 0x0420, 0x1401, 0x64E6, 0x74C7, 0x44A4, 0x5485,
        0xA56A, 0xB54B, 0x8528, 0x9509, 0xE5EE, 0xF5CF, 0xC5AC, 0xD58D,
        0x3653, 0x2672, 0x1611, 0x0630, 0x76D7, 0x66F6, 0x5695, 0x46B4,
        0xB75B, 0xA77A, 0x9719, 0x8738, 0xF7DF, 0xE7FE, 0xD79D, 0xC7BC,
        0x48C4, 0x58E5, 0x6886, 0x78A7, 0x0840, 0x1861, 0x2802, 0x3823,
        0xC9CC, 0xD9ED, 0xE98E, 0xF9AF, 0x8948, 0x9969, 0xA90A, 0xB92B,
        0x5AF5, 0x4AD4, 0x7AB7, 0x6A96, 0x1A71, 0x0A50, 0x3A33, 0x2A12,
        0xDBFD, 0xCBDC, 0xFBBF, 0xEB9E, 0x9B79, 0x8B58, 0xBB3B, 0xAB1A,
        0x6CA6, 0x7C87, 0x4CE4, 0x5CC5, 0x2C22, 0x3C03, 0x0C60, 0x1C41,
        0xEDAE, 0xFD8F, 0xCDEC, 0xDDCD, 0xAD2A, 0xBD0B, 0x8D68, 0x9D49,
        0x7E97, 0x6EB6, 0x5ED5, 0x4EF4, 0x3E13, 0x2E32, 0x1E51, 0x0E70,
        0xFF9F, 0xEFBE, 0xDFDD, 0xCFFC, 0xBF1B, 0xAF3A, 0x9F59, 0x8F78,
        0x9188, 0x81A9, 0xB1CA, 0xA1EB, 0xD10C, 0xC12D, 0xF14E, 0xE16F,
        0x1080, 0x00A1, 0x30C2, 0x20E3, 0x5004, 0x4025, 0x7046, 0x6067,
        0x83B9, 0x9398, 0xA3FB, 0xB3DA, 0xC33D, 0xD31C, 0xE37F, 0xF35E,
        0x02B1, 0x1290, 0x22F3, 0x32D2, 0x4235, 0x5214, 0x6277, 0x7256,
        0xB5EA, 0xA5CB, 0x95A8, 0x8589, 0xF56E, 0xE54F, 0xD52C, 0xC50D,
        0x34E2, 0x24C3, 0x14A0, 0x0481, 0x7466, 0x6447, 0x5424, 0x4405,
        0xA7DB, 0xB7FA, 0x8799, 0x97B8, 0xE75F, 0xF77E, 0xC71D, 0xD73C,
        0x26D3, 0x36F2, 0x0691, 0x16B0, 0x6657, 0x7676, 0x4615, 0x5634,
        0xD94C, 0xC96D, 0xF90E, 0xE92F, 0x99C8, 0x89E9, 0xB98A, 0xA9AB,
        0x5844, 0x4865, 0x7806, 0x6827, 0x18C0, 0x08E1, 0x3882, 0x28A3,
        0xCB7D, 0xDB5C, 0xEB3F, 0xFB1E, 0x8BF9, 0x9BD8, 0xABBB, 0xBB9A,
        0x4A75, 0x5A54, 0x6A37, 0x7A16, 0x0AF1, 0x1AD0, 0x2AB3, 0x3A92,
        0xFD2E, 0xED0F, 0xDD6C, 0xCD4D, 0xBDAA, 0xAD8B, 0x9DE8, 0x8DC9,
        0x7C26, 0x6C07, 0x5C64, 0x4C45, 0x3CA2, 0x2C83, 0x1CE0, 0x0CC1,
        0xEF1F, 0xFF3E, 0xCF5D, 0xDF7C, 0xAF9B, 0xBFBA, 0x8FD9, 0x9FF8,
        0x6E17, 0x7E36, 0x4E55, 0x5E74, 0x2E93, 0x3EB2, 0x0ED1, 0x1EF0,
    ];

    public function generate(array $payload, string $type = 'individual'): array
    {
        $qr = $this->buildKhqr($payload, $type);

        return [
            'qr' => $qr,
            'md5' => md5($qr),
        ];
    }

    private function buildKhqr(array $payload, string $type): string
    {
        $merchantName = $this->requireString($payload['merchant_name'] ?? null, 'Merchant name is required.');
        $merchantCity = $payload['merchant_city'] ?? self::EMV['defaultMerchantCity'];
        $merchantCategoryCode = $payload['merchant_category_code'] ?? self::EMV['defaultMerchantCategoryCode'];
        $currency = $payload['currency'] ?? 'USD';
        $amount = $payload['amount'] ?? null;

        $qrType = ($amount === null || (float) $amount == 0.0)
            ? self::EMV['staticQR']
            : self::EMV['dynamicQR'];

        $tags = [];
        $tags[] = $this->tag(self::EMV['payloadFormatIndicator'], self::EMV['defaultPayloadFormatIndicator']);
        $tags[] = $this->tag(self::EMV['pointOfInitiationMethod'], $qrType);
        $tags[] = $this->buildMerchantAccount($payload, $type);
        $tags[] = $this->tag(self::EMV['merchantCategoryCode'], $this->validateMerchantCategory($merchantCategoryCode));
        $tags[] = $this->tag(self::EMV['transactionCurrency'], $this->mapCurrency($currency));

        if ($amount !== null && (float) $amount > 0) {
            $tags[] = $this->tag(
                self::EMV['transactionAmount'],
                $this->formatAmount((float) $amount, $currency)
            );
        }

        $tags[] = $this->tag(self::EMV['countryCode'], $payload['country_code'] ?? self::EMV['defaultCountryCode']);
        $tags[] = $this->tag(self::EMV['merchantName'], $this->validateLength($merchantName, self::INVALID_LENGTH['merchantName'], 'merchant name'));
        $tags[] = $this->tag(self::EMV['merchantCity'], $this->validateLength($merchantCity, self::INVALID_LENGTH['merchantCity'], 'merchant city'));

        $additionalData = $this->buildAdditionalData($payload);
        if ($additionalData !== '') {
            $tags[] = $additionalData;
        }

        if ($qrType === self::EMV['dynamicQR']) {
            $timestamp = $this->buildTimestamp($payload);
            if ($timestamp !== '') {
                $tags[] = $timestamp;
            }
        }

        $payloadString = implode('', $tags);
        $payloadWithCrc = $payloadString.self::EMV['crc'].self::EMV['crcLength'];
        $crc = $this->crc16($payloadWithCrc);

        return $payloadWithCrc.$crc;
    }

    private function buildMerchantAccount(array $payload, string $type): string
    {
        $bakongAccountId = $this->requireString(
            $payload['bakong_account_id'] ?? null,
            'Bakong account id is required.'
        );

        if (strlen($bakongAccountId) > self::INVALID_LENGTH['bakongAccount']) {
            throw new InvalidArgumentException('Bakong account id is too long.');
        }

        if (strpos($bakongAccountId, '@') === false) {
            throw new InvalidArgumentException('Bakong account id is invalid.');
        }

        $accountInfo = $this->tag(self::EMV['bakongAccountIdentifier'], $bakongAccountId);

        if ($type === 'merchant') {
            if (! empty($payload['merchant_id'])) {
                $merchantId = $this->validateLength(
                    (string) $payload['merchant_id'],
                    self::INVALID_LENGTH['merchantId'],
                    'merchant id'
                );
                $accountInfo .= $this->tag(self::EMV['merchantAccountInformationMerchantId'], $merchantId);
            }

            if (! empty($payload['acquiring_bank'])) {
                $acquiringBank = $this->validateLength(
                    (string) $payload['acquiring_bank'],
                    self::INVALID_LENGTH['acquiringBank'],
                    'acquiring bank'
                );
                $accountInfo .= $this->tag(self::EMV['merchantAccountInformationAcquiringBank'], $acquiringBank);
            }
        } else {
            if (! empty($payload['account_information'])) {
                $accountInformation = $this->validateLength(
                    (string) $payload['account_information'],
                    self::INVALID_LENGTH['accountInformation'],
                    'account information'
                );
                $accountInfo .= $this->tag(self::EMV['individualAccountInformation'], $accountInformation);
            }

            if (! empty($payload['acquiring_bank'])) {
                $acquiringBank = $this->validateLength(
                    (string) $payload['acquiring_bank'],
                    self::INVALID_LENGTH['acquiringBank'],
                    'acquiring bank'
                );
                $accountInfo .= $this->tag(self::EMV['merchantAccountInformationAcquiringBank'], $acquiringBank);
            }
        }

        $tag = $type === 'merchant'
            ? self::EMV['merchantAccountInformationMerchant']
            : self::EMV['merchantAccountInformationIndividual'];

        return $this->tag($tag, $accountInfo);
    }

    private function buildAdditionalData(array $payload): string
    {
        $additional = '';

        if (! empty($payload['bill_number'])) {
            $billNumber = $this->validateLength(
                (string) $payload['bill_number'],
                self::INVALID_LENGTH['billNumber'],
                'bill number'
            );
            $additional .= $this->tag(self::EMV['billNumberTag'], $billNumber);
        }

        if (! empty($payload['mobile_number'])) {
            $mobileNumber = $this->validateLength(
                (string) $payload['mobile_number'],
                self::INVALID_LENGTH['mobileNumber'],
                'mobile number'
            );
            $additional .= $this->tag(self::EMV['additionalDataFieldMobileNumber'], $mobileNumber);
        }

        if (! empty($payload['store_label'])) {
            $storeLabel = $this->validateLength(
                (string) $payload['store_label'],
                self::INVALID_LENGTH['storeLabel'],
                'store label'
            );
            $additional .= $this->tag(self::EMV['storeLabelTag'], $storeLabel);
        }

        if (! empty($payload['terminal_label'])) {
            $terminalLabel = $this->validateLength(
                (string) $payload['terminal_label'],
                self::INVALID_LENGTH['terminalLabel'],
                'terminal label'
            );
            $additional .= $this->tag(self::EMV['terminalTag'], $terminalLabel);
        }

        if (! empty($payload['purpose'])) {
            $purpose = $this->validateLength(
                (string) $payload['purpose'],
                self::INVALID_LENGTH['purposeOfTransaction'],
                'purpose of transaction'
            );
            $additional .= $this->tag(self::EMV['purposeOfTransaction'], $purpose);
        }

        if ($additional === '') {
            return '';
        }

        return $this->tag(self::EMV['additionalDataTag'], $additional);
    }

    private function buildTimestamp(array $payload): string
    {
        $expiration = $payload['expiration_timestamp'] ?? null;
        if ($expiration === null) {
            return '';
        }

        $expiration = (int) $expiration;
        $creation = (int) floor(microtime(true) * 1000);

        if (strlen((string) $expiration) !== self::INVALID_LENGTH['timestamp']) {
            throw new InvalidArgumentException('Expiration timestamp length invalid.');
        }

        if ($expiration <= $creation) {
            throw new InvalidArgumentException('Expiration timestamp must be in the future.');
        }

        $timestamp = $this->tag(self::EMV['creationTimestamp'], (string) $creation);
        $timestamp .= $this->tag(self::EMV['expirationTimestamp'], (string) $expiration);

        return $this->tag(self::EMV['timestampTag'], $timestamp);
    }

    private function mapCurrency(string $currency): string
    {
        $currency = strtoupper(trim($currency));
        if ($currency === 'USD' || $currency === '840') {
            return '840';
        }
        if ($currency === 'KHR' || $currency === '116') {
            return '116';
        }

        if (ctype_digit($currency) && strlen($currency) <= 3) {
            return str_pad($currency, 3, '0', STR_PAD_LEFT);
        }

        throw new InvalidArgumentException('Unsupported currency.');
    }

    private function formatAmount(float $amount, string $currency): string
    {
        $currencyCode = $this->mapCurrency($currency);

        if ($currencyCode === '116') {
            $rounded = (int) round($amount);
            if (abs($amount - $rounded) > 0.0001) {
                throw new InvalidArgumentException('KHR amount must be an integer.');
            }
            return (string) $rounded;
        }

        return number_format($amount, 2, '.', '');
    }

    private function validateMerchantCategory(string $value): string
    {
        $value = trim($value);
        if ($value === '') {
            throw new InvalidArgumentException('Merchant category code is required.');
        }
        if (strlen($value) > self::INVALID_LENGTH['merchantCategoryCode']) {
            throw new InvalidArgumentException('Merchant category code length invalid.');
        }
        if (! ctype_digit($value)) {
            throw new InvalidArgumentException('Merchant category code must be numeric.');
        }
        $intValue = (int) $value;
        if ($intValue < 0 || $intValue > 9999) {
            throw new InvalidArgumentException('Merchant category code is invalid.');
        }
        return str_pad((string) $intValue, 4, '0', STR_PAD_LEFT);
    }

    private function tag(string $tag, string $value): string
    {
        $length = str_pad((string) strlen($value), 2, '0', STR_PAD_LEFT);

        return $tag.$length.$value;
    }

    private function validateLength(string $value, int $limit, string $label): string
    {
        $value = trim($value);
        if ($value === '') {
            throw new InvalidArgumentException("{$label} is required.");
        }
        if (strlen($value) > $limit) {
            throw new InvalidArgumentException("{$label} is too long.");
        }
        return $value;
    }

    private function requireString(?string $value, string $message): string
    {
        $value = trim((string) $value);
        if ($value === '') {
            throw new InvalidArgumentException($message);
        }

        return $value;
    }

    private function crc16(string $input): string
    {
        $crc = 0xFFFF;
        $bytes = array_values(unpack('C*', $input));

        foreach ($bytes as $byte) {
            $j = ($byte ^ ($crc >> 8)) & 0xFF;
            $crc = self::CRC_TABLE[$j] ^ (($crc << 8) & 0xFFFF);
        }

        $finalCheckSum = ($crc ^ 0) & 0xFFFF;

        return strtoupper(str_pad(dechex($finalCheckSum), 4, '0', STR_PAD_LEFT));
    }
}
