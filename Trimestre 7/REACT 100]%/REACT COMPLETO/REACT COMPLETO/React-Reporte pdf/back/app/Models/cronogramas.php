<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Cronogramas extends Model
{
    use SoftDeletes;

    protected $table      = 'Cronogramas';
    protected $primaryKey = 'idCronogramas';
    public    $timestamps = false;

    protected $dates = ['deleted_at'];

    protected $fillable = [
        'FechaDeEventos',
        'hora',
        'TipoDeEventos',
        'CanchaPartido',
        'Ubicacion',
        'SedeEntrenamiento',
        'Descripcion',
        'idCategorias',
        'idCompetencias',
    ];

    // ── Relaciones hacia arriba (BelongsTo) ──────────────────────
    public function competencia(): BelongsTo
    {
        return $this->belongsTo(Competencias::class, 'idCompetencias', 'idCompetencias');
    }

    public function categoria(): BelongsTo
    {
        return $this->belongsTo(Categorias::class, 'idCategorias', 'idCategorias');
    }

    // ── Relaciones hacia abajo (HasMany) ─────────────────────────
    public function partidos(): HasMany
    {
        return $this->hasMany(Partidos::class, 'idCronogramas', 'idCronogramas');
    }
}