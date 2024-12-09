<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use Carbon\Carbon;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function stats()
    {
        $today = Carbon::today();

        $todaySales = Transaction::whereDate('created_at', $today)->sum('total_amount');
        $todayTransactions = Transaction::whereDate('created_at', $today)->count();
        $totalProducts = Transaction::whereDate('created_at', $today)
            ->join('transaction_items', 'transactions.id', '=', 'transaction_items.transaction_id')
            ->sum('transaction_items.quantity');

        // Get sales data for chart (last 7 days)
        $salesChart = Transaction::whereBetween('created_at', [
            Carbon::now()->subDays(6)->startOfDay(),
            Carbon::now()->endOfDay()
        ])
            ->selectRaw('DATE(created_at) as date, SUM(total_amount) as total')
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        // Get recent transactions
        $recentTransactions = Transaction::with(['user', 'items.product'])
            ->latest()
            ->take(5)
            ->get()
            ->map(function ($transaction) {
                return [
                    'id' => $transaction->id,
                    'date' => $transaction->created_at->format('Y-m-d H:i'),
                    'total_amount' => $transaction->total_amount,
                    'items_count' => $transaction->items->sum('quantity'),
                    'user_name' => $transaction->user->name,
                ];
            });

        return response()->json([
            'today_sales' => $todaySales,
            'today_transactions' => $todayTransactions,
            'total_products' => $totalProducts,
            'sales_chart' => $salesChart,
            'recent_transactions' => $recentTransactions,
        ]);
    }
}
