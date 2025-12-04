<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Entrenadores extends Model
{
    protected $table = 'Entrenadores';
    protected $primaryKey = 'idEntrenadores';
    public $timestamps = false;
    
    protected $fillable = [
        'idPersonas', 
        'AnosDeExperiencia',
        'Cargo',
    ];

    // Relación con Personas (Un entrenador pertenece a UNA persona)
    public function persona(): BelongsTo
    {
        return $this->belongsTo(Personas::class, 'idPersonas', 'idPersonas');
    }

    // Relación Muchos a Muchos con Categorías
    public function categorias(): BelongsToMany
    {
        return $this->belongsToMany(
            Categorias::class,
            'EntrenadoresCategorias', // nombre de tu tabla pivote
            'idEntrenadores',
            'idCategorias'
        );
    }
}
