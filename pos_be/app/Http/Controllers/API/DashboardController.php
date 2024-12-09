<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\Product;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function index()
    {
        try {
            $today = Carbon::today();

            // Get today's sales and transactions
            $todayStats = Transaction::whereDate('created_at', $today)
                ->select(
                    DB::raw('COALESCE(SUM(total_amount), 0) as total'),
                    DB::raw('COUNT(*) as count')
                )
                ->first();

            // Get total products sold today
            $totalProductsSold = DB::table('transaction_items')
                ->join('transactions', 'transactions.id', '=', 'transaction_items.transaction_id')
                ->whereDate('transactions.created_at', $today)
                ->sum('transaction_items.quantity');

            // Get last 7 days sales data for chart
            $salesChartData = Transaction::whereBetween('created_at', [
                Carbon::now()->subDays(6)->startOfDay(),
                Carbon::now()->endOfDay()
            ])
                ->select(
                    DB::raw('DATE(created_at) as date'),
                    DB::raw('SUM(total_amount) as total'),
                    DB::raw('COUNT(*) as transactions')
                )
                ->groupBy('date')
                ->orderBy('date')
                ->get()
                ->map(function ($item) {
                    return [
                        'date' => Carbon::parse($item->date)->format('d M'),
                        'sales' => (float)$item->total,
                        'transactions' => (int)$item->transactions
                    ];
                });

            // Get monthly revenue
            $monthlyRevenue = Transaction::whereBetween('created_at', [
                Carbon::now()->startOfMonth(),
                Carbon::now()->endOfMonth()
            ])->sum('total_amount');

            // Get weekly revenue
            $weeklyRevenue = Transaction::whereBetween('created_at', [
                Carbon::now()->startOfWeek(),
                Carbon::now()->endOfWeek()
            ])->sum('total_amount');

            // Get sales growth (compare with previous month)
            $previousMonthRevenue = Transaction::whereBetween('created_at', [
                Carbon::now()->subMonth()->startOfMonth(),
                Carbon::now()->subMonth()->endOfMonth()
            ])->sum('total_amount');

            $salesGrowth = $previousMonthRevenue > 0
                ? (($monthlyRevenue - $previousMonthRevenue) / $previousMonthRevenue) * 100
                : 0;

            // Get total customers (unique user_id count)
            $totalCustomers = Transaction::distinct('user_id')->count('user_id');

            // Get best selling products
            $bestSellingProducts = DB::table('transaction_items')
                ->join('products', 'products.id', '=', 'transaction_items.product_id')
                ->select(
                    'products.name',
                    DB::raw('SUM(transaction_items.quantity) as total_quantity'),
                    DB::raw('SUM(transaction_items.subtotal) as total_sales')
                )
                ->whereMonth('transaction_items.created_at', Carbon::now()->month)
                ->groupBy('products.id', 'products.name')
                ->orderBy('total_quantity', 'desc')
                ->take(5)
                ->get();

            // Get recent transactions
            $recentTransactions = Transaction::with('items')
                ->latest()
                ->take(5)
                ->get()
                ->map(function ($transaction) {
                    return [
                        'id' => $transaction->id,
                        'total_amount' => (float)$transaction->total_amount,
                        'items_count' => $transaction->items->sum('quantity'),
                        'created_at' => $transaction->created_at->toIso8601String(),
                        'status' => $transaction->status
                    ];
                });

            return response()->json([
                'status' => 'success',
                'data' => [
                    'today_sales' => (float)$todayStats->total,
                    'today_transactions' => (int)$todayStats->count,
                    'total_products_sold' => (int)$totalProductsSold,
                    'recent_transactions' => $recentTransactions,
                    'monthly_revenue' => (float)$monthlyRevenue,
                    'weekly_revenue' => (float)$weeklyRevenue,
                    'sales_growth' => (float)$salesGrowth,
                    'total_customers' => (int)$totalCustomers,
                    'best_selling_products' => $bestSellingProducts,
                    'sales_chart_data' => $salesChartData
                ]
            ], 200);
        } catch (\Exception $e) {
            \Log::error('Dashboard error: ' . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to load dashboard data'
            ], 500);
        }
    }
}
