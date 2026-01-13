<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Invoice extends Model
{
    use HasFactory;

    protected $fillable = [
        'repair_id',
        'invoice_number',
        'subtotal',
        'tax',
        'total',
        'payment_status',
    ];

    public function repair()
    {
        return $this->belongsTo(RepairRequest::class, 'repair_id');
    }

    public function payments()
    {
        return $this->hasMany(RepairPayment::class);
    }
}
