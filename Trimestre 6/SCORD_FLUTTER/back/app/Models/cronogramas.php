<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class cronogramas extends Model
{
    protected $table = 'Cronogramas';

    protected $primaryKey = 'idCronogramas'; // Clave primaria personalizada

    public $timestamps = false; // Si tu tabla no tiene created_at/updated_at

    protected $fillable = 
    [
        'FechaDeEventos',
        'TipoDeEventos',
        'CanchaPartido',
        'Ubicacion',
        'SedeEntrenamiento',
        'Descripcion',
        'idCategorias'
    ];

    // Relación: un cronograma tiene muchos partidos
    public function partidos()
    {
        return $this->hasMany(Partidos::class, 'idCronogramas', 'idCronogramas');
    }
    // Relación: un cronograma pertenece a una categoría
    public function categoria(): BelongsTo
    {
        return $this->belongsTo(Categorias::class, 'idCategorias', 'idCategorias');
    }
}