<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Competencias extends Model
{
    protected $table = 'Competencias';

    protected $primaryKey = 'idCompetencias'; // Clave primaria personalizada

    public $timestamps = false; // Si tu tabla no tiene created_at/updated_at

    protected $fillable = [
        'idCompetencias',
        'Nombre',
        'TipoCompetencia',
        'Ano',
        'idEquipos'
    ];
  public function equipos()
  {
    return $this->BelongsTo(Equipos::class,'idEquipos');
  }
}
