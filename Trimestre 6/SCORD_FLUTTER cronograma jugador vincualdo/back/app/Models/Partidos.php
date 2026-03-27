<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes; // ← NUEVO

class Partidos extends Model
{
    use SoftDeletes; // ← AGREGADO SoftDeletes

    protected $table = 'Partidos';
    protected $primaryKey = 'idPartidos';
    public $timestamps = false;

    protected $fillable = [
        'Formacion',
        'EquipoRival',
        'idCronogramas'
    ];

    public function cronogramas(): BelongsTo
    {
        return $this->belongsTo(Cronogramas::class, 'idCronogramas', 'idCronogramas');
    }

    public function rendimientosPartidos(): HasMany
    {
        return $this->hasMany(RendimientosPartidos::class, 'idPartidos', 'idPartidos');
    }

    public function resultados(): HasMany
    {
        return $this->hasMany(Resultados::class, 'idPartidos', 'idPartidos');
    }

    public function PartidosEquipos(): HasMany
    {
        return $this->hasMany(PartidosEquipos::class, 'idPartidos', 'idPartidos');
    }
}