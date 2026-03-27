<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reporte de Rendimiento - SCORD</title>
    <style>
        /* ============================================
           CONFIGURACIÓN GENERAL - NORMAS APA
           ============================================ */
        @page {
            margin: 2.54cm; /* Márgenes APA: 1 pulgada = 2.54cm */
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Times New Roman', Times, serif; /* Fuente APA */
            font-size: 12pt; /* Tamaño APA */
            line-height: 2; /* Doble espacio APA */
            color: #000;
            background: #fff;
        }

        /* ============================================
           ENCABEZADO INSTITUCIONAL
           ============================================ */
        .header-institucional {
            text-align: center;
            margin-bottom: 30px;
            border-bottom: 2px solid #333;
            padding-bottom: 15px;
        }

        .logo-institucional {
            width: 80px;
            height: 80px;
            margin: 0 auto 10px;
            background: #;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 36px;
            font-weight: bold;
        }

        .nombre-institucion {
            font-size: 14pt;
            font-weight: bold;
            text-transform: uppercase;
            margin-bottom: 5px;
            color: #910000ff;
        }

        .sistema-nombre {
            font-size: 11pt;
            color: #555;
            margin-bottom: 8px;
        }

        /* ============================================
           TÍTULO PRINCIPAL
           ============================================ */
        .titulo-principal {
            text-align: center;
            font-size: 16pt;
            font-weight: bold;
            text-transform: uppercase;
            margin: 30px 0 20px 0;
            color: #910000ff;
            border: 3px solid #910000ff;
            padding: 15px;
            background: #f0f8f0;
        }

        /* ============================================
           SECCIONES
           ============================================ */
        .seccion {
            margin-bottom: 25px;
            page-break-inside: avoid;
        }

        .seccion-titulo {
            font-size: 13pt;
            font-weight: bold;
            color: #910000ff;
            text-transform: uppercase;
            margin-bottom: 12px;
            padding: 8px 12px;
            background: #e8f5e8;
            border-left: 5px solid #910000ff;
        }

        /* ============================================
           TABLAS ESTILO APA
           ============================================ */
        .tabla-apa {
            width: 100%;
            border-collapse: collapse;
            margin: 15px 0;
            font-size: 11pt;
        }

        .tabla-apa caption {
            font-weight: bold;
            text-align: left;
            margin-bottom: 8px;
            font-style: italic;
        }

        .tabla-apa thead {
            border-top: 2px solid #000;
            border-bottom: 2px solid #000;
        }

        .tabla-apa th {
            padding: 10px 8px;
            text-align: left;
            font-weight: bold;
            background: #f8f8f8;
        }

        .tabla-apa td {
            padding: 8px;
            border-bottom: 1px solid #ddd;
            text-align: left;
        }

        .tabla-apa tbody tr:last-child td {
            border-bottom: 2px solid #000;
        }

        .tabla-apa tbody tr:hover {
            background: #f9f9f9;
        }

        /* Alineación de columnas */
        .tabla-apa .col-label {
            width: 40%;
            font-weight: 600;
        }

        .tabla-apa .col-valor {
            width: 60%;
        }

        .tabla-apa .col-centro {
            text-align: center;
        }

        .tabla-apa .col-derecha {
            text-align: right;
        }


        /* ============================================
           TABLA DE PARTIDOS
           ============================================ */
        .tabla-partidos {
            width: 100%;
            border-collapse: collapse;
            margin: 15px 0;
            font-size: 10pt;
        }

        .tabla-partidos thead {
            background: #910000ff;
            color: white;
        }

        .tabla-partidos th {
            padding: 12px 8px;
            text-align: center;
            font-weight: bold;
            border: 1px solid #fff;
        }

        .tabla-partidos td {
            padding: 10px 8px;
            text-align: center;
            border: 1px solid #ddd;
        }

        .tabla-partidos tbody tr:nth-child(even) {
            background: #f8f8f8;
        }

        .tabla-partidos tbody tr:hover {
            background: #e8f5e8;
        }

        .destacado {
            font-weight: bold;
            color: #2c5f2d;
        }

        /* ============================================
           FOOTER APA
           ============================================ */
        .footer-apa {
            position: fixed;
            bottom: 2.54cm;
            right: 2.54cm;
            font-size: 10pt;
            color: #666;
        }

        /* ============================================
           MENSAJE SIN DATOS
           ============================================ */
        .sin-datos {
            text-align: center;
            padding: 30px;
            background: #f8f8f8;
            border: 2px dashed #ccc;
            border-radius: 8px;
            color: #666;
            font-style: italic;
        }

        /* ============================================
           NOTA AL PIE
           ============================================ */
        .nota-pie {
            font-size: 10pt;
            font-style: italic;
            color: #666;
            margin-top: 10px;
            padding-top: 10px;
            border-top: 1px solid #ddd;
        }
    </style>
</head>
<body>

    {{-- ============================================
         ENCABEZADO INSTITUCIONAL
         ============================================ --}}
    <div class="header-institucional">
        <div class="logo-institucional">S</div>
        <div class="nombre-institucion">
            Sistema de Información de Rendimiento Deportivo
        </div>
        <div class="sistema-nombre">SCORD - Reporte de Jugador</div>
    </div>

    {{-- ============================================
         TÍTULO PRINCIPAL
         ============================================ --}}
    <div class="titulo-principal">
        Reporte de Rendimiento del Jugador
    </div>

    {{-- ============================================
         INFORMACIÓN DEL JUGADOR
         ============================================ --}}
    <div class="seccion">
        <div class="seccion-titulo">Datos del Jugador</div>
        
        <table class="tabla-apa">
            <thead>
                <tr>
                    <th class="col-label">Campo</th>
                    <th class="col-valor">Información</th>
                </tr>
            </thead>
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
                        {{ $jugador->persona->tiposDeDocumentos->Descripcion ?? '' }} 
                        {{ $jugador->persona->NumeroDeDocumento ?? '---' }}
                    </td>
                </tr>
                <tr>
                    <td class="col-label">Dorsal</td>
                    <td class="col-valor"><strong>{{ $jugador->Dorsal }}</strong></td>
                </tr>
                <tr>
                    <td class="col-label">Posición</td>
                    <td class="col-valor">{{ $jugador->Posicion }}</td>
                </tr>
                <tr>
                    <td class="col-label">UPZ</td>
                    <td class="col-valor">{{ $jugador->Upz }}</td>
                </tr>
                <tr>
                    <td class="col-label">Estatura</td>
                    <td class="col-valor">{{ $jugador->Estatura }} cm</td>
                </tr>
                <tr>
                    <td class="col-label">Categoría</td>
                    <td class="col-valor"><strong>{{ $jugador->categoria->Nombre ?? 'Sin categoría' }}</strong></td>
                </tr>
            </tbody>
        </table>
    </div>

    {{-- ============================================
         INFORMACIÓN DE TUTORES
         ============================================ --}}
    <div class="seccion">
        <div class="seccion-titulo">Información de Tutores</div>
        
        <table class="tabla-apa">
            <tbody>
                <tr>
                    <td class="col-label">Tutor 1</td>
                    <td class="col-valor">{{ $jugador->NomTutor1 }} {{ $jugador->ApeTutor1 }}</td>
                </tr>
                <tr>
                    <td class="col-label">Tutor 2</td>
                    <td class="col-valor">{{ $jugador->NomTutor2 }} {{ $jugador->ApeTutor2 }}</td>
                </tr>
                <tr>
                    <td class="col-label">Teléfono de Contacto</td>
                    <td class="col-valor"><strong>{{ $jugador->TelefonoTutor }}</strong></td>
                </tr>
            </tbody>
        </table>
    </div>

    {{-- ============================================
         ESTADÍSTICAS DETALLADAS DE ÚLTIMOS 5 PARTIDOS
         ============================================ --}}
    <div class="seccion">
        <div class="seccion-titulo">Estadísticas Detalladas - Últimos 5 Partidos</div>
        
        @if($ultimosPartidos->isEmpty())
            <div class="sin-datos">
                No existen registros de rendimiento para este jugador.
            </div>
        @else
            <table class="tabla-partidos">
                <caption>Tabla 1. Rendimiento Individual De los ultimos 5</caption>
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
                            <td>{{ $r->partido->Fecha ?? '---' }}</td>
                            <td><strong>{{ $r->partido->Rival ?? '---' }}</strong></td>
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
                <em>Nota.</em> TA = Tarjetas Amarillas, TR = Tarjetas Rojas. 
                Datos correspondientes a los últimos {{ $ultimosPartidos->count() }} partidos disputados.
            </p>
        @endif
    </div>

    {{-- ============================================
         FOOTER
         ============================================ --}}
    <div class="footer-apa">
        Generado: {{ $fecha_generacion }}
    </div>

</body>
</html>