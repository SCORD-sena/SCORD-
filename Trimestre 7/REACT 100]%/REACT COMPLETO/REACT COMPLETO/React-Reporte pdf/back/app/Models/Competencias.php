<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Competencias extends Model
{
    use SoftDeletes;

    protected $table      = 'Competencias';
    protected $primaryKey = 'idCompetencias';
    public    $timestamps = false;

    protected $dates = ['deleted_at'];

    protected $fillable = [
        'Nombre',
        'TipoCompetencia',
        'Ano',
    ];

    public function cronogramas(): HasMany
    {
        return $this->hasMany(Cronogramas::class, 'idCompetencias', 'idCompetencias');
    }
}