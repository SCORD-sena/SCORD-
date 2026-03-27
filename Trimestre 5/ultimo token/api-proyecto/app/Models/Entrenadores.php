<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;


class Entrenadores extends Model
{
    protected $table = 'Entrenadores';       // Nombre de la tabla en BD
    protected $primaryKey = 'idEntrenadores'; // Llave primaria
    public $timestamps = false;  
       protected $fillable=[
        'idEntrenadores',
        'NumeroDeDocumento',
        'AnosDeExperiencia',
        'Cargo',
       ];
         public function tipoDocumento(): BelongsTo
    {
        return $this->BelongsTo(Personas::class,'NumeroDeDocumento');
    }

}
