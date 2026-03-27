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
<<<<<<< HEAD
        'idCategorias',
        'idCompetencias'
=======
        'idCategorias'
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
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
<<<<<<< HEAD
    // Relación: un cronograma pertenece a una competencia
    public function competencia(): BelongsTo
    {
        return $this->belongsTo(Competencias::class, 'idCompetencias', 'idCompetencias');
    }  
=======
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
}