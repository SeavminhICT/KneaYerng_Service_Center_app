<?php

namespace App\Http\Middleware;

use App\Models\RepairRequest;
use App\Models\Technician;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Gates the technician self-service repair routes: the actor must be a
 * logged-in technician whose linked Technician profile is the one assigned
 * to the {repair} route parameter. Reused across several controllers
 * (RepairDiagnosticController, RepairQuotationController, RepairQcController,
 * RepairIntakeController) so those don't each need their own ownership check.
 */
class EnsureTechnicianOwnsRepair
{
    public function handle(Request $request, Closure $next): Response
    {
        $actor = $request->user() ?? $request->user('sanctum');

        if (! $actor) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $technician = Technician::where('user_id', $actor->id)->first();

        if (! $technician) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        $repair = $request->route('repair');
        if (! $repair instanceof RepairRequest) {
            $repair = RepairRequest::find($repair);
        }

        if (! $repair || (int) $repair->technician_id !== (int) $technician->id) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        $request->attributes->set('technician', $technician);

        return $next($request);
    }
}
