<?php

namespace Database\Factories;

use App\Models\Jugadores;
use App\Models\Partidos;
use Illuminate\Database\Eloquent\Factories\Factory;

class RendimientosPartidosFactory extends Factory
{
    public function definition(): array
    {
        return [
            'idJugadores'    => Jugadores::factory(),
            'idPartidos'     => Partidos::factory(),
            'Goles'          => fake()->numberBetween(0, 5),
            'Asistencias'    => fake()->numberBetween(0, 5),
            'TarjetasA'      => fake()->numberBetween(0, 2),
            'TarjetasR'      => fake()->numberBetween(0, 1),
            'MinutosJugados' => fake()->numberBetween(0, 90),
        ];
    }
}