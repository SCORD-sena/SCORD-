<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Equipos extends Model
{
    protected $table = 'Equipos';

    protected $primaryKey = 'idEquipos'; // Clave primaria personalizada

    public $timestamps = false; // Si tu tabla no tiene created_at/updated_at

    protected $fillable = [
        'CantidadJugadores',
        'Sub'
    ];
    public function competencias()
    {
        return $this->hasmany(Competencias::class,'idCompetencias');
    }
    public function PartidosEquipos()
    {
        return $this->hasmany(PartidosEquipos::class, 'idEquipos', 'idEquipos');
    }
}