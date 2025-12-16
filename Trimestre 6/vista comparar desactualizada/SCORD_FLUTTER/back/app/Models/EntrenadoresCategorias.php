<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class EntrenadoresCategorias extends Model
{
    use HasFactory;
    protected $table = 'entrenadorescategorias'; // Nombre de la tabla pivote
    public $incrementing = false;
    public $timestamps = false;
    protected $primaryKey = null;

    protected $fillable = [
        'idCategorias',
        'idEntrenadores'
    ];

    // Relaciones
    public function categoria()
    {
        return $this->belongsTo(Categorias::class, 'idCategorias');
    }

    public function entrenador()
    {
        return $this->belongsTo(Entrenadores::class, 'idEntrenadores');
    }
}