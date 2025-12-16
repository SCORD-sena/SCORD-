<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Jugadores extends Model
{
    use HasFactory;

    protected $table = 'Jugadores';
    protected $primaryKey = 'idJugadores';
    public $timestamps = false;

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

    protected $casts = [
        'fechaIngresoClub' => 'date',
        'fechaVencimientoMensualidad' => 'date',
        'Estatura' => 'float',
    ];

    // ====== ESTOS ATRIBUTOS SE INCLUIRAN SIEMPRE EN EL JSON ======
    protected $appends = [
        'tiempo_en_club',
        'dias_para_vencimiento',
        'mensualidad_vencida',
        'estado_pago',
    ];

    // Relaciones
    public function persona()
    {
        return $this->belongsTo(Personas::class, 'idPersonas', 'idPersonas');
    }

    public function categoria()
    {
        return $this->belongsTo(Categorias::class, 'idCategorias');
    }
    
    public function rendimientosPartidos()
    {
        return $this->hasMany(RendimientosPartidos::class, 'idJugadores', 'idJugadores');
    }

    // ====== ATRIBUTOS CALCULADOS ======

    public function getTiempoEnClubAttribute()
    {
        if (!$this->fechaIngresoClub) {
            return null;
        }

        $fechaIngreso = Carbon::parse($this->fechaIngresoClub);
        $ahora = Carbon::now();
        $diff = $fechaIngreso->diff($ahora);

        $partes = [];
        if ($diff->y > 0) {
            $partes[] = $diff->y . ($diff->y == 1 ? ' año' : ' años');
        }
        if ($diff->m > 0) {
            $partes[] = $diff->m . ($diff->m == 1 ? ' mes' : ' meses');
        }
        if ($diff->d > 0) {
            $partes[] = $diff->d . ($diff->d == 1 ? ' dia' : ' dias');
        }

        return [
            'anios' => $diff->y,
            'meses' => $diff->m,
            'dias' => $diff->d,
            'total_dias' => (int) $fechaIngreso->diffInDays($ahora),
            'texto' => empty($partes) ? 'Hoy' : implode(', ', $partes)
        ];
    }

    public function getMensualidadVencidaAttribute()
    {
        if (!$this->fechaVencimientoMensualidad) {
            return false;
        }
        
        return Carbon::parse($this->fechaVencimientoMensualidad)->isPast();
    }

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

    public function getEstadoPagoAttribute()
    {
        if (!$this->fechaVencimientoMensualidad) {
            return 'sin_definir';
        }

        $fechaVencimiento = Carbon::parse($this->fechaVencimientoMensualidad);
        $ahora = Carbon::now();

        // Si la fecha ya paso
        if ($fechaVencimiento->isPast()) {
            return 'no_pagado';
        }

        // Si faltan 5 dias o menos
        if ($ahora->diffInDays($fechaVencimiento) <= 5) {
            return 'por_vencer';
        }

        // Si aun hay tiempo
        return 'al_dia';
    }

    public function registrarPago()
    {
        if (!$this->fechaVencimientoMensualidad) {
            $this->fechaVencimientoMensualidad = Carbon::now()->addMonth();
        } else {
            $this->fechaVencimientoMensualidad = Carbon::parse($this->fechaVencimientoMensualidad)->addMonth();
        }
        
        $this->save();
        return $this;
    }
}