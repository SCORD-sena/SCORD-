<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Categorias extends Model
{
    use SoftDeletes;

    protected $table      = 'Categorias';
    protected $primaryKey = 'idCategorias';
    public    $timestamps = false;

    protected $dates = ['deleted_at'];

    protected $fillable = [
        'Descripcion',
        'TiposCategoria',
    ];

    // ── Relaciones directas ───────────────────────────────────────
    public function cronogramas(): HasMany
    {
        return $this->hasMany(Cronogramas::class, 'idCategorias', 'idCategorias');
    }

    public function jugadores(): HasMany
    {
        return $this->hasMany(Jugadores::class, 'idCategorias', 'idCategorias');
    }

    public function entrenadores(): HasMany
    {
        return $this->hasMany(EntrenadoresCategorias::class, 'idCategorias', 'idCategorias');
    }

    // ── Relación a través de Cronogramas ─────────────────────────
    public function competencias()
    {
        return $this->hasManyThrough(
            Competencias::class,
            Cronogramas::class,
            'idCategorias',   // FK en Cronogramas apuntando a Categorias
            'idCompetencias', // FK en Competencias
            'idCategorias',   // PK local de Categorias
            'idCompetencias'  // FK en Cronogramas apuntando a Competencias
        );
    }

    // ── Partidos a través de Cronogramas ─────────────────────────
    public function partidos()
    {
        return $this->hasManyThrough(
            Partidos::class,
            Cronogramas::class,
            'idCategorias',  // FK en Cronogramas
            'idCronogramas', // FK en Partidos
            'idCategorias',  // PK local
            'idCronogramas'  // PK de Cronogramas
        );
    }
}