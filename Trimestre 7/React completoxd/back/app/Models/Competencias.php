<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Competencias extends Model
{
    use SoftDeletes;

    protected $table = 'competencias';
    protected $primaryKey = 'idCompetencias';
    public $timestamps = false;

    protected $fillable = [
        'Nombre',
        'TipoCompetencia',
        'Ano',
        'idCategorias'
    ];

    protected $dates = ['deleted_at'];

    // ============================================
    // RELACIONES
    // ============================================
    
    /**
     * Una competencia pertenece a una categoría
     */
    public function categoria()
    {
        return $this->belongsTo(Categorias::class, 'idCategorias', 'idCategorias');
    }

    /**
     * Una competencia tiene muchos cronogramas
     */
    public function cronogramas()
    {
        return $this->hasMany(Cronogramas::class, 'idCompetencias', 'idCompetencias');
    }
}