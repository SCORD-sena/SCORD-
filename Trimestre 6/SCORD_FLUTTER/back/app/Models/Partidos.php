<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;


class Partidos extends Model
{
    protected $table = 'Partidos';

    protected $primaryKey = 'idPartidos'; // Clave primaria personalizada

    public $timestamps = false; // Si tu tabla no tiene created_at/updated_at

    protected $fillable = [
        'Formacion',
        'EquipoRival',
        'idCronogramas'
    ];


public function cronogramas(): BelongsTo
{
    return $this->belongsTo(Cronogramas::class, 'idCronogramas', 'idCronogramas');
}

public function rendimientosPartidos()
{
    return $this->hasMany(RendimientosPartidos::class, 'idPartidos', 'idPartidos');
}
public function resultados()
{
    return $this->hasMany(Resultados::class, 'idPartidos', 'idPartidos');
}
public function PartidosEquipos()
{
    return $this->hasMany(PartidosEquipos::class, 'idPartidos', 'idPartidos');
}
}