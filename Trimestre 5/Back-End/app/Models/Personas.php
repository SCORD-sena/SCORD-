<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Tymon\JWTAuth\Contracts\JWTSubject;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Personas extends Authenticatable implements JWTSubject
{
    use HasFactory, Notifiable;

    protected $table = 'Personas';
    protected $primaryKey = 'idPersonas';
    public $incrementing = false;
    protected $keyType = 'integer';

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
        'contrasena',
        'idTiposDeDocumentos',
        'idRoles',
    ];

    protected $hidden = [
        'contrasena',
        'remember_token',
    ];

    protected $casts = [
        'FechaDeNacimiento' => 'date',

    ];

    const CREATED_AT = null;
    const UPDATED_AT = null;

    public function getAuthPassword()
    {
        return $this->contrasena;
    }

    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    public function getJWTCustomClaims()
    {
        return [];
    }

    public function isAdmin()
    {
        return $this->idRoles === 1;
    }

    public function isEntrenador()
    {
        return $this->idRoles === 2;
    }

    public function isJugador()
    {
        return $this->idRoles === 3;
    }

    // Relaciones
    public function tipoDocumento(): BelongsTo
    {
        return $this->belongsTo(TipoDeDocumento::class, 'idTiposDeDocumentos', 'idTiposDeDocumentos');
    }

    public function rol(): BelongsTo
    {
        return $this->belongsTo(Roles::class, 'idRoles', 'idRoles');
    }
}