<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ChatMessage extends Model
{
    use HasFactory;

    protected $fillable = [
        'repair_id',
        'sender_type',
        'message',
    ];

    public function repair()
    {
        return $this->belongsTo(RepairRequest::class, 'repair_id');
    }
}
