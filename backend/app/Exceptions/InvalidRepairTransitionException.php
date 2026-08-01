<?php

namespace App\Exceptions;

use RuntimeException;

class InvalidRepairTransitionException extends RuntimeException
{
    /**
     * @param  string[]  $allowedNext
     */
    public function __construct(public readonly string $from, public readonly string $to, public readonly array $allowedNext)
    {
        $allowedList = $allowedNext === [] ? 'none (terminal status)' : implode(', ', $allowedNext);

        parent::__construct("Cannot change repair status from \"{$from}\" to \"{$to}\". Allowed next status(es): {$allowedList}.");
    }
}
