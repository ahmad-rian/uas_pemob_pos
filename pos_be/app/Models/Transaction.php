<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Transaction extends Model
{
    protected $fillable = [
        'user_id',
        'total_amount',
        'status'
    ];

    protected $casts = [
        'total_amount' => 'double',
        'created_at' => 'datetime',
    ];

    public function items()
    {
        return $this->hasMany(TransactionItem::class);
    }

    public function toDashboardFormat()
    {
        return [
            'id' => $this->id,
            'total_amount' => (float)$this->total_amount,
            'items_count' => $this->items->sum('quantity'),
            'created_at' => $this->created_at->toIso8601String(),
            'status' => $this->status
        ];
    }
}
