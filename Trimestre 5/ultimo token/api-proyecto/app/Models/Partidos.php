<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Partidos extends Model
{
    protected $table = 'Partidos';

    protected $primaryKey = 'idPartido'; // Clave primaria personalizada

    public $timestamps = false; // Si tu tabla no tiene created_at/updated_at

    protected $fillable = [
        'idPartido',
        'Formacion',
        'EquipoRival',
        'idCronograma'
    ];


public function cronograma(): BelongsTo
{
    return $this->belongsTo(cronogramas::class, 'idCronograma');
}
}