<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Equipos extends Model
{
    protected $table = 'equipos';

    protected $primaryKey = 'idEquipo'; // Clave primaria personalizada

    public $timestamps = false; // Si tu tabla no tiene created_at/updated_at

    protected $fillable = [
        'idEquipo',
        'CantidadJugadores',
        'Sub'
    ];
}