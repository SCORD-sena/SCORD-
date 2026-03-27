<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
<<<<<<< HEAD
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
=======
use Illuminate\Database\Eloquent\Relations\BelongsTo;

>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b

class Categorias extends Model
{
    public $incrementing = true;
    protected $keyType = 'int';
    protected $table = 'Categorias';
<<<<<<< HEAD
    protected $primaryKey = 'idCategorias';
    public $timestamps = false;
=======

    protected $primaryKey = 'idCategorias'; // Clave primaria personalizada

    public $timestamps = false; // Si tu tabla no tiene created_at/updated_at
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b

    protected $fillable = [
        'idCategorias',
        'Descripcion',
        'TiposCategoria'
    ];

<<<<<<< HEAD
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
=======

public function Entrenadores()
{
    return $this->hasMany(Entrenadores::class, 'idEntrenadores', 'idEntrenadores');
}

public function Jugadores()
{
    return $this->hasMany(Jugadores::class, 'idJugadores', 'idJugadores');
}

public function cronogramas()
{
    return $this->hasMany(Cronogramas::class, 'idCategorias', 'idCategorias');
}
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
}