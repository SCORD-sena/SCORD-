<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class CategoriasFactory extends Factory
{
    public function definition(): array
    {
        return [
            'Descripcion'    => 'Sub-' . fake()->numberBetween(8, 20),
            'TiposCategoria' => fake()->randomElement(['Masculino', 'Femenino', 'Mixto']),
        ];
    }
}