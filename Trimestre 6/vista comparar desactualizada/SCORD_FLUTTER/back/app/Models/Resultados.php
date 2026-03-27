<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Resultados extends Model
{
    protected $table = 'Resultados';

    protected $primaryKey = 'idResultados'; // Clave primaria personalizada

    public $timestamps = false; // Si tu tabla no tiene created_at/updated_at

    protected $fillable = [
        'idResultados',
        'Marcador',
        'PuntosObtenidos',
        'Observacion',
        'idPartidos'
    ];


public function Partido(): BelongsTo
{
    return $this->belongsTo(Partidos::class, 'idPartidos');
}
}