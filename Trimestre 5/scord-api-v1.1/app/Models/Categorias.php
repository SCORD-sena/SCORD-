<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Categorias extends Model
{
    use HasFactory;

    // Nombre de la tabla (opcional si sigue convención Laravel)
    protected $table = 'Categorias';

    // Clave primaria (opcional si se llama 'id')
    protected $primaryKey = 'idCategorias';

    // Campos que pueden ser asignados masivamente
    protected $fillable = [
        'descripcion',
        'TiposCategoria'
    ];
}


