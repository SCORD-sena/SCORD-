<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RendimientosPartidos extends Model
{
    protected $table = 'RendimientosPartidos';

    protected $primaryKey = 'IdRendimientos'; // ✅ CAMBIAR A MAYÚSCULA
    
    public $incrementing = true; // ✅ AGREGAR ESTO
    
    protected $keyType = 'int'; // ✅ AGREGAR ESTO

    public $timestamps = false;

    protected $fillable = [
        'Goles',
        'GolesDeCabeza',
        'MinutosJugados',
        'Asistencias',
        'TirosApuerta',
        'TarjetasRojas',
        'TarjetasAmarillas',
        'FuerasDeLugar',
        'ArcoEnCero',
        'idPartidos',
        'idJugadores'
    ];

    public function partido(): BelongsTo
    {
        return $this->belongsTo(Partidos::class, 'idPartidos');
    }

    public function jugador(): BelongsTo
    {
        return $this->belongsTo(Jugadores::class, 'idJugadores');
    }
}