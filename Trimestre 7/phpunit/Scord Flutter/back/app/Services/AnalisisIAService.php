<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;

class AnalisisIAService
{
    private $usarGroq = true; // ⚡ USAR GROQ (NUBE) EN LUGAR DE OLLAMA LOCAL
    private $groqApiKey;
    private $ollamaUrl = 'http://localhost:11434/api/generate';
    private $modelo = 'llama3.2:3b';
    
    public function __construct()
    {
        $this->groqApiKey = env('GROQ_API_KEY');
    }
    
    /**
     * Genera análisis detallado del rendimiento del jugador
     */
    public function generarAnalisisJugador($jugador, $totales, $promedios, $totalPartidos, $ultimosPartidos, $competencia = null)
    {
        try {
            // Si no hay partidos, retornar null
            if ($totalPartidos === 0) {
                return null;
            }

            // CACHEAR EL ANÁLISIS POR 24 HORAS
            $cacheKey = $this->generarCacheKey($jugador->idJugadores, $competencia);
            
            return Cache::remember($cacheKey, 86400, function() use ($jugador, $totales, $promedios, $totalPartidos, $ultimosPartidos, $competencia) {
                
                if ($this->usarGroq && $this->groqApiKey) {
                    Log::info('🌐 [IA] Usando Groq API (nube)');
                    return $this->generarConGroq($jugador, $totales, $promedios, $totalPartidos, $ultimosPartidos, $competencia);
                } else {
                    Log::info('💻 [IA] Usando Ollama local');
                    return $this->generarAnalisisNuevo($jugador, $totales, $promedios, $totalPartidos, $ultimosPartidos, $competencia);
                }
            });

        } catch (\Exception $e) {
            Log::error('❌ Error generando análisis IA: ' . $e->getMessage());
            return null;
        }
    }

    /**
     * 🌐 GENERAR CON GROQ (API EN LA NUBE - RÁPIDO Y GRATIS)
     */
    private function generarConGroq($jugador, $totales, $promedios, $totalPartidos, $ultimosPartidos, $competencia)
    {
        try {
            $prompt = $this->construirPromptOptimizado($jugador, $totales, $promedios, $totalPartidos, $ultimosPartidos, $competencia);
            
            Log::info('🤖 [IA] Generando análisis con Groq para jugador: ' . $jugador->idJugadores);
            
            $startTime = microtime(true);
            
            $response = Http::timeout(30)
                ->withHeaders([
                    'Authorization' => 'Bearer ' . $this->groqApiKey,
                    'Content-Type' => 'application/json',
                ])
                ->post('https://api.groq.com/openai/v1/chat/completions', [
                    'model' => 'llama-3.3-70b-versatile', // Modelo rápido de Groq
                    'messages' => [
                        [
                            'role' => 'system',
                            'content' => 'Eres un analista deportivo profesional especializado en fútbol juvenil. Genera análisis en texto plano sin usar asteriscos, negritas ni formato Markdown.'
                        ],
                        [
                            'role' => 'user',
                            'content' => $prompt
                        ]
                    ],
                    'temperature' => 0.7,
                    'max_tokens' => 400,
                ]);

            $endTime = microtime(true);
            $duration = round($endTime - $startTime, 2);
            
            Log::info("⏱️ [IA] Groq respondió en: {$duration} segundos");

            if ($response->successful()) {
                $data = $response->json();
                $analisis = $data['choices'][0]['message']['content'] ?? null;
                
                if ($analisis && strlen(trim($analisis)) > 50) {
                    Log::info('✅ [IA] Análisis generado con Groq (' . strlen($analisis) . ' caracteres)');
                    return $this->limpiarAnalisis($analisis);
                } else {
                    Log::warning('⚠️ [IA] Groq respondió pero el contenido es muy corto');
                    return null;
                }
            }

            Log::warning('⚠️ [IA] Groq no respondió correctamente. Status: ' . $response->status());
            Log::warning('⚠️ [IA] Response body: ' . $response->body());
            return null;

        } catch (\Exception $e) {
            Log::error('❌ [IA] Error con Groq: ' . $e->getMessage());
            return null;
        }
    }

    /**
     * Genera clave única de caché
     */
    private function generarCacheKey($idJugador, $competencia)
    {
        $competenciaId = $competencia ? $competencia->idCompetencias : 'general';
        return "analisis_ia_jugador_{$idJugador}_comp_{$competenciaId}"; // ← CORREGIDO: agregado guion bajo
    }

    /**
     * 💻 GENERAR CON OLLAMA LOCAL (BACKUP)
     */
    private function generarAnalisisNuevo($jugador, $totales, $promedios, $totalPartidos, $ultimosPartidos, $competencia)
    {
        $prompt = $this->construirPromptOptimizado($jugador, $totales, $promedios, $totalPartidos, $ultimosPartidos, $competencia);
        
        Log::info('🤖 [IA] Generando análisis con Ollama para jugador: ' . $jugador->idJugadores);
        
        try {
            $startTime = microtime(true);
            
            $response = Http::timeout(120)
                ->withOptions(['connect_timeout' => 10])
                ->post($this->ollamaUrl, [
                    'model' => $this->modelo,
                    'prompt' => $prompt,
                    'stream' => false,
                    'options' => [
                        'temperature' => 0.7,
                        'top_p' => 0.9,
                        'num_predict' => 300,
                        'num_ctx' => 1024,
                    ]
                ]);

            $endTime = microtime(true);
            $duration = round($endTime - $startTime, 2);
            
            Log::info("⏱️ [IA] Ollama respondió en: {$duration} segundos");

            if ($response->successful()) {
                $data = $response->json();
                $analisis = $data['response'] ?? null;
                
                if ($analisis && strlen(trim($analisis)) > 50) {
                    Log::info('✅ [IA] Análisis generado con Ollama');
                    return $this->limpiarAnalisis($analisis);
                }
            }

            Log::warning('⚠️ [IA] Ollama no respondió correctamente');
            return null;

        } catch (\Exception $e) {
            Log::error('❌ [IA] Error con Ollama: ' . $e->getMessage());
            return null;
        }
    }

    /**
     * PROMPT OPTIMIZADO SEGÚN POSICIÓN DEL JUGADOR
     */
    private function construirPromptOptimizado($jugador, $totales, $promedios, $totalPartidos, $ultimosPartidos, $competencia)
    {
        $nombre = trim("{$jugador->persona->Nombre1} {$jugador->persona->Apellido1}");
        $posicion = $jugador->Posicion;
        $categoria = $jugador->categoria->Descripcion ?? 'Sin categoría';
        
        $tipoReporte = $competencia ? $competencia->Nombre : "todas las competencias";
        
        $esPortero = $this->esPortero($posicion);
        
        if ($esPortero) {
            // PROMPT PARA PORTEROS
            $prompt = "Analiza al portero {$nombre} de categoría {$categoria} en {$tipoReporte}.

ESTADÍSTICAS ({$totalPartidos} partidos):
- Arcos en cero (vallas invictas): {$totales['ArcoEnCero']} partidos
- Goles anotados: {$totales['Goles']} (goles que ÉL marcó, NO goles recibidos)
- Asistencias: {$totales['Asistencias']}
- Minutos jugados: {$totales['MinutosJugados']} (promedio {$promedios['MinutosPromedio']} por partido)
- Tarjetas amarillas: {$totales['TarjetasAmarillas']}
- Tarjetas rojas: {$totales['TarjetasRojas']}

IMPORTANTE: Los goles mostrados son goles QUE ÉL ANOTÓ, no goles en contra. Para evaluar su rendimiento defensivo usa ARCOS EN CERO.

Genera un análisis profesional en texto plano (SIN asteriscos, SIN negritas, SIN formato especial), máximo 150 palabras, que incluya:

RESUMEN: 1-2 líneas sobre su rendimiento defensivo, destacando arcos en cero.

PUNTOS FUERTES: 2-3 aspectos positivos basados en las estadísticas. Si tiene buenos arcos en cero, menciona solidez defensiva. Si anotó goles, menciona capacidad ofensiva inusual. Si tiene asistencias, destaca juego con pies.

ÁREAS DE MEJORA: 1-2 aspectos específicos donde puede mejorar como portero.

RECOMENDACIÓN: 1 sugerencia concreta para su entrenamiento como portero.

Escribe en párrafos naturales. Tono profesional y motivador.";

        } else {
            // PROMPT PARA JUGADORES DE CAMPO
            $prompt = "Analiza al jugador {$nombre} ({$posicion}) de categoría {$categoria} en {$tipoReporte}.

ESTADÍSTICAS ({$totalPartidos} partidos):
- Goles: {$totales['Goles']} (promedio {$promedios['GolesPromedio']} por partido)
- Goles de cabeza: {$totales['GolesDeCabeza']}
- Asistencias: {$totales['Asistencias']} (promedio {$promedios['AsistenciasPromedio']} por partido)
- Minutos jugados: {$totales['MinutosJugados']} (promedio {$promedios['MinutosPromedio']} por partido)
- Tiros a puerta: {$totales['TirosApuerta']} (promedio {$promedios['TirosPromedio']} por partido)
- Tarjetas amarillas: {$totales['TarjetasAmarillas']}
- Tarjetas rojas: {$totales['TarjetasRojas']}
- Fueras de lugar: {$totales['FuerasDeLugar']}

Genera un análisis profesional en texto plano (SIN asteriscos, SIN negritas, SIN formato especial), máximo 150 palabras, que incluya:

RESUMEN: 1-2 líneas sobre su rendimiento general según su posición.

PUNTOS FUERTES: 2-3 aspectos positivos basados en datos. Si tiene buenos goles/asistencias, destaca efectividad ofensiva. Si juega muchos minutos, menciona importancia en el equipo. Si tiene pocos fueras de lugar, destaca inteligencia táctica.

ÁREAS DE MEJORA: 1-2 aspectos específicos donde puede mejorar según su posición.

RECOMENDACIÓN: 1 sugerencia concreta para su desarrollo según su posición.

Escribe en párrafos naturales. Tono profesional y motivador.";
        }

        return $prompt;
    }

    /**
     * Determina si el jugador es portero
     */
    private function esPortero($posicion)
    {
        $posicion = strtolower(trim($posicion));
        
        $posicionesPortero = [
            'portero',
            'arquero',
            'guardameta',
            'goalkeeper',
            'gk',
            'porter'
        ];
        
        foreach ($posicionesPortero as $pos) {
            if (strpos($posicion, $pos) !== false) {
                return true;
            }
        }
        
        return false;
    }

    /**
     * Limpia el análisis generado y quita formato Markdown
     */
    private function limpiarAnalisis($analisis)
    {
        if (!$analisis) {
            return null;
        }

        // Quitar formato Markdown - CORREGIDO
        $analisis = preg_replace('/\*\*(.*?)\*\*/', '$1', $analisis); // Quitar negritas **texto**
        $analisis = preg_replace('/\*(.*?)\*/', '$1', $analisis);     // Quitar itálicas *texto*
        $analisis = preg_replace('/#{1,6}\s/', '', $analisis);        // Quitar headers # ## ###
        $analisis = preg_replace('/\[([^\]]+)\]\([^\)]+\)/', '$1', $analisis); // Quitar links
        
        // Quitar múltiples saltos de línea
        $analisis = preg_replace('/\n{3,}/', "\n\n", $analisis);
        
        // Limpiar espacios extras
        $analisis = trim($analisis);
        
        return $analisis;
    }

    /**
     * MÉTODO PARA LIMPIAR CACHÉ MANUALMENTE
     */
    public function limpiarCacheJugador($idJugador, $idCompetencia = null)
    {
        $competenciaId = $idCompetencia ?? 'general';
        $cacheKey = "analisis_ia_jugador_{$idJugador}_comp_{$competenciaId}"; // ← CORREGIDO
        Cache::forget($cacheKey);
        Log::info("🗑️ [IA] Caché limpiado para jugador {$idJugador}");
    }
}