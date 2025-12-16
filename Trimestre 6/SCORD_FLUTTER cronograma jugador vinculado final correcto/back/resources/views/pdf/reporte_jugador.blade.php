<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reporte de Rendimiento - SCORD</title>
    <style>
        /* --- Definición de Variables y Globales --- */
        :root {
            --color-principal: #C0392B; /* Rojo Institucional Fuerte */
            --color-secundario: #E74C3C; /* Rojo Más Brillante */
            --color-dark: #2c3e50; /* Gris Oscuro (Texto) */
            --color-light: #ecf0f1; /* Gris Claro (Fondos) */
            --color-borde: #DCDCDC;
            --color-sombra: rgba(0, 0, 0, 0.15);
            --color-tabla-texto: #333333; /* Color de texto legible para las tablas (Gris oscuro) */
        }

        @page {
            margin: 2.54cm;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Helvetica Neue', Arial, sans-serif; 
            font-size: 10.5pt;
            line-height: 1.5;
            color: var(--color-dark);
            background: #ffffff;
        }
        
        /* --- Encabezado Institucional (Modernizado) --- */
        .header-institucional {
            text-align: center;
            margin-bottom: 40px;
            padding-bottom: 15px;
            border-bottom: 5px solid var(--color-principal); 
            box-shadow: 0 4px 6px var(--color-sombra); 
        }

        .logo-institucional {
            width: 70px;
            height: 70px;
            margin: 0 auto 10px;
            background: var(--color-principal);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 30px;
            font-weight: 900;
            border: 3px solid var(--color-secundario);
        }

        .nombre-institucion {
            font-size: 16pt;
            font-weight: 700;
            text-transform: uppercase;
            margin-bottom: 3px;
            color: var(--color-dark);
            letter-spacing: 1.5px;
        }

        .sistema-nombre {
            font-size: 10pt;
            color: var(--color-principal);
            font-weight: 600;
        }

        /* --- Bloque de Reporte (Tarjeta de Resumen) --- */
        .tipo-reporte {
            background: linear-gradient(135deg, #fefefe, #fbebeb); 
            border-left: 5px solid var(--color-principal);
            padding: 15px 20px;
            margin: 30px 0;
            border-radius: 6px;
            box-shadow: 0 4px 10px var(--color-sombra);
        }

        .tipo-reporte h2 {
            color: var(--color-dark);
            font-size: 14pt;
            margin-bottom: 10px;
            text-align: left;
            border-bottom: 2px solid var(--color-borde);
            padding-bottom: 8px;
        }

        .tipo-reporte p {
            color: #555;
            font-size: 10pt;
            text-align: left;
            margin: 4px 0;
            line-height: 1.3;
            padding-left: 10px;
        }

        .tipo-reporte p strong {
            color: var(--color-dark);
        }
        
        /* --- Título Principal (Banner) --- */
        .titulo-principal {
            text-align: center;
            font-size: 18pt;
            font-weight: 900;
            text-transform: uppercase;
            margin: 35px 0 30px 0;
            color: white;
            background: var(--color-principal);
            padding: 18px 20px;
            letter-spacing: 3px;
            border-radius: 8px;
            box-shadow: 0 6px 15px var(--color-sombra);
        }

        /* --- Secciones --- */
        .seccion {
            margin-bottom: 40px;
            page-break-inside: avoid;
        }

        .seccion-titulo {
            font-size: 12pt;
            font-weight: 700;
            color: white;
            text-transform: uppercase;
            margin-bottom: 15px;
            padding: 10px 15px;
            background: var(--color-principal);
            border-left: 6px solid var(--color-secundario);
            box-shadow: 0 2px 4px var(--color-sombra);
            border-radius: 4px 4px 0 0;
        }

        /* --- Tablas de Datos del Jugador (Estilo Ficha) --- */
        .tabla-apa { 
            width: 100%;
            border-collapse: collapse;
            margin: 0;
            font-size: 10.5pt;
            border: 1px solid var(--color-borde);
            border-radius: 0 0 4px 4px;
        }

        .tabla-apa thead {
            display: none; 
        }
        
        .tabla-apa tbody tr:nth-child(even) {
            background-color: #f7f7f7;
        }

        .tabla-apa td {
            padding: 12px 15px;
            border-bottom: 1px solid var(--color-borde);
        }

        .tabla-apa tbody tr:last-child td {
            border-bottom: none;
        }

        .tabla-apa .col-label {
            width: 40%;
            font-weight: 600;
            color: var(--color-dark);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-right: 2px solid var(--color-borde);
        }

        .tabla-apa .col-valor {
            width: 60%;
            font-weight: 500;
            color: #34495e;
        }
        
        .tabla-apa .col-valor strong {
            color: var(--color-principal);
            font-size: 11pt;
        }
        
        /* --- Tablas de Estadísticas (KPIs) --- */
        .tabla-estadisticas {
            width: 100%;
            border-collapse: collapse;
            margin: 15px 0;
            font-size: 10.5pt;
            border: 1px solid var(--color-borde);
            border-radius: 4px;
        }
        
        .tabla-estadisticas caption {
            font-weight: 600;
            text-align: left;
            margin-bottom: 10px;
            font-size: 11pt;
            color: var(--color-principal);
        }

        .tabla-estadisticas th {
            background: var(--color-principal);
            color: dark; /* CORRECCIÓN CLAVE: El texto de encabezado debe ser blanco sobre fondo rojo */
            padding: 12px 10px;
            text-align: center;
            font-weight: 700;
            border: 1px solid var(--color-secundario);
            text-transform: uppercase;
        }

        .tabla-estadisticas td {
            padding: 10px;
            text-align: center;
            border: 1px solid #f0f0f0;
            color: var(--color-tabla-texto); 
        }
        
        /* Asegura que el texto de la columna de estadística sea negro */
        .tabla-estadisticas td strong {
            color: #000000 !important; 
            font-weight: 600; 
        }

        .tabla-estadisticas tbody tr:nth-child(even) {
            background: #fcfcfc;
        }
        
        .stat-total {
            font-weight: 700;
            color: var(--color-secundario); 
            font-size: 12pt;
        }
        
        .stat-total:before {
            content: "";
        }
        
        /* --- Tabla de Partidos (Detalle Compacto) --- */
        .tabla-partidos {
            width: 100%;
            border-collapse: collapse;
            margin: 15px 0;
            font-size: 9.5pt;
        }
        
        .tabla-partidos caption {
            font-weight: 600;
            text-align: left;
            margin-bottom: 10px;
            font-size: 11pt;
            color: var(--color-principal);
        }

        .tabla-partidos thead {
            background: var(--color-secundario);
            color: white; /* Aseguramos que los encabezados de la tabla de partidos también sean blancos */
        }

        .tabla-partidos th {
            padding: 8px 5px;
            text-align: center;
            font-weight: 600;
            border-right: 1px solid var(--color-principal);
            text-transform: uppercase;
        }
        
        .tabla-partidos th:last-child {
            border-right: none;
        }

        .tabla-partidos td {
            padding: 7px 5px;
            text-align: center;
            border-bottom: 1px solid #eee;
            border-right: 1px solid #f8f8f8;
            color: var(--color-tabla-texto); 
        }

        .tabla-partidos tbody tr:nth-child(even) {
            background: #fafafa;
        }

        .destacado {
            font-weight: 700;
            color: var(--color-principal); 
        }

        /* --- Notas y Pie de Página Corregido --- */
        .sin-datos {
            text-align: center;
            padding: 30px;
            background: #fef0f0; 
            border: 2px dashed var(--color-secundario);
            border-radius: 8px;
            color: var(--color-principal);
            font-style: italic;
            font-size: 12pt;
        }

        .nota-pie {
            font-size: 9pt;
            font-style: italic;
            color: #7f8c8d;
            margin-top: 20px;
            padding-top: 10px;
            border-top: 1px solid var(--color-borde);
        }

        /* CORRECCIÓN: Pie de página NO fijo */
        .footer-generacion {
            text-align: right;
            margin-top: 30px;
            padding-top: 10px;
            font-size: 9pt;
            color: #7f8c8d;
            border-top: 1px solid var(--color-borde);
        }
    </style>
</head>
<body>

    <div class="header-institucional">
        <div class="logo-institucional">S</div>
        <div class="nombre-institucion">
            Sistema de Información de Rendimiento Deportivo
        </div>
        <div class="sistema-nombre">SCORD - Reporte de Jugador</div>
    </div>

    <div class="tipo-reporte">
        <h2>Reporte {{ $tipo_reporte }}</h2>
        @if($competencia)
            <p><strong>Competencia:</strong> {{ $competencia->Nombre ?? 'N/A' }}</p>
            @if($competencia->Descripcion)
                <p><strong>Descripción:</strong> {{ $competencia->Descripcion }}</p>
            @endif
        @else
            <p>Este reporte incluye estadísticas de todas las competencias en las que ha participado el jugador.</p>
        @endif
        <p><strong>Total de Partidos Registrados:</strong> <span style="color: var(--color-principal); font-weight: bold;">{{ $totalPartidos }}</span></p>
    </div>

    <div class="titulo-principal">
        Ficha de Rendimiento del Jugador
    </div>

    <div class="seccion">
        <div class="seccion-titulo">Información Base del Atleta</div>
        
        <table class="tabla-apa">
            <tbody>
                <tr>
                    <td class="col-label">Nombre Completo</td>
                    <td class="col-valor">
                        {{ $jugador->persona->Nombre1 ?? '' }} 
                        {{ $jugador->persona->Nombre2 ?? '' }} 
                        {{ $jugador->persona->Apellido1 ?? '' }} 
                        {{ $jugador->persona->Apellido2 ?? '' }}
                    </td>
                </tr>
                <tr>
                    <td class="col-label">Documento de Identidad</td>
                    <td class="col-valor">
                        {{ $jugador->persona->tiposDeDocumentos->Tipo ?? 'N/A' }}: 
                        {{ $jugador->persona->NumeroDeDocumento ?? '---' }}
                    </td>
                </tr>
                <tr>
                    <td class="col-label">Fecha de Nacimiento</td>
                    <td class="col-valor">
                        {{ \Carbon\Carbon::parse($jugador->persona->FechaDeNacimiento)->format('d/m/Y') }}
                        (<strong style="color: var(--color-dark)">{{ \Carbon\Carbon::parse($jugador->persona->FechaDeNacimiento)->age }} años</strong>)
                    </td>
                </tr>
                <tr>
                    <td class="col-label">Categoría</td>
                    <td class="col-valor"><strong>{{ $jugador->categoria->Descripcion ?? 'Sin categoría' }}</strong></td>
                </tr>
                <tr>
                    <td class="col-label">Dorsal</td>
                    <td class="col-valor"><strong style="font-size: 14pt;">#{{ $jugador->Dorsal }}</strong></td>
                </tr>
                <tr>
                    <td class="col-label">Posición Principal</td>
                    <td class="col-valor">{{ $jugador->Posicion }}</td>
                </tr>
                <tr>
                    <td class="col-label">Estatura</td>
                    <td class="col-valor">{{ $jugador->Estatura }} cm</td>
                </tr>
                @if($jugador->Upz)
                <tr>
                    <td class="col-label">UPZ (Ubicación)</td>
                    <td class="col-valor">{{ $jugador->Upz }}</td>
                </tr>
                @endif
                <tr>
                    <td class="col-label">Contacto (Jugador)</td>
                    <td class="col-valor">{{ $jugador->persona->Telefono ?? 'N/A' }}</td>
                </tr>
            </tbody>
        </table>
    </div>

    <div class="seccion">
        <div class="seccion-titulo">Información del Tutor/Responsable</div>
        
        <table class="tabla-apa">
            <tbody>
                <tr>
                    <td class="col-label">Nombre Completo del Tutor</td>
                    <td class="col-valor">
                        {{ $jugador->NomTutor1 }} 
                        @if($jugador->NomTutor2)
                            {{ $jugador->NomTutor2 }}
                        @endif
                        {{ $jugador->ApeTutor1 }}
                        @if($jugador->ApeTutor2)
                            {{ $jugador->ApeTutor2 }}
                        @endif
                    </td>
                </tr>
                <tr>
                    <td class="col-label">Teléfono de Contacto</td>
                    <td class="col-valor"><strong>{{ $jugador->TelefonoTutor }}</strong></td>
                </tr>
            </tbody>
        </table>
    </div>

    <div class="seccion">
        <div class="seccion-titulo">Estadísticas Clave (KPIs)</div>
        
        <table class="tabla-estadisticas">
            <caption>Resumen de Rendimiento Deportivo: {{ $tipo_reporte }}</caption>
            <thead>
                <tr>
                    <th>Estadística</th>
                    <th>Total</th>
                    <th>Promedio por Partido</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>Goles</strong></td>
                    <td class="stat-total">{{ $totales['Goles'] }}</td>
                    <td>{{ $promedios['GolesPromedio'] }}</td>
                </tr>
                <tr>
                    <td><strong>Goles de Cabeza</strong></td>
                    <td class="stat-total">{{ $totales['GolesDeCabeza'] }}</td>
                    <td>-</td>
                </tr>
                <tr>
                    <td><strong>Asistencias</strong></td>
                    <td class="stat-total">{{ $totales['Asistencias'] }}</td>
                    <td>{{ $promedios['AsistenciasPromedio'] }}</td>
                </tr>
                <tr>
                    <td><strong>Minutos Jugados</strong></td>
                    <td class="stat-total">{{ $totales['MinutosJugados'] }}</td>
                    <td>{{ $promedios['MinutosPromedio'] }}</td>
                </tr>
                <tr>
                    <td><strong>Tiros a Puerta</strong></td>
                    <td class="stat-total">{{ $totales['TirosApuerta'] }}</td>
                    <td>{{ $promedios['TirosPromedio'] }}</td>
                </tr>
                <tr>
                    <td><strong>Tarjetas Amarillas</strong></td>
                    <td class="stat-total">{{ $totales['TarjetasAmarillas'] }}</td>
                    <td>-</td>
                </tr>
                <tr>
                    <td><strong>Tarjetas Rojas</strong></td>
                    <td class="stat-total">{{ $totales['TarjetasRojas'] }}</td>
                    <td>-</td>
                </tr>
                <tr>
                    <td><strong>Fueras de Lugar</strong></td>
                    <td class="stat-total">{{ $totales['FuerasDeLugar'] }}</td>
                    <td>-</td>
                </tr>
                <tr>
                    <td><strong>Arco en Cero</strong></td>
                    <td class="stat-total">{{ $totales['ArcoEnCero'] }}</td>
                    <td>-</td>
                </tr>
            </tbody>
        </table>

        <p class="nota-pie">
            *Promedios calculados sobre {{ $totalPartidos }} {{ $totalPartidos === 1 ? 'partido disputado' : 'partidos disputados' }}.
        </p>
    </div>

    <div class="seccion">
        <div class="seccion-titulo">Detalle de Partidos Recientes</div>
        
        @if($ultimosPartidos->isEmpty())
            <div class="sin-datos">
                No existen registros de rendimiento para este jugador{{ $competencia ? ' en esta competencia' : '' }}.
            </div>
        @else
            <table class="tabla-partidos">
                <caption>Rendimiento Individual por Partido (Últimos {{ min(5, $ultimosPartidos->count()) }})</caption>
                <thead>
                    <tr>
                        <th>Fecha</th>
                        <th>Rival</th>
                        <th>Goles</th>
                        <th>Goles<br>Cabeza</th>
                        <th>Asist.</th>
                        <th>Min.</th>
                        <th>Tiros<br>Puerta</th>
                        <th>TA</th>
                        <th>TR</th>
                        <th>Fuera<br>Lugar</th>
                        <th>Arco<br>Cero</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($ultimosPartidos as $r)
                        <tr>
                            <td>{{ \Carbon\Carbon::parse($r->partido->cronogramas->FechaDeEventos ?? '')->format('d/m/Y') }}</td>
                            <td><strong>{{ $r->partido->EquipoRival ?? '---' }}</strong></td>
                            <td class="destacado">{{ $r->Goles }}</td>
                            <td>{{ $r->GolesDeCabeza }}</td>
                            <td class="destacado">{{ $r->Asistencias }}</td>
                            <td>{{ $r->MinutosJugados }}'</td>
                            <td>{{ $r->TirosApuerta }}</td>
                            <td>{{ $r->TarjetasAmarillas }}</td>
                            <td>{{ $r->TarjetasRojas }}</td>
                            <td>{{ $r->FuerasDeLugar }}</td>
                            <td>{{ $r->ArcoEnCero }}</td>
                        </tr>
                    @endforeach
                </tbody>
            </table>

            <p class="nota-pie">
                *TA = Tarjetas Amarillas, TR = Tarjetas Rojas. Datos correspondientes a los últimos {{ $ultimosPartidos->count() }} partidos disputados{{ $competencia ? ' en esta competencia' : '' }}.
            </p>
        @endif
    </div>

    <div class="footer-generacion">
        Generado por SCORD: {{ $fecha_generacion }}
    </div>

</body>
</html>