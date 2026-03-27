<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Personas>
 */
class PersonasFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
   public function definition(): array
{
    return [
        'NumeroDeDocumento'   => fake()->unique()->numerify('##########'),
        'Nombre1'             => fake()->firstName(),
        'Apellido1'           => fake()->lastName(),
        'Apellido2'           => fake()->lastName(),
        'FechaDeNacimiento'   => fake()->date(),
        'Genero'              => 'M',
        'EpsSisben'           => 'Sura',
        'Direccion'           => fake()->address(),
        'Telefono'            => fake()->numerify('##########'),
        'correo'              => fake()->unique()->safeEmail(),
        'contrasena'          => ('Password123!'),
        'idTiposDeDocumentos' => 1,
        'idRoles'             => 1,
    ];
}
}
