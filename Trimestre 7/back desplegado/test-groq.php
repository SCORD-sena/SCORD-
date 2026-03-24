<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$apiKey = env('GROQ_API_KEY');

echo "========================================\n";
echo "TEST DE CONEXIÓN CON GROQ\n";
echo "========================================\n\n";

echo "API Key detectada: " . ($apiKey ? "SÍ (primeros 15 chars: " . substr($apiKey, 0, 15) . "...)" : "❌ NO") . "\n\n";

if (!$apiKey) {
    die("❌ ERROR: No se detectó GROQ_API_KEY en .env\nVerifica que esté correctamente configurada.\n");
}

try {
    echo "Probando conexión con Groq...\n";
    
    $response = \Illuminate\Support\Facades\Http::timeout(30)
        ->withHeaders([
            'Authorization' => 'Bearer ' . $apiKey,
            'Content-Type' => 'application/json',
        ])
        ->post('https://api.groq.com/openai/v1/chat/completions', [
            'model' => 'llama-3.3-70b-versatile',
            'messages' => [
                [
                    'role' => 'user',
                    'content' => 'Di "hola" en una sola palabra'
                ]
            ],
            'max_tokens' => 10,
        ]);

    if ($response->successful()) {
        $data = $response->json();
        echo "\n✅ ¡ÉXITO! Groq está respondiendo correctamente.\n\n";
        echo "Respuesta de Groq: " . ($data['choices'][0]['message']['content'] ?? 'Sin contenido') . "\n\n";
        echo "========================================\n";
        echo "Todo está funcionando bien. Ahora genera un PDF desde tu app.\n";
        echo "========================================\n";
    } else {
        echo "\n❌ ERROR! Groq no respondió correctamente.\n";
        echo "Status Code: " . $response->status() . "\n";
        echo "Respuesta: " . $response->body() . "\n\n";
        
        if ($response->status() == 401) {
            echo "⚠️ Error 401: La API Key es inválida o expiró.\n";
            echo "Ve a https://console.groq.com/keys y genera una nueva.\n";
        }
    }
    
} catch (\Exception $e) {
    echo "\n❌ EXCEPCIÓN: " . $e->getMessage() . "\n";
    echo "\nVerifica tu conexión a internet.\n";
}

echo "\n";