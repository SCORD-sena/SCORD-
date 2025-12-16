<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Jugadores extends Model
{
    use HasFactory;

    // Nombre de la tabla
    protected $table = 'Jugadores';

    // Clave primaria
    protected $primaryKey = 'idJugadores';

    // Si no usas created_at y updated_at
    public $timestamps = false;

    // Campos que se pueden asignar masivamente
    protected $fillable = [
        'Dorsal',
        'Posicion',
        'Upz',
        'Estatura',
        'NomTutor1',
        'NomTutor2',
        'ApeTutor1',
        'ApeTutor2',
        'TelefonoTutor',
        'idPersonas',
        'idCategorias',
        'fechaIngresoClub',
        'fechaVencimientoMensualidad',
    ];

    // Castear fechas automaticamente
    protected $casts = [
        'fechaIngresoClub' => 'date',
        'fechaVencimientoMensualidad' => 'date',
        'Estatura' => 'float',
    ];

    /*
    |--------------------------------------------------------------------------
    | Relaciones
    |--------------------------------------------------------------------------
    */

    // Relacion con personas
    public function persona()
    {
        return $this->belongsTo(Personas::class, 'idPersonas', 'idPersonas');
    }

    // Relacion con categorias
    public function categoria()
    {
        return $this->belongsTo(Categorias::class, 'idCategorias');
    }
    
    public function rendimientosPartidos()
    {
        return $this->hasMany(RendimientosPartidos::class, 'idJugadores', 'idJugadores');
    }

    /*
    |--------------------------------------------------------------------------
    | Metodos Helper para Mensualidades
    |--------------------------------------------------------------------------
    */

    /**
     * Calcular tiempo en el club (en formato legible)
     * Retorna array con años, meses y dias
     */
    public function getTiempoEnClubAttribute()
    {
        if (!$this->fechaIngresoClub) {
            return null;
        }

        $fechaIngreso = Carbon::parse($this->fechaIngresoClub);
        $ahora = Carbon::now();

        $diff = $fechaIngreso->diff($ahora);

        return [
            'anios' => $diff->y,
            'meses' => $diff->m,
            'dias' => $diff->d,
            'total_dias' => (int) $fechaIngreso->diffInDays($ahora),
            'texto' => $this->formatearTiempoEnClub($diff)
        ];
    }

    /**
     * Formatear el tiempo en texto legible
     * CORREGIDO: Ahora muestra años, meses Y días cuando corresponde
     */
    private function formatearTiempoEnClub($diff)
    {
        $partes = [];
        
        // Agregar años si hay
        if ($diff->y > 0) {
            $partes[] = $diff->y . ($diff->y == 1 ? ' año' : ' años');
        }
        
        // Agregar meses si hay
        if ($diff->m > 0) {
            $partes[] = $diff->m . ($diff->m == 1 ? ' mes' : ' meses');
        }
        
        // ✅ CORRECCION: Agregar días SIEMPRE que haya días (no solo si partes está vacío)
        if ($diff->d > 0) {
            $partes[] = $diff->d . ($diff->d == 1 ? ' dia' : ' dias');
        }

        // Si no hay nada, mostrar "Hoy"
        return empty($partes) ? 'Hoy' : implode(', ', $partes);
    }

    /**
     * Verificar si la mensualidad esta vencida
     */
    public function getMensualidadVencidaAttribute()
    {
        if (!$this->fechaVencimientoMensualidad) {
            return false;
        }

        return Carbon::parse($this->fechaVencimientoMensualidad)->isPast();
    }

    /**
     * Dias restantes para el vencimiento (o dias vencidos)
     */
    public function getDiasParaVencimientoAttribute()
    {
        if (!$this->fechaVencimientoMensualidad) {
            return null;
        }

        $fechaVencimiento = Carbon::parse($this->fechaVencimientoMensualidad);
        $ahora = Carbon::now();

        $dias = $ahora->diffInDays($fechaVencimiento, false);
        $diasAbsoluto = (int) abs($dias);
        
        return [
            'dias' => $diasAbsoluto,
            'vencido' => $dias < 0,
            'texto' => $dias < 0 
                ? 'Vencido hace ' . $diasAbsoluto . ' dias' 
                : ($dias == 0 ? 'Vence hoy' : 'Vence en ' . $diasAbsoluto . ' dias')
        ];
    }
}