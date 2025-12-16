<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class cronogramas extends Model
{
    protected $table = 'cronogramas';

    protected $primaryKey = 'idCronograma'; // Clave primaria personalizada

    public $timestamps = false; // Si tu tabla no tiene created_at/updated_at

    protected $fillable = [
        'idCronograma',
        'FechaDeEventos',
        'TipoDeEventos',
        'CanchaPartido',
        'Ubicacion',
        'SedeEntrenamiento',
        'Descripcion'
    ];
}