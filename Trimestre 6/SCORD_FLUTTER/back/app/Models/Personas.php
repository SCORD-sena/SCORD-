<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Tymon\JWTAuth\Contracts\JWTSubject;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Personas extends Authenticatable implements JWTSubject
{
    use HasFactory, Notifiable;

    protected $table = 'Personas';
    protected $primaryKey = 'idPersonas';
    public $incrementing = true;
    protected $keyType = 'int';

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

    /*
    |--------------------------------------------------------------------------
    | Autenticación con JWT
    |--------------------------------------------------------------------------
    */
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

    /*
    |--------------------------------------------------------------------------
    | Helpers para roles
    |--------------------------------------------------------------------------
    */
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

    /*
    |--------------------------------------------------------------------------
    | Relaciones
    |--------------------------------------------------------------------------
    */

    // Relación con TiposDeDocumentos
    public function tiposDeDocumentos(): BelongsTo
    {
        return $this->belongsTo(TiposDeDocumentos::class, 'idTiposDeDocumentos', 'idTiposDeDocumentos');
    }

    // Relación con Roles
    public function rol(): BelongsTo
    {
        return $this->belongsTo(Roles::class, 'idRoles', 'idRoles');
    }

    // Relación con Jugadores
    public function jugadores(): HasMany
    {
        return $this->hasMany(Jugadores::class, 'idPersonas', 'idPersonas');
    }

    // Relación con Entrenadores
    public function entrenadores(): HasMany
    {
        return $this->hasMany(Entrenadores::class, 'idPersonas', 'idPersonas');
    }   
}
