<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes; // ← NUEVO

class Resultados extends Model
{
    use SoftDeletes; // ← AGREGADO SoftDeletes

    protected $table = 'Resultados';
    protected $primaryKey = 'idResultados';
    public $timestamps = false;

    protected $fillable = [
        'idResultados',
        'Marcador',
        'PuntosObtenidos',
        'Observacion',
        'idPartidos'
    ];

    public function Partido(): BelongsTo
    {
        return $this->belongsTo(Partidos::class, 'idPartidos', 'idPartidos');
    }
}