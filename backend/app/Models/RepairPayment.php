<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RepairPayment extends Model
{
    use HasFactory;

    protected $fillable = [
        'invoice_id',
        'type',
        'method',
        'amount',
        'status',
        'transaction_ref',
    ];

    public function invoice()
    {
        return $this->belongsTo(Invoice::class);
    }
}
