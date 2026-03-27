<?php

namespace Database\Factories;

use App\Models\Categorias;
use App\Models\Competencias;
use Illuminate\Database\Eloquent\Factories\Factory;

class CronogramasFactory extends Factory
{
    public function definition(): array
    {
        return [
            'FechaDeEventos'    => fake()->dateTimeBetween('now', '+6 months')->format('Y-m-d'),
            'Hora'              => fake()->time('H:i:s'),
            'TipoDeEventos'     => fake()->randomElement(['Partido', 'Entrenamiento', 'Torneo']),
            'CanchaPartido'     => fake()->randomElement(['Cancha 1', 'Cancha 2', 'Estadio']),
            'Ubicacion'         => fake()->city(),
            'SedeEntrenamiento' => fake()->company(),
            'Descripcion'       => fake()->sentence(),
            'idCategorias'      => Categorias::factory(),
            'idCompetencias'    => Competencias::factory(),
        ];
    }
}