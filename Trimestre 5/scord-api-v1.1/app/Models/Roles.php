<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Roles extends Model
{
     protected $table = 'Roles';

    protected $primaryKey = 'idRoles';

    public $timestamps = false;
     public $incrementing = false; // 🔥 Muy importante para poder asignar idRoles manualmente
    protected $keyType = 'int'; // Para que lo trate como número y no como string


    protected $fillable = [
        'TipoDeRol',
        'idRoles'
    ];

    public function personas(): HasMany
    {
        return $this->hasMany(Personas::class, 'idRoles');
    }
}
