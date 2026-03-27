<?php

namespace Database\Factories;

use App\Models\Partidos;
use Illuminate\Database\Eloquent\Factories\Factory;

class ResultadosFactory extends Factory
{
    public function definition(): array
    {
        return [
            'idPartidos'     => Partidos::factory(),
            'GolesLocal'     => fake()->numberBetween(0, 10),
            'GolesVisitante' => fake()->numberBetween(0, 10),
        ];
    }
}