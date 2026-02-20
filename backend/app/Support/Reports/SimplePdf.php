<?php

namespace App\Support\Reports;

class SimplePdf
{
    public static function fromLines(array $lines, int $fontSize = 11, int $lineHeight = 14): string
    {
        $prepared = self::prepareLines($lines, 96);
        $text = "BT\n/F1 {$fontSize} Tf\n72 760 Td\n";
        foreach ($prepared as $index => $line) {
            if ($index > 0) {
                $text .= "0 -{$lineHeight} Td\n";
            }
            $text .= '(' . self::escapePdfText($line) . ") Tj\n";
        }
        $text .= "ET\n";

        $objects = [];
        $objects[] = '<< /Type /Catalog /Pages 2 0 R >>';
        $objects[] = '<< /Type /Pages /Kids [3 0 R] /Count 1 >>';
        $objects[] = '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>';
        $objects[] = '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>';
        $objects[] = "<< /Length " . strlen($text) . " >>\nstream\n{$text}\nendstream";

        $pdf = "%PDF-1.4\n";
        $offsets = [];
        foreach ($objects as $index => $object) {
            $offsets[] = strlen($pdf);
            $pdf .= ($index + 1) . " 0 obj\n" . $object . "\nendobj\n";
        }

        $xrefOffset = strlen($pdf);
        $pdf .= "xref\n0 " . (count($objects) + 1) . "\n";
        $pdf .= "0000000000 65535 f \n";
        foreach ($offsets as $offset) {
            $pdf .= sprintf("%010d 00000 n \n", $offset);
        }
        $pdf .= "trailer\n<< /Size " . (count($objects) + 1) . " /Root 1 0 R >>\n";
        $pdf .= "startxref\n{$xrefOffset}\n%%EOF";

        return $pdf;
    }

    private static function prepareLines(array $lines, int $maxLength): array
    {
        $result = [];
        foreach ($lines as $line) {
            $line = self::sanitizeLine((string) $line);
            if ($line === '') {
                $result[] = '';
                continue;
            }
            $wrapped = wordwrap($line, $maxLength, "\n", true);
            foreach (explode("\n", $wrapped) as $chunk) {
                $result[] = $chunk;
            }
        }
        return $result;
    }

    private static function sanitizeLine(string $line): string
    {
        $line = preg_replace('/[^\x20-\x7E]/', '?', $line) ?? '';
        return trim($line);
    }

    private static function escapePdfText(string $text): string
    {
        return str_replace(['\\', '(', ')'], ['\\\\', '\\(', '\\)'], $text);
    }
}
