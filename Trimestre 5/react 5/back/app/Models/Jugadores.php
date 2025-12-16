<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Jugadores extends Model
{
    use HasFactory;

    // Nombre de la tabla
    protected $table = 'Jugadores';

    // Clave primaria
    protected $primaryKey = 'idJugadores';

    // Si no usas created_at y updated_at
    public $timestamps = false;

    // Campos que se pueden asignar masivamente
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
        'idPersonas',   // Clave foránea a personas    
        'idCategorias',        // Clave foránea a categorías
    ];

    /*
    |--------------------------------------------------------------------------
    | Relaciones
    |--------------------------------------------------------------------------
    */

    // Relación con personas (por NumeroDeDocumento)
    public function persona()
    {
        return $this->belongsTo(Personas::class, 'idPersonas', 'idPersonas');
    }


     //Relación con categorías
     public function categoria()
    {
       return $this->belongsTo(Categorias::class, 'idCategorias');
    }
    
    public function rendimientosPartidos()
    {
        return $this->hasMany(RendimientosPartidos::class, 'idJugadores', 'idJugadores');
    }
}