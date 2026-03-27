<?php

namespace Database\Factories;

use App\Models\Personas;
use App\Models\Categorias;
use App\Models\TiposDeDocumentos;
use App\Models\Roles;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;

class JugadoresFactory extends Factory
{
    public function definition(): array
    {
        // Garantizar registros base
        TiposDeDocumentos::firstOrCreate(
            ['idTiposDeDocumentos' => 1],
            ['NombreTipo' => 'Cedula']
        );
        Roles::firstOrCreate(
            ['idRoles' => 3],
            ['NombreRol' => 'Jugador']
        );

        $persona = Personas::factory()->create([
            'idRoles'             => 3,
            'idTiposDeDocumentos' => 1,
            'contrasena'          => Hash::make('Password123!'),
        ]);

        return [
            'Dorsal'                      => fake()->numberBetween(1, 99),
            'Posicion'                    => fake()->randomElement(['Portero', 'Defensa', 'Mediocampista', 'Delantero']),
            'Upz'                         => fake()->numerify('###'),
            'Estatura'                    => fake()->randomFloat(2, 1.50, 2.00),
            'NomTutor1'                   => fake()->firstName(),
            'NomTutor2'                   => fake()->optional()->firstName(),
            'ApeTutor1'                   => fake()->lastName(),
            'ApeTutor2'                   => fake()->optional()->lastName(),
            'TelefonoTutor'               => fake()->numerify('##########'),
            'idPersonas'                  => $persona->idPersonas, // ← FK real
            'idCategorias'                => Categorias::factory(),
            'fechaIngresoClub'            => fake()->date('Y-m-d', '-1 year'),
            'fechaVencimientoMensualidad' => fake()->dateTimeBetween('now', '+2 months')->format('Y-m-d'),
        ];
    }
}