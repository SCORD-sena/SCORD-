<?php

namespace Database\Factories;

use App\Models\Equipos;
use Illuminate\Database\Eloquent\Factories\Factory;

class CompetenciasFactory extends Factory
{
    public function definition(): array
    {
        return [
            'Nombre'          => fake()->words(2, true),
            'TipoCompetencia' => fake()->randomElement(['Liga', 'Copa', 'Torneo', 'Amistoso']),
            'Ano'             => fake()->year(),
            'idEquipos'       => Equipos::factory(),
        ];
    }
}