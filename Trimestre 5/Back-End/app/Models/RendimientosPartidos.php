<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class RendimientosPartidos extends Model
{
    protected $table = 'RendimientosPartidos';
    protected $primaryKey = 'idRendimientos';
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

    // Relación con jugadores
    public function jugador()
    {
        return $this->belongsTo(Jugadores::class, 'idJugadores', 'idJugadores');
    }

    // Relación con partidos
    public function partido()
    {
        return $this->belongsTo(Partidos::class, 'idPartidos', 'idPartidos');
    }
}
