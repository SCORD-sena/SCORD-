<?php

namespace Database\Factories;

use App\Models\Partidos;
use App\Models\Equipos;
use Illuminate\Database\Eloquent\Factories\Factory;

class PartidosEquiposFactory extends Factory
{
    public function definition(): array
    {
        return [
            'idPartidos' => Partidos::factory(),
            'idEquipos'  => Equipos::factory(),
        ];
    }
}