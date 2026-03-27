<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Tymon\JWTAuth\Contracts\JWTSubject;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Personas extends Authenticatable implements JWTSubject
{
    protected $table = 'Personas'; // Usa mayúsculas si tu tabla realmente está así

    protected $primaryKey = 'NumeroDeDocumento'; // Clave primaria personalizada
    public $incrementing = false; // Si es un número de documento (no autoincremental)

    public $timestamps = false;

    protected $fillable = [
        'NumeroDeDocumento',
        'Nombre1',
        'Nombre2',
        'Apellido1',
        'Apellido2',
        'FechaDeNacimiento',
        'Genero',
        'Telefono',
        'EpsSisben', 
        'Direccion',
        'correo',
        'contraseña',
        'idTiposDeDocumentos',
        'idRoles',
    ];

    protected $hidden = [
        'contraseña', // para que no se devuelva en JSON
    ];

    // Relación con Tipos de Documentos
    public function tipoDocumento(): BelongsTo
    {
        return $this->belongsTo(TipoDeDocumento::class,'idTiposDeDocumentos');
    }

    // Relación con Roles
    public function rol(): BelongsTo
    {
        return $this->belongsTo(Roles::class,'idRoles','idRoles');
    }

    // === Métodos requeridos por JWT ===
    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    public function getJWTCustomClaims()
    {
        return [];
    }
    public function getAuthPassword()
    {
    return $this->contraseña;
    }
    public function setPasswordAttribute($value)
{
    $this->attributes['contraseña'] = bcrypt($value);
}
    public function getAuthIdentifierName()
{
    return 'correo';  // para que Laravel sepa que el username es 'correo' y no 'email'
}



}
