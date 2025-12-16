<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        // Registrar middlewares personalizados con alias
        $middleware->alias([
            'auth.entrenador' => \App\Http\Middleware\IsEntrenador::class,
            'auth.administrador' => \App\Http\Middleware\IsAdmin::class, 
            'auth.Jugador' => \App\Http\Middleware\IsJugador::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        //
    })->create();
