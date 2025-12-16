<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RendimientosPartidos extends Model
{
    protected $table = 'RendimientosPartidos';

    protected $primaryKey = 'idRendimientosP'; // Clave primaria personalizada

    public $timestamps = false; // Si tu tabla no tiene created_at/updated_at

    protected $fillable = [
        'idRendimientosP',
        'Goles',
        'GolesDeCabeza',
        'MinutosJugados',
        'Asistencias',
        'TirosApuerta',
        'TarjetasRojas',
        'TarjetasAmarillas',
        'FuerasDeLugar',
        'ArcoEnCero',
        'idPartido'
    ];

    public function partido(): BelongsTo
    {
        return $this->belongsTo(Partidos::class, 'idPartido');
    }
}
