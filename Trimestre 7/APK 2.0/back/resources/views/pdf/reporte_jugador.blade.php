<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reporte de Rendimiento - SCORD</title>
    <style>
        @page {
            margin: 0;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Helvetica Neue', Arial, sans-serif;
            font-size: 9.5pt;
            line-height: 1.4;
            color: #1a1a1a;
            background: #f2f2f2;
        }

        /* ── PAGE WRAPPER ── */
        .page {
            background: #ffffff;
            margin: 0 auto;
            width: 100%;
        }

        /* ══════════════════════════════════════
           HEADER
        ══════════════════════════════════════ */
        .header {
            background: #111111;
            padding: 0;
            display: table;
            width: 100%;
        }

        .header-left {
            display: table-cell;
            width: 60%;
            padding: 28px 32px;
            vertical-align: middle;
        }

        .header-right {
            display: table-cell;
            width: 40%;
            background: #CC0000;
            padding: 28px 32px;
            vertical-align: middle;
            text-align: right;
        }

        .logo-badge {
            display: inline-block;
            width: 48px;
            height: 48px;
            background: #CC0000;
            border-radius: 4px;
            text-align: center;
            line-height: 48px;
            font-size: 22pt;
            font-weight: 900;
            color: #fff;
            margin-bottom: 8px;
            letter-spacing: -1px;
        }

        .header-title {
            font-size: 15pt;
            font-weight: 900;
            color: #ffffff;
            text-transform: uppercase;
            letter-spacing: 3px;
            line-height: 1.1;
        }

        .header-subtitle {
            font-size: 8pt;
            color: #999999;
            text-transform: uppercase;
            letter-spacing: 2px;
            margin-top: 4px;
        }

        .header-meta {
            font-size: 8pt;
            color: rgba(255,255,255,0.75);
            text-transform: uppercase;
            letter-spacing: 1px;
            line-height: 1.8;
        }

        .header-meta strong {
            color: #ffffff;
            font-size: 10pt;
            display: block;
            letter-spacing: 2px;
            margin-bottom: 2px;
        }

        /* ══════════════════════════════════════
           PLAYER HERO STRIP
        ══════════════════════════════════════ */
        .player-hero {
            background: #1a1a1a;
            padding: 20px 32px;
            display: table;
            width: 100%;
            border-bottom: 3px solid #CC0000;
        }

        .player-hero-name {
            display: table-cell;
            vertical-align: middle;
        }

        .player-name {
            font-size: 22pt;
            font-weight: 900;
            color: #ffffff;
            text-transform: uppercase;
            letter-spacing: 2px;
            line-height: 1;
        }

        .player-pos-cat {
            font-size: 9pt;
            color: #CC0000;
            text-transform: uppercase;
            letter-spacing: 3px;
            margin-top: 5px;
            font-weight: 700;
        }

        .player-hero-stats {
            display: table-cell;
            vertical-align: middle;
            text-align: right;
        }

        .hero-stat-group {
            display: inline-block;
            text-align: center;
            margin-left: 24px;
        }

        .hero-stat-num {
            font-size: 22pt;
            font-weight: 900;
            color: #CC0000;
            line-height: 1;
        }

        .hero-stat-label {
            font-size: 7pt;
            color: #888888;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-top: 2px;
        }

        /* ══════════════════════════════════════
           REPORTE TYPE BANNER
        ══════════════════════════════════════ */
        .report-type-bar {
            background: #f7f7f7;
            border-left: 5px solid #CC0000;
            padding: 10px 32px;
            display: table;
            width: 100%;
        }

        .report-type-bar-left {
            display: table-cell;
            vertical-align: middle;
        }

        .report-type-label {
            font-size: 7pt;
            color: #888;
            text-transform: uppercase;
            letter-spacing: 2px;
        }

        .report-type-value {
            font-size: 11pt;
            font-weight: 900;
            color: #111;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .report-type-bar-right {
            display: table-cell;
            vertical-align: middle;
            text-align: right;
        }

        .partidos-badge {
            background: #CC0000;
            color: #fff;
            font-size: 8pt;
            font-weight: 700;
            padding: 4px 12px;
            border-radius: 2px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        /* ══════════════════════════════════════
           BODY CONTENT
        ══════════════════════════════════════ */
        .content {
            padding: 24px 32px;
        }

        /* ── SECTION HEADER ── */
        .section {
            margin-bottom: 28px;
        }

        .section-header {
            display: table;
            width: 100%;
            margin-bottom: 12px;
            border-bottom: 2px solid #111111;
            padding-bottom: 6px;
        }

        .section-header-left {
            display: table-cell;
            vertical-align: bottom;
        }

        .section-number {
            font-size: 7pt;
            font-weight: 900;
            color: #CC0000;
            text-transform: uppercase;
            letter-spacing: 3px;
        }

        .section-title {
            font-size: 11pt;
            font-weight: 900;
            color: #111111;
            text-transform: uppercase;
            letter-spacing: 2px;
        }

        .section-header-right {
            display: table-cell;
            vertical-align: bottom;
            text-align: right;
        }

        .section-tag {
            font-size: 7pt;
            color: #888;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        /* ── DATA TABLE (ficha) ── */
        .data-table {
            width: 100%;
            border-collapse: collapse;
        }

        .data-table tr {
            border-bottom: 1px solid #eeeeee;
        }

        .data-table tr:last-child {
            border-bottom: none;
        }

        .data-table td {
            padding: 8px 10px;
            vertical-align: middle;
        }

        .data-table .label {
            width: 38%;
            font-size: 8pt;
            font-weight: 700;
            color: #888888;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .data-table .value {
            font-size: 9.5pt;
            color: #1a1a1a;
            font-weight: 500;
        }

        .data-table .value .highlight {
            color: #CC0000;
            font-weight: 900;
            font-size: 11pt;
        }

        /* two-column layout for data tables */
        .data-cols {
            display: table;
            width: 100%;
        }

        .data-col-left {
            display: table-cell;
            width: 50%;
            padding-right: 16px;
            vertical-align: top;
        }

        .data-col-right {
            display: table-cell;
            width: 50%;
            padding-left: 16px;
            border-left: 1px solid #eeeeee;
            vertical-align: top;
        }

        /* ── KPI CARDS ── */
        .kpi-grid {
            display: table;
            width: 100%;
            border-collapse: separate;
            border-spacing: 6px;
        }

        .kpi-row {
            display: table-row;
        }

        .kpi-card {
            display: table-cell;
            background: #f7f7f7;
            border-top: 3px solid #dddddd;
            padding: 10px 12px;
            text-align: center;
            width: 11.1%;
        }

        .kpi-card.highlight-card {
            background: #1a1a1a;
            border-top-color: #CC0000;
        }

        .kpi-num {
            font-size: 18pt;
            font-weight: 900;
            color: #111111;
            line-height: 1;
        }

        .kpi-card.highlight-card .kpi-num {
            color: #CC0000;
        }

        .kpi-label {
            font-size: 6.5pt;
            color: #888888;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-top: 4px;
            line-height: 1.2;
        }

        .kpi-card.highlight-card .kpi-label {
            color: #aaaaaa;
        }

        .kpi-avg {
            font-size: 7pt;
            color: #CC0000;
            font-weight: 700;
            margin-top: 3px;
        }

        /* ── MATCHES TABLE ── */
        .matches-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 8.5pt;
        }

        .matches-table thead tr {
            background: #111111;
        }

        .matches-table thead th {
            padding: 8px 8px;
            color: #ffffff;
            font-size: 7pt;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-weight: 700;
            text-align: center;
            border-right: 1px solid #333333;
        }

        .matches-table thead th:first-child {
            text-align: left;
        }

        .matches-table thead th:last-child {
            border-right: none;
        }

        .matches-table tbody tr {
            border-bottom: 1px solid #eeeeee;
        }

        .matches-table tbody tr:nth-child(even) {
            background: #fafafa;
        }

        .matches-table tbody td {
            padding: 7px 8px;
            text-align: center;
            color: #333333;
        }

        .matches-table tbody td:first-child,
        .matches-table tbody td:nth-child(2) {
            text-align: left;
        }

        .matches-table .rival-name {
            font-weight: 700;
            color: #111111;
        }

        .matches-table .red-accent {
            color: #CC0000;
            font-weight: 900;
        }

        .matches-table .card-yellow {
            color: #e6a817;
            font-weight: 700;
        }

        .matches-table .card-red {
            color: #CC0000;
            font-weight: 700;
        }

        /* ── AI ANALYSIS ── */
        .ai-section {
            background: #111111;
            border-radius: 4px;
            overflow: hidden;
            margin-top: 4px;
        }

        .ai-header {
            background: #CC0000;
            padding: 10px 18px;
            display: table;
            width: 100%;
        }

        .ai-header-left {
            display: table-cell;
            vertical-align: middle;
        }

        .ai-title {
            font-size: 8pt;
            font-weight: 900;
            color: #ffffff;
            text-transform: uppercase;
            letter-spacing: 2px;
        }

        .ai-header-right {
            display: table-cell;
            vertical-align: middle;
            text-align: right;
        }

        .ai-badge {
            font-size: 7pt;
            color: rgba(255,255,255,0.7);
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .ai-body {
            padding: 18px 20px;
        }

        .ai-text {
            font-size: 9.5pt;
            color: #cccccc;
            line-height: 1.75;
            white-space: pre-wrap;
        }

        .ai-disclaimer {
            margin-top: 12px;
            padding-top: 10px;
            border-top: 1px solid #333333;
            font-size: 7.5pt;
            color: #666666;
            font-style: italic;
        }

        /* ── FOOTER ── */
        .footer {
            background: #111111;
            padding: 12px 32px;
            display: table;
            width: 100%;
            margin-top: 24px;
        }

        .footer-left {
            display: table-cell;
            vertical-align: middle;
        }

        .footer-brand {
            font-size: 8pt;
            font-weight: 900;
            color: #CC0000;
            text-transform: uppercase;
            letter-spacing: 2px;
        }

        .footer-tagline {
            font-size: 7pt;
            color: #555555;
            letter-spacing: 1px;
            margin-top: 2px;
        }

        .footer-right {
            display: table-cell;
            vertical-align: middle;
            text-align: right;
            font-size: 7.5pt;
            color: #555555;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        /* ── DIVIDER ── */
        .divider {
            height: 1px;
            background: #eeeeee;
            margin: 20px 0;
        }

        .note {
            font-size: 8pt;
            color: #aaaaaa;
            font-style: italic;
            margin-top: 8px;
        }

        .sin-datos {
            text-align: center;
            padding: 24px;
            background: #f7f7f7;
            border: 1px dashed #dddddd;
            color: #888888;
            font-size: 9pt;
            border-radius: 4px;
        }

        .page-break {
            page-break-before: always;
        }
    </style>
</head>
<body>
<div class="page">

    {{-- ══ HEADER ══ --}}
    <div class="header">
        <div class="header-left">
            <div class="logo-badge">S</div>
            <div class="header-title">SCORD</div>
            <div class="header-subtitle">Sistema de Información de Rendimiento Deportivo</div>
        </div>
        <div class="header-right">
            <div class="header-meta">
                <strong>Reporte de Jugador</strong>
                Categoría: {{ $jugador->categoria->Descripcion ?? '—' }}<br>
                Generado: {{ $fecha_generacion }}
            </div>
        </div>
    </div>

    {{-- ══ PLAYER HERO STRIP ══ --}}
    <div class="player-hero">
        <div class="player-hero-name">
            <div class="player-name">
                {{ $jugador->persona->Nombre1 ?? '' }} {{ $jugador->persona->Nombre2 ?? '' }}
                {{ $jugador->persona->Apellido1 ?? '' }} {{ $jugador->persona->Apellido2 ?? '' }}
            </div>
            <div class="player-pos-cat">
                {{ $jugador->Posicion ?? '—' }} &nbsp;·&nbsp; #{{ $jugador->Dorsal }} &nbsp;·&nbsp; {{ $jugador->categoria->Descripcion ?? '—' }}
            </div>
        </div>
        <div class="player-hero-stats">
            <div class="hero-stat-group">
                <div class="hero-stat-num">{{ $totales['Goles'] }}</div>
                <div class="hero-stat-label">Goles</div>
            </div>
            <div class="hero-stat-group">
                <div class="hero-stat-num">{{ $totales['Asistencias'] }}</div>
                <div class="hero-stat-label">Asist.</div>
            </div>
            <div class="hero-stat-group">
                <div class="hero-stat-num">{{ $totalPartidos }}</div>
                <div class="hero-stat-label">Partidos</div>
            </div>
            <div class="hero-stat-group">
                <div class="hero-stat-num">{{ $totales['MinutosJugados'] }}'</div>
                <div class="hero-stat-label">Minutos</div>
            </div>
        </div>
    </div>

    {{-- ══ REPORT TYPE BAR ══ --}}
    <div class="report-type-bar">
        <div class="report-type-bar-left">
            <div class="report-type-label">Tipo de Reporte</div>
            <div class="report-type-value">
                {{ $tipo_reporte }}
                @if($competencia)
                    &nbsp;— {{ $competencia->Nombre }}
                @endif
            </div>
        </div>
        <div class="report-type-bar-right">
            <span class="partidos-badge">{{ $totalPartidos }} {{ $totalPartidos === 1 ? 'partido' : 'partidos' }} registrados</span>
        </div>
    </div>

    {{-- ══ CONTENT ══ --}}
    <div class="content">

        {{-- ── 01 INFORMACIÓN DEL ATLETA ── --}}
        <div class="section">
            <div class="section-header">
                <div class="section-header-left">
                    <div class="section-number">01</div>
                    <div class="section-title">Información del Atleta</div>
                </div>
                <div class="section-header-right">
                    <span class="section-tag">Ficha Personal</span>
                </div>
            </div>

            <div class="data-cols">
                <div class="data-col-left">
                    <table class="data-table">
                        <tr>
                            <td class="label">Nombre</td>
                            <td class="value">
                                {{ $jugador->persona->Nombre1 ?? '' }} {{ $jugador->persona->Nombre2 ?? '' }}
                                {{ $jugador->persona->Apellido1 ?? '' }} {{ $jugador->persona->Apellido2 ?? '' }}
                            </td>
                        </tr>
                        <tr>
                            <td class="label">Documento</td>
                            <td class="value">{{ $jugador->persona->tiposDeDocumentos->Tipo ?? 'N/A' }}: {{ $jugador->persona->NumeroDeDocumento ?? '—' }}</td>
                        </tr>
                        <tr>
                            <td class="label">Nacimiento</td>
                            <td class="value">
                                {{ \Carbon\Carbon::parse($jugador->persona->FechaDeNacimiento)->format('d/m/Y') }}
                                <span class="highlight">({{ \Carbon\Carbon::parse($jugador->persona->FechaDeNacimiento)->age }} años)</span>
                            </td>
                        </tr>
                        <tr>
                            <td class="label">Contacto</td>
                            <td class="value">{{ $jugador->persona->Telefono ?? 'N/A' }}</td>
                        </tr>
                        @if($jugador->Upz)
                        <tr>
                            <td class="label">UPZ</td>
                            <td class="value">{{ $jugador->Upz }}</td>
                        </tr>
                        @endif
                    </table>
                </div>
                <div class="data-col-right">
                    <table class="data-table">
                        <tr>
                            <td class="label">Categoría</td>
                            <td class="value"><span class="highlight">{{ $jugador->categoria->Descripcion ?? '—' }}</span></td>
                        </tr>
                        <tr>
                            <td class="label">Dorsal</td>
                            <td class="value"><span class="highlight">#{{ $jugador->Dorsal }}</span></td>
                        </tr>
                        <tr>
                            <td class="label">Posición</td>
                            <td class="value">{{ $jugador->Posicion }}</td>
                        </tr>
                        <tr>
                            <td class="label">Estatura</td>
                            <td class="value">{{ $jugador->Estatura }} cm</td>
                        </tr>
                        <tr>
                            <td class="label">Tutor</td>
                            <td class="value">
                                {{ $jugador->NomTutor1 }} {{ $jugador->NomTutor2 ?? '' }}
                                {{ $jugador->ApeTutor1 }} {{ $jugador->ApeTutor2 ?? '' }}
                            </td>
                        </tr>
                        <tr>
                            <td class="label">Tel. Tutor</td>
                            <td class="value"><span class="highlight">{{ $jugador->TelefonoTutor }}</span></td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>

        {{-- ── 02 ESTADÍSTICAS CLAVE ── --}}
        <div class="section">
            <div class="section-header">
                <div class="section-header-left">
                    <div class="section-number">02</div>
                    <div class="section-title">Estadísticas Clave</div>
                </div>
                <div class="section-header-right">
                    <span class="section-tag">KPIs — {{ $tipo_reporte }}</span>
                </div>
            </div>

            <table class="kpi-grid">
                <tr class="kpi-row">
                    <td class="kpi-card highlight-card">
                        <div class="kpi-num">{{ $totales['Goles'] }}</div>
                        <div class="kpi-label">Goles</div>
                        <div class="kpi-avg">Ø {{ $promedios['GolesPromedio'] }}/P</div>
                    </td>
                    <td class="kpi-card">
                        <div class="kpi-num">{{ $totales['GolesDeCabeza'] }}</div>
                        <div class="kpi-label">Goles<br>Cabeza</div>
                    </td>
                    <td class="kpi-card highlight-card">
                        <div class="kpi-num">{{ $totales['Asistencias'] }}</div>
                        <div class="kpi-label">Asistencias</div>
                        <div class="kpi-avg">Ø {{ $promedios['AsistenciasPromedio'] }}/P</div>
                    </td>
                    <td class="kpi-card">
                        <div class="kpi-num">{{ $totales['TirosApuerta'] }}</div>
                        <div class="kpi-label">Tiros a<br>Puerta</div>
                        <div class="kpi-avg">Ø {{ $promedios['TirosPromedio'] }}/P</div>
                    </td>
                    <td class="kpi-card highlight-card">
                        <div class="kpi-num">{{ $totales['MinutosJugados'] }}'</div>
                        <div class="kpi-label">Minutos<br>Jugados</div>
                        <div class="kpi-avg">Ø {{ $promedios['MinutosPromedio'] }}'/P</div>
                    </td>
                    <td class="kpi-card">
                        <div class="kpi-num" style="color:#e6a817">{{ $totales['TarjetasAmarillas'] }}</div>
                        <div class="kpi-label">T. Amarillas</div>
                    </td>
                    <td class="kpi-card">
                        <div class="kpi-num" style="color:#CC0000">{{ $totales['TarjetasRojas'] }}</div>
                        <div class="kpi-label">T. Rojas</div>
                    </td>
                    <td class="kpi-card">
                        <div class="kpi-num">{{ $totales['FuerasDeLugar'] }}</div>
                        <div class="kpi-label">Fuera de<br>Lugar</div>
                    </td>
                    <td class="kpi-card highlight-card">
                        <div class="kpi-num">{{ $totales['ArcoEnCero'] }}</div>
                        <div class="kpi-label">Arco en<br>Cero</div>
                    </td>
                </tr>
            </table>

            <p class="note">* Promedios (Ø) calculados sobre {{ $totalPartidos }} {{ $totalPartidos === 1 ? 'partido' : 'partidos' }} disputados.</p>
        </div>

        {{-- ── 03 PARTIDOS RECIENTES ── --}}
        <div class="section">
            <div class="section-header">
                <div class="section-header-left">
                    <div class="section-number">03</div>
                    <div class="section-title">Partidos Recientes</div>
                </div>
                <div class="section-header-right">
                    <span class="section-tag">Últimos {{ $ultimosPartidos->count() }} partidos</span>
                </div>
            </div>

            @if($ultimosPartidos->isEmpty())
                <div class="sin-datos">Sin registros de rendimiento disponibles.</div>
            @else
                <table class="matches-table">
                    <thead>
                        <tr>
                            <th>Fecha</th>
                            <th>Rival</th>
                            <th>Goles</th>
                            <th>G. Cabeza</th>
                            <th>Asist.</th>
                            <th>Min.</th>
                            <th>Tiros</th>
                            <th>T.A.</th>
                            <th>T.R.</th>
                            <th>F. Lugar</th>
                            <th>A. Cero</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($ultimosPartidos as $r)
                        <tr>
                            <td>{{ \Carbon\Carbon::parse($r->partido->cronogramas->FechaDeEventos ?? '')->format('d/m/Y') }}</td>
                            <td class="rival-name">{{ $r->partido->EquipoRival ?? '—' }}</td>
                            <td class="{{ $r->Goles > 0 ? 'red-accent' : '' }}">{{ $r->Goles }}</td>
                            <td>{{ $r->GolesDeCabeza }}</td>
                            <td class="{{ $r->Asistencias > 0 ? 'red-accent' : '' }}">{{ $r->Asistencias }}</td>
                            <td>{{ $r->MinutosJugados }}'</td>
                            <td>{{ $r->TirosApuerta }}</td>
                            <td class="{{ $r->TarjetasAmarillas > 0 ? 'card-yellow' : '' }}">{{ $r->TarjetasAmarillas }}</td>
                            <td class="{{ $r->TarjetasRojas > 0 ? 'card-red' : '' }}">{{ $r->TarjetasRojas }}</td>
                            <td>{{ $r->FuerasDeLugar }}</td>
                            <td class="{{ $r->ArcoEnCero > 0 ? 'red-accent' : '' }}">{{ $r->ArcoEnCero }}</td>
                        </tr>
                        @endforeach
                    </tbody>
                </table>
                <p class="note">* TA = Tarjetas Amarillas · TR = Tarjetas Rojas · Goles y Asistencias destacados en rojo.</p>
            @endif
        </div>

        {{-- ── 04 ANÁLISIS IA ── --}}
        @if(isset($analisisIA) && !empty($analisisIA))
        <div class="section">
            <div class="section-header">
                <div class="section-header-left">
                    <div class="section-number">04</div>
                    <div class="section-title">Análisis Técnico IA</div>
                </div>
                <div class="section-header-right">
                    <span class="section-tag">Generado por Inteligencia Artificial</span>
                </div>
            </div>

            <div class="ai-section">
                <div class="ai-header">
                    <div class="ai-header-left">
                        <div class="ai-title">Informe de Rendimiento — Generado por IA</div>
                    </div>
                    <div class="ai-header-right">
                        <span class="ai-badge">SCORD · Groq AI · llama-3.3</span>
                    </div>
                </div>
                <div class="ai-body">
                    <div class="ai-text">{!! nl2br(e($analisisIA)) !!}</div>
                    <div class="ai-disclaimer">
                        Análisis generado automáticamente con IA a partir de estadísticas registradas. Complementar con evaluación directa del cuerpo técnico.
                    </div>
                </div>
            </div>
        </div>
        @endif

    </div>{{-- end .content --}}

    {{-- ══ FOOTER ══ --}}
    <div class="footer">
        <div class="footer-left">
            <div class="footer-brand">SCORD</div>
            <div class="footer-tagline">Sistema de Información de Rendimiento Deportivo · Escuela de Fútbol Quilmes</div>
        </div>
        <div class="footer-right">
            Generado el {{ $fecha_generacion }}
        </div>
    </div>

</div>
</body>
</html>