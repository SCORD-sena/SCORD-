<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class TiposDeDocumentos extends Model
{
    protected $table = 'TiposDeDocumentos';

    protected $primaryKey = 'idTiposDeDocumentos';

    public $timestamps = false;

    protected $fillable = [
         'idTiposDeDocumentos',
          'Descripcion'
    
    ];

    public function personas(): HasMany
    {
        return $this->hasMany(Personas::class, 'idTiposDeDocumentos');
    }
}
