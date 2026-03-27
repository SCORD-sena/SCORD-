<?php

namespace Database\Factories;

use App\Models\Personas;
use App\Models\TiposDeDocumentos;
use App\Models\Roles;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;

class EntrenadoresFactory extends Factory
{
    public function definition(): array
    {
        // Garantizar que existan los registros base necesarios
        TiposDeDocumentos::firstOrCreate(
            ['idTiposDeDocumentos' => 1],
            ['NombreTipo' => 'Cedula']
        );
        Roles::firstOrCreate(
            ['idRoles' => 2],
            ['NombreRol' => 'Entrenador']
        );

        $persona = Personas::factory()->create([
            'idRoles'             => 2,
            'idTiposDeDocumentos' => 1,
            'contrasena'          => Hash::make('Password123!'),
        ]);

        return [
            'idPersonas'        => $persona->idPersonas,
            'AnosDeExperiencia' => fake()->numberBetween(1, 20),
            'Cargo'             => fake()->randomElement(['Entrenador Principal', 'Asistente', 'Preparador Físico']),
        ];
    }
}