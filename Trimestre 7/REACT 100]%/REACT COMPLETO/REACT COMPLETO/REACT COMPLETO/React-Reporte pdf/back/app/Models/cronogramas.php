<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes; // ← NUEVO

class cronogramas extends Model
{
    use SoftDeletes; // ← AGREGADO SoftDeletes

    protected $table = 'Cronogramas';
    protected $primaryKey = 'idCronogramas';
    public $timestamps = false;

    protected $fillable = 
    [
        'FechaDeEventos',
        'Hora',
        'TipoDeEventos',
        'CanchaPartido',
        'Ubicacion',
        'SedeEntrenamiento',
        'Descripcion',
        'idCategorias',
        'idCompetencias'
    ];

    // Relación: un cronograma tiene muchos partidos
    public function partidos(): HasMany
    {
        return $this->hasMany(Partidos::class, 'idCronogramas', 'idCronogramas');
    }

    // Relación: un cronograma pertenece a una categoría
    public function categoria(): BelongsTo
    {
        return $this->belongsTo(Categorias::class, 'idCategorias', 'idCategorias');
    }

    // Relación: un cronograma pertenece a una competencia
    public function competencia(): BelongsTo
    {
        return $this->belongsTo(Competencias::class, 'idCompetencias', 'idCompetencias');
    }  
}