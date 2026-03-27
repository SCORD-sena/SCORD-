<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Categorias extends Model
{
    public $incrementing = true;
    protected $keyType = 'int';
    protected $table = 'Categorias';
    protected $primaryKey = 'idCategorias';
    public $timestamps = false;

    protected $fillable = [
        'Descripcion',
        'TiposCategoria'
    ];

    // Relación con entrenadores (si realmente está por categoría)
    public function entrenadores()
    {
        return $this->hasMany(Entrenadores::class, 'idCategorias', 'idCategorias');
    }

    // Relación con jugadores (CORREGIDA)
    public function jugadores()
    {
        return $this->hasMany(Jugadores::class, 'idCategorias', 'idCategorias');
    }
}
