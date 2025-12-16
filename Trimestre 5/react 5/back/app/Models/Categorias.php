<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Categorias extends Model
{
    public $incrementing = true;
    protected $keyType = 'int';
    protected $table = 'Categorias';
    protected $primaryKey = 'idCategorias';
    public $timestamps = false;

    protected $fillable = [
        'idCategorias',
        'Descripcion',
        'TiposCategoria'
    ];

    // Relación Muchos a Muchos con Entrenadores (CORREGIDO)
    public function entrenadores(): BelongsToMany
    {
        return $this->belongsToMany(
            Entrenadores::class,
            'EntrenadoresCategorias', // tabla pivote
            'idCategorias',
            'idEntrenadores'
        );
    }

    // Relación con Jugadores
    public function jugadores(): HasMany
    {
        return $this->hasMany(Jugadores::class, 'idCategorias', 'idCategorias');
    }

    // Relación con Cronogramas
    public function cronogramas(): HasMany
    {
        return $this->hasMany(Cronogramas::class, 'idCategorias', 'idCategorias');
    }
}