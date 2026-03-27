<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class EquiposFactory extends Factory
{
    public function definition(): array
    {
        return [
            'CantidadJugadores' => fake()->numberBetween(11, 25),
            'Sub'               => 'Sub-' . fake()->numberBetween(8, 20),
        ];
    }
}