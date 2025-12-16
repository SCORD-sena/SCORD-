<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes; // ← NUEVO

class RendimientosPartidos extends Model
{
    use SoftDeletes; // ← AGREGADO SoftDeletes

    protected $table = 'RendimientosPartidos';
    protected $primaryKey = 'IdRendimientos';
    public $incrementing = true;
    protected $keyType = 'int';
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
        return $this->belongsTo(Partidos::class, 'idPartidos', 'idPartidos');
    }

    public function jugador(): BelongsTo
    {
        return $this->belongsTo(Jugadores::class, 'idJugadores', 'idJugadores');
    }
}