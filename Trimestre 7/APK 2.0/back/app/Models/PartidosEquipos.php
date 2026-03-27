<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PartidosEquipos extends Model
{
    use HasFactory;

    protected $table = 'PartidosEquipos'; // Nombre de la tabla pivote
    public $incrementing = false;
    public $timestamps = false;
    protected $primaryKey = null;

    protected $fillable = [
        'idPartidos',
        'idEquipos',
        'EsLocal'
    ];

     protected $casts = [
        'EsLocal' => 'boolean', 
    ];

    // Relaciones
    public function partido()
    {
        return $this->belongsTo(Partidos::class, 'idPartidos');
    }

    public function equipo()
    {
        return $this->belongsTo(Equipos::class, 'idEquipos');
    }
}