<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;


class Categorias extends Model
{
    public $incrementing = true;
    protected $keyType = 'int';
    protected $table = 'Categorias';

    protected $primaryKey = 'idCategorias'; // Clave primaria personalizada

    public $timestamps = false; // Si tu tabla no tiene created_at/updated_at

    protected $fillable = [
        'idCategorias',
        'Descripcion',
        'TiposCategoria'
    ];


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
}