<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Jugadores extends Model
{
    use HasFactory;

    protected $table = 'Jugadores';
    protected $primaryKey = 'idJugadores';
    public $timestamps = false;

    protected $fillable = [
        'Dorsal',
        'Posicion',
        'Upz',
        'Estatura',
        'NomTutor1',
        'NomTutor2',
        'ApeTutor1',
        'ApeTutor2',
        'TelefonoTutor',
        'idPersonas',   
        'idCategorias'
    ];

    // ==========================
    // RELACIONES
    // ==========================

    // Un jugador pertenece a una persona
    public function persona()
    {
        return $this->belongsTo(Personas::class, 'idPersonas', 'idPersonas');
    }

    // Un jugador pertenece a una categoría
    public function categoria()
    {
        return $this->belongsTo(Categorias::class, 'idCategorias', 'idCategorias');
    }

    // Un jugador tiene muchos rendimientos en partidos
    public function rendimientosPartidos()
    {
        return $this->hasMany(RendimientosPartidos::class, 'idJugadores', 'idJugadores');
    }
}
