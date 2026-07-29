<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\StorePartRequest;
use App\Http\Requests\Api\UpdatePartRequest;
use App\Http\Resources\PartResource;
use App\Models\Part;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;

class PartController extends Controller
{
    public function index(Request $request)
    {
        $query = Part::query()->orderByDesc('id');
        $this->applyPartFilters($request, $query);

        $perPage = (int) $request->input('per_page', 10);
        $perPage = max(1, min(50, $perPage));

        $parts = $query->paginate($perPage)->withQueryString();

        return PartResource::collection($parts);
    }

    public function exportExcel(Request $request)
    {
        $query = Part::query();
        $this->applyPartFilters($request, $query);
        $query->orderBy('name')->orderBy('sku');

        $parts = $query->select([
            'name',
            'type',
            'brand',
            'sku',
            'stock',
            'unit_cost',
            'status',
            'tag',
            'created_at',
        ])->limit(5000)->get();

        $fileName = 'parts-inventory-'.now()->format('Ymd-His').'.xls';
        $xml = $this->buildPartsExcelXml($parts);

        return response($xml, 200, [
            'Content-Type' => 'application/vnd.ms-excel; charset=UTF-8',
            'Content-Disposition' => 'attachment; filename="'.$fileName.'"',
            'Pragma' => 'no-cache',
            'Cache-Control' => 'must-revalidate, post-check=0, pre-check=0',
            'Expires' => '0',
        ]);
    }

    public function exportPdf(Request $request)
    {
        $query = Part::query();
        $this->applyPartFilters($request, $query);
        $query->orderBy('name')->orderBy('sku');

        $parts = $query->select([
            'name',
            'type',
            'brand',
            'sku',
            'stock',
            'unit_cost',
            'status',
            'tag',
            'created_at',
        ])->limit(1000)->get();

        $generatedAt = now()->format('d M Y, H:i').' ICT';
        $fileName = 'parts-inventory-'.now()->format('Ymd-His').'.pdf';

        $pdf = Pdf::loadView('admin.parts.pdf.export', compact('parts', 'generatedAt'))
            ->setPaper('a4', 'landscape');

        return $pdf->download($fileName);
    }

    public function store(StorePartRequest $request)
    {
        $part = Part::create($request->validated());

        return new PartResource($part);
    }

    public function show(Part $part)
    {
        return new PartResource($part);
    }

    public function update(UpdatePartRequest $request, Part $part)
    {
        $part->fill($request->validated());
        $part->save();

        return new PartResource($part);
    }

    public function destroy(Part $part)
    {
        $part->delete();

        return response()->noContent();
    }

    private function applyPartFilters(Request $request, Builder $query): void
    {
        if ($request->filled('q')) {
            $q = (string) $request->string('q');
            $query->where(function ($builder) use ($q) {
                $builder->where('name', 'like', "%{$q}%")
                    ->orWhere('sku', 'like', "%{$q}%")
                    ->orWhere('brand', 'like', "%{$q}%")
                    ->orWhere('type', 'like', "%{$q}%");
            });
        }

        if ($request->filled('status')) {
            $status = (string) $request->string('status');
            if (in_array($status, Part::STATUSES, true)) {
                $query->where('status', $status);
            }
        }

        if ($request->filled('tag')) {
            $tag = (string) $request->string('tag');
            if (in_array($tag, Part::TAGS, true)) {
                $query->where('tag', $tag);
            }
        }

        if ($request->filled('type')) {
            $type = (string) $request->string('type');
            $query->where('type', 'like', "%{$type}%");
        }

        if ($request->filled('brand')) {
            $brand = (string) $request->string('brand');
            $query->where('brand', 'like', "%{$brand}%");
        }

        if ($request->filled('stock_filter')) {
            match ((string) $request->string('stock_filter')) {
                'in_stock' => $query->where('stock', '>', 0),
                'out_of_stock' => $query->where('stock', 0),
                'low_stock' => $query->whereBetween('stock', [1, 5]),
                default => null,
            };
        }

        if ($request->filled('min_stock') && is_numeric($request->input('min_stock'))) {
            $query->where('stock', '>=', max(0, (int) $request->input('min_stock')));
        }

        if ($request->filled('max_stock') && is_numeric($request->input('max_stock'))) {
            $query->where('stock', '<=', max(0, (int) $request->input('max_stock')));
        }

        if ($request->filled('min_unit_cost') && is_numeric($request->input('min_unit_cost'))) {
            $query->where('unit_cost', '>=', max(0, (float) $request->input('min_unit_cost')));
        }

        if ($request->filled('max_unit_cost') && is_numeric($request->input('max_unit_cost'))) {
            $query->where('unit_cost', '<=', max(0, (float) $request->input('max_unit_cost')));
        }
    }

    private function buildPartsExcelXml($parts): string
    {
        $now = now()->format('d M Y, H:i').' ICT';
        $count = $parts->count();
        $totalStock = (int) $parts->sum('stock');
        $totalValue = round($parts->sum(fn (Part $part) => (int) $part->stock * (float) $part->unit_cost), 2);

        $xml = '<?xml version="1.0" encoding="UTF-8"?>'."\n";
        $xml .= '<?mso-application progid="Excel.Sheet"?>'."\n";
        $xml .= '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"'."\n";
        $xml .= ' xmlns:o="urn:schemas-microsoft-com:office:office"'."\n";
        $xml .= ' xmlns:x="urn:schemas-microsoft-com:office:excel"'."\n";
        $xml .= ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">'."\n";

        $xml .= '<Styles>'."\n";
        $xml .= '<Style ss:ID="s_title"><Font ss:Bold="1" ss:Size="14" ss:Color="#1E293B"/></Style>'."\n";
        $xml .= '<Style ss:ID="s_meta"><Font ss:Size="9" ss:Color="#64748B"/></Style>'."\n";
        $xml .= '<Style ss:ID="s_hdr"><Font ss:Bold="1" ss:Color="#FFFFFF" ss:Size="9"/><Interior ss:Color="#1E293B" ss:Pattern="Solid"/><Alignment ss:Horizontal="Center" ss:Vertical="Center"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#4F46E5"/></Borders></Style>'."\n";
        $xml .= '<Style ss:ID="s_odd"><Font ss:Size="9" ss:Color="#1E293B"/><Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/></Borders></Style>'."\n";
        $xml .= '<Style ss:ID="s_even"><Font ss:Size="9" ss:Color="#1E293B"/><Interior ss:Color="#F8FAFC" ss:Pattern="Solid"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/></Borders></Style>'."\n";
        $xml .= '<Style ss:ID="s_num_odd"><Font ss:Size="9" ss:Color="#1E293B"/><Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/><NumberFormat ss:Format="#,##0.00"/><Alignment ss:Horizontal="Right"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/></Borders></Style>'."\n";
        $xml .= '<Style ss:ID="s_num_even"><Font ss:Size="9" ss:Color="#1E293B"/><Interior ss:Color="#F8FAFC" ss:Pattern="Solid"/><NumberFormat ss:Format="#,##0.00"/><Alignment ss:Horizontal="Right"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/></Borders></Style>'."\n";
        $xml .= '<Style ss:ID="s_stock_odd"><Font ss:Size="9" ss:Color="#1E293B"/><Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/><NumberFormat ss:Format="#,##0"/><Alignment ss:Horizontal="Right"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/></Borders></Style>'."\n";
        $xml .= '<Style ss:ID="s_stock_even"><Font ss:Size="9" ss:Color="#1E293B"/><Interior ss:Color="#F8FAFC" ss:Pattern="Solid"/><NumberFormat ss:Format="#,##0"/><Alignment ss:Horizontal="Right"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/></Borders></Style>'."\n";
        $xml .= '<Style ss:ID="s_foot_label"><Font ss:Bold="1" ss:Size="9" ss:Color="#0F172A"/><Interior ss:Color="#F1F5F9" ss:Pattern="Solid"/><Borders><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#CBD5E1"/></Borders></Style>'."\n";
        $xml .= '<Style ss:ID="s_foot_num"><Font ss:Bold="1" ss:Size="9" ss:Color="#16A34A"/><Interior ss:Color="#F1F5F9" ss:Pattern="Solid"/><NumberFormat ss:Format="#,##0.00"/><Alignment ss:Horizontal="Right"/><Borders><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#CBD5E1"/></Borders></Style>'."\n";
        $xml .= '<Style ss:ID="s_active"><Font ss:Bold="1" ss:Size="9" ss:Color="#166534"/><Interior ss:Color="#DCFCE7" ss:Pattern="Solid"/><Alignment ss:Horizontal="Center"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/></Borders></Style>'."\n";
        $xml .= '<Style ss:ID="s_inactive"><Font ss:Bold="1" ss:Size="9" ss:Color="#475569"/><Interior ss:Color="#F1F5F9" ss:Pattern="Solid"/><Alignment ss:Horizontal="Center"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/></Borders></Style>'."\n";
        $xml .= '<Style ss:ID="s_archived"><Font ss:Bold="1" ss:Size="9" ss:Color="#854D0E"/><Interior ss:Color="#FEF9C3" ss:Pattern="Solid"/><Alignment ss:Horizontal="Center"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/></Borders></Style>'."\n";
        $xml .= '</Styles>'."\n";

        $xml .= '<Worksheet ss:Name="Parts Inventory">'."\n";
        $xml .= '<Table ss:DefaultColumnWidth="80">'."\n";

        foreach ([40, 150, 90, 90, 105, 65, 75, 85, 75, 90, 115] as $width) {
            $xml .= '<Column ss:Width="'.$width.'"/>'."\n";
        }

        $xml .= '<Row ss:Height="28"><Cell ss:MergeAcross="10" ss:StyleID="s_title"><Data ss:Type="String">KneaYerng Service Center - Parts Inventory Export</Data></Cell></Row>'."\n";
        $xml .= '<Row ss:Height="16"><Cell ss:MergeAcross="10" ss:StyleID="s_meta"><Data ss:Type="String">Generated: '.$this->excelText($now).'   |   Total records: '.$count.'   |   Total stock: '.$totalStock.'   |   Inventory value: $'.number_format($totalValue, 2).'</Data></Cell></Row>'."\n";
        $xml .= '<Row ss:Height="8"></Row>'."\n";

        $headers = ['#', 'Name', 'Type', 'Brand', 'SKU', 'Stock', 'Unit Cost ($)', 'Value ($)', 'Status', 'Tag', 'Created At'];
        $xml .= '<Row ss:Height="22">'."\n";
        foreach ($headers as $header) {
            $xml .= '<Cell ss:StyleID="s_hdr"><Data ss:Type="String">'.$this->excelText($header).'</Data></Cell>'."\n";
        }
        $xml .= '</Row>'."\n";

        foreach ($parts as $index => $part) {
            $even = $index % 2 === 1;
            $rowStyle = $even ? 's_even' : 's_odd';
            $numStyle = $even ? 's_num_even' : 's_num_odd';
            $stockStyle = $even ? 's_stock_even' : 's_stock_odd';
            $statusStyle = match ((string) $part->status) {
                'active' => 's_active',
                'archived' => 's_archived',
                'inactive' => 's_inactive',
                default => $rowStyle,
            };
            $createdAt = $part->created_at ? $part->created_at->format('d M Y H:i') : '';
            $stock = (int) ($part->stock ?? 0);
            $unitCost = (float) ($part->unit_cost ?? 0);
            $value = round($stock * $unitCost, 2);

            $xml .= '<Row ss:Height="18">'."\n";
            $xml .= '<Cell ss:StyleID="'.$rowStyle.'"><Data ss:Type="Number">'.($index + 1).'</Data></Cell>'."\n";
            $xml .= '<Cell ss:StyleID="'.$rowStyle.'"><Data ss:Type="String">'.$this->excelText($part->name).'</Data></Cell>'."\n";
            $xml .= '<Cell ss:StyleID="'.$rowStyle.'"><Data ss:Type="String">'.$this->excelText($part->type).'</Data></Cell>'."\n";
            $xml .= '<Cell ss:StyleID="'.$rowStyle.'"><Data ss:Type="String">'.$this->excelText($part->brand).'</Data></Cell>'."\n";
            $xml .= '<Cell ss:StyleID="'.$rowStyle.'"><Data ss:Type="String">'.$this->excelText($part->sku).'</Data></Cell>'."\n";
            $xml .= '<Cell ss:StyleID="'.$stockStyle.'"><Data ss:Type="Number">'.$stock.'</Data></Cell>'."\n";
            $xml .= '<Cell ss:StyleID="'.$numStyle.'"><Data ss:Type="Number">'.$unitCost.'</Data></Cell>'."\n";
            $xml .= '<Cell ss:StyleID="'.$numStyle.'"><Data ss:Type="Number">'.$value.'</Data></Cell>'."\n";
            $xml .= '<Cell ss:StyleID="'.$statusStyle.'"><Data ss:Type="String">'.$this->excelText($this->titleLabel($part->status)).'</Data></Cell>'."\n";
            $xml .= '<Cell ss:StyleID="'.$rowStyle.'"><Data ss:Type="String">'.$this->excelText($this->tagLabel($part->tag)).'</Data></Cell>'."\n";
            $xml .= '<Cell ss:StyleID="'.$rowStyle.'"><Data ss:Type="String">'.$this->excelText($createdAt).'</Data></Cell>'."\n";
            $xml .= '</Row>'."\n";
        }

        $xml .= '<Row ss:Height="20">'."\n";
        $xml .= '<Cell ss:MergeAcross="4" ss:StyleID="s_foot_label"><Data ss:Type="String">TOTAL ('.$count.' parts)</Data></Cell>'."\n";
        $xml .= '<Cell ss:StyleID="s_foot_label"><Data ss:Type="Number">'.$totalStock.'</Data></Cell>'."\n";
        $xml .= '<Cell ss:StyleID="s_foot_label"><Data ss:Type="String"></Data></Cell>'."\n";
        $xml .= '<Cell ss:StyleID="s_foot_num"><Data ss:Type="Number">'.$totalValue.'</Data></Cell>'."\n";
        $xml .= '<Cell ss:MergeAcross="2" ss:StyleID="s_foot_label"><Data ss:Type="String"></Data></Cell>'."\n";
        $xml .= '</Row>'."\n";

        $xml .= '</Table>'."\n";
        $xml .= '</Worksheet>'."\n";
        $xml .= '</Workbook>';

        return $xml;
    }

    private function excelText($value): string
    {
        return htmlspecialchars((string) ($value ?? ''), ENT_QUOTES | ENT_XML1, 'UTF-8');
    }

    private function tagLabel(?string $tag): string
    {
        return match ($tag) {
            'HOT_SALE' => 'Hot Sale',
            'TOP_SELLER' => 'Top Seller',
            'PROMOTION' => 'Promotion',
            default => $tag ? ucwords(strtolower(str_replace('_', ' ', $tag))) : '',
        };
    }

    private function titleLabel(?string $value): string
    {
        return $value ? ucwords(str_replace('_', ' ', strtolower($value))) : '';
    }
}
