<?php

namespace Database\Factories;

use App\Models\cronogramas;
use Illuminate\Database\Eloquent\Factories\Factory;

class PartidosFactory extends Factory
{
    public function definition(): array
    {
        return [
            'Formacion'     => fake()->randomElement(['4-3-3', '4-4-2', '3-5-2', '4-2-3-1']),
            'EquipoRival'   => fake()->company(),
            'idCronogramas' => cronogramas::factory(),
        ];
    }
}