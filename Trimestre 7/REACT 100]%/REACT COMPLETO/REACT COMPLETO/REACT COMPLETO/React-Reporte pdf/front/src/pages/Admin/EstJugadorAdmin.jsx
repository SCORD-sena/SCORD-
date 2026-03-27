import React, { useState, useEffect } from 'react';
import NavbarAdmin from '../../componentes/NavbarAdmin';

const ComparacionJugadores = () => {
  const [categorias, setCategorias] = useState([]);
  const [categoriaSeleccionada, setCategoriaSeleccionada] = useState('');
  const [jugadores, setJugadores] = useState([]);
  const [jugadoresConPersonas, setJugadoresConPersonas] = useState([]);
  const [jugador1Id, setJugador1Id] = useState('');
  const [jugador2Id, setJugador2Id] = useState('');
  const [estadisticas1, setEstadisticas1] = useState(null);
  const [estadisticas2, setEstadisticas2] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    cargarCategorias();
  }, []);

  const cargarCategorias = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch('http://localhost:8000/api/categorias', {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Accept': 'application/json'
        }
      });
      const data = await response.json();

      if (Array.isArray(data.data)) {
        setCategorias(data.data);
      } else if (Array.isArray(data)) {
        setCategorias(data);
      }
    } catch (error) {
      console.error('Error al cargar categorías:', error);
      setError('Error al cargar las categorías');
    }
  };

  const cargarJugadoresPorCategoria = async (idCategorias) => {
    try {
      const token = localStorage.getItem('token');
      
      const response = await fetch(`http://localhost:8000/api/categorias/${idCategorias}/jugadores`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Accept': 'application/json'
        }
      });
      
      const data = await response.json();
      
      if (data.data && Array.isArray(data.data)) {
        setJugadores(data.data);
        await cargarInformacionPersonas(data.data);
      } else {
        setJugadores([]);
        setJugadoresConPersonas([]);
      }
    } catch (error) {
      console.error('Error al cargar jugadores:', error);
      setJugadores([]);
      setJugadoresConPersonas([]);
    }
  };

  const cargarInformacionPersonas = async (jugadoresData) => {
    try {
      const token = localStorage.getItem('token');
      const jugadoresConInfo = [];

      for (const jugador of jugadoresData) {
        try {
          const jugadorId = jugador.idJugadores || jugador.id;
          
          if (!jugadorId) {
            continue;
          }

          const personaId = jugador.NumeroDeDocumento || jugador.idPersonas;
          
          if (!personaId) {
            jugadoresConInfo.push({
              ...jugador,
              id: jugadorId,
              persona: null,
              nombreCompleto: `Jugador ${jugadorId}`
            });
            continue;
          }

          const response = await fetch(`http://localhost:8000/api/personas/${personaId}`, {
            headers: {
              'Authorization': `Bearer ${token}`,
              'Accept': 'application/json'
            }
          });

          if (response.ok) {
            const personaData = await response.json();
            const persona = personaData.data || personaData;
            const nombreCompleto = `${persona.Nombre1 || ''} ${persona.Nombre2 || ''} ${persona.Apellido1 || ''} ${persona.Apellido2 || ''}`.trim();
            
            jugadoresConInfo.push({
              ...jugador,
              id: jugadorId,
              persona: persona,
              nombreCompleto: nombreCompleto || `Jugador ${jugadorId}`
            });
          } else {
            jugadoresConInfo.push({
              ...jugador,
              id: jugadorId,
              persona: null,
              nombreCompleto: `Jugador ${jugadorId}`
            });
          }
        } catch (error) {
          const jugadorId = jugador.idJugadores || jugador.id;
          if (jugadorId) {
            jugadoresConInfo.push({
              ...jugador,
              id: jugadorId,
              persona: null,
              nombreCompleto: `Jugador ${jugadorId}`
            });
          }
        }
      }

      setJugadoresConPersonas(jugadoresConInfo);
      
    } catch (error) {
      const jugadoresBasicos = jugadoresData
        .map(jugador => ({
          ...jugador,
          id: jugador.idJugadores || jugador.id,
          persona: null,
          nombreCompleto: `Jugador ${jugador.idJugadores || jugador.id}`
        }))
        .filter(j => j.id);
      setJugadoresConPersonas(jugadoresBasicos);
    }
  };

  const cargarEstadisticasJugador = async (idJugador) => {
    try {
      const token = localStorage.getItem('token');
      
      try {
        const responseTotales = await fetch(`http://localhost:8000/api/rendimientospartidos/jugador/${idJugador}/totales`, {
          method: 'GET',
          headers: {
            'Authorization': `Bearer ${token}`,
            'Accept': 'application/json'
          }
        });
        
        if (responseTotales.ok) {
          const dataTotales = await responseTotales.json();
          const estadisticas = dataTotales.data || dataTotales;
          
          if (estadisticas && Object.keys(estadisticas).length > 0 && estadisticas.goles !== undefined) {
            return {
              jugador_id: idJugador,
              estadisticas: estadisticas,
              sinDatos: false
            };
          }
        }
      } catch (errorTotales) {
        console.log('Endpoint totales no disponible, usando método alternativo');
      }
      
      const response = await fetch(`http://localhost:8000/api/rendimientospartidos`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Accept': 'application/json'
        }
      });
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      const rendimientos = (data.data || data).filter(r => r.idJugadores == idJugador);
      
      if (rendimientos.length === 0) {
        return {
          jugador_id: idJugador,
          estadisticas: null,
          sinDatos: true
        };
      }
      
      const totales = rendimientos.reduce((acc, r) => {
        return {
          goles: (acc.goles || 0) + (parseInt(r.Goles) || 0),
          goles_cabeza: (acc.goles_cabeza || 0) + (parseInt(r.GolesDeCabeza) || 0),
          asistencias: (acc.asistencias || 0) + (parseInt(r.Asistencias) || 0),
          tiros_puerta: (acc.tiros_puerta || 0) + (parseInt(r.TirosAPuerta) || 0),
          fueras_juego: (acc.fueras_juego || 0) + (parseInt(r.FuerasDeLuego) || 0),
          partidos_jugados: (acc.partidos_jugados || 0) + 1,
          tarjetas_amarillas: (acc.tarjetas_amarillas || 0) + (parseInt(r.TarjetasAmarillas) || 0),
          tarjetas_rojas: (acc.tarjetas_rojas || 0) + (parseInt(r.TarjetasRojas) || 0)
        };
      }, {});
      
      return {
        jugador_id: idJugador,
        estadisticas: totales,
        sinDatos: false
      };
      
    } catch (error) {
      console.error(`Error al cargar estadísticas del jugador ${idJugador}:`, error);
      return {
        jugador_id: idJugador,
        estadisticas: null,
        sinDatos: true,
        error: true
      };
    }
  };

  const cargarEstadisticasComparadas = async (id1, id2) => {
    try {
      setError(null);
      
      const [stats1, stats2] = await Promise.all([
        cargarEstadisticasJugador(id1),
        cargarEstadisticasJugador(id2)
      ]);
      
      if (stats1.sinDatos && stats2.sinDatos) {
        setError('Ninguno de los jugadores tiene estadísticas registradas. Debe agregar rendimientos en partidos primero.');
      } else if (stats1.sinDatos) {
        setError(`El jugador ${obtenerNombreJugador(id1)} no tiene estadísticas registradas.`);
      } else if (stats2.sinDatos) {
        setError(`El jugador ${obtenerNombreJugador(id2)} no tiene estadísticas registradas.`);
      }
      
      setEstadisticas1({
        jugador_id: id1,
        estadisticas: stats1.estadisticas || {
          goles: 0,
          goles_cabeza: 0,
          asistencias: 0,
          tiros_puerta: 0,
          fueras_juego: 0,
          partidos_jugados: 0,
          tarjetas_amarillas: 0,
          tarjetas_rojas: 0
        }
      });
      
      setEstadisticas2({
        jugador_id: id2,
        estadisticas: stats2.estadisticas || {
          goles: 0,
          goles_cabeza: 0,
          asistencias: 0,
          tiros_puerta: 0,
          fueras_juego: 0,
          partidos_jugados: 0,
          tarjetas_amarillas: 0,
          tarjetas_rojas: 0
        }
      });
      
    } catch (error) {
      console.error('Error al cargar estadísticas comparadas:', error);
      setError('Error al cargar las estadísticas de los jugadores');
      
      setEstadisticas1({
        jugador_id: id1,
        estadisticas: {
          goles: 0,
          goles_cabeza: 0,
          asistencias: 0,
          tiros_puerta: 0,
          fueras_juego: 0,
          partidos_jugados: 0,
          tarjetas_amarillas: 0,
          tarjetas_rojas: 0
        }
      });
      
      setEstadisticas2({
        jugador_id: id2,
        estadisticas: {
          goles: 0,
          goles_cabeza: 0,
          asistencias: 0,
          tiros_puerta: 0,
          fueras_juego: 0,
          partidos_jugados: 0,
          tarjetas_amarillas: 0,
          tarjetas_rojas: 0
        }
      });
    }
  };

  const handleCategoriaChange = async (e) => {
    const categoriaId = e.target.value;
    
    setCategoriaSeleccionada(categoriaId);
    setJugador1Id('');
    setJugador2Id('');
    setEstadisticas1(null);
    setEstadisticas2(null);
    setJugadores([]);
    setJugadoresConPersonas([]);
    setError(null);

    if (categoriaId) {
      setLoading(true);
      await cargarJugadoresPorCategoria(categoriaId);
      setLoading(false);
    }
  };

  const handleJugador1Change = (e) => {
    const id = e.target.value;
    setJugador1Id(id);
    setEstadisticas1(null);
    setEstadisticas2(null);
    setError(null);
  };

  const handleJugador2Change = (e) => {
    const id = e.target.value;
    setJugador2Id(id);
    setEstadisticas1(null);
    setEstadisticas2(null);
    setError(null);
  };

  useEffect(() => {
    if (jugador1Id && jugador2Id) {
      setLoading(true);
      cargarEstadisticasComparadas(jugador1Id, jugador2Id)
        .finally(() => setLoading(false));
    }
  }, [jugador1Id, jugador2Id]);

  const obtenerNombreJugador = (jugadorId) => {
    const jugador = jugadoresConPersonas.find(j => j.id == jugadorId);
    return jugador ? jugador.nombreCompleto : `Jugador ${jugadorId}`;
  };

  const calcularDiferencia = (stat1, stat2) => {
    const val1 = stat1 || 0;
    const val2 = stat2 || 0;
    const diff = val1 - val2;
    if (diff > 0) return `+${diff}`;
    return diff;
  };

  const getColorDiferencia = (diff) => {
    if (diff > 0) return 'text-success';
    if (diff < 0) return 'text-danger';
    return 'text-secondary';
  };

  return (
    <div className="d-flex flex-column min-vh-100">
      <style>{`
        .navbar a {
          color: #000;
          text-decoration: none;
          padding: 8px 16px;
          transition: all 0.3s ease;
          font-size: 15px;
          font-weight: 400;
          border-radius: 6px;
        }
        
        .navbar a:hover {
          color: #e63946;
          background-color: #000;
        }
        
        .navbar a.btn-dark {
          background-color: #000;
          color: white;
          border-radius: 6px;
          padding: 8px 20px;
          font-weight: 400;
        }
        
        .navbar a.btn-dark:hover {
          background-color: #000;
          color: #e63946;
        }
        
        .navbar a.btn-outline {
          border: 2px solid #000;
          color: #000;
          border-radius: 6px;
          padding: 6px 18px;
          font-weight: 400;
          background-color: transparent;
        }
        
        .navbar a.btn-outline:hover {
          background-color: #000;
          color: #e63946;
          border-color: #000;
        }
      `}</style>
      
      <link 
        href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" 
        rel="stylesheet" 
      />

      <header className="header bg-white shadow-sm py-3">
        <nav className="navbar container d-flex align-items-center justify-content-between flex-wrap">
          <div className="d-flex align-items-center">
            <img 
              src="/Img/SCORD.png" 
              alt="Logo SCORD" 
              className="me-2" 
              style={{height: '60px'}} 
            />
            <h4 className="mb-0 text-danger fw-bold">SCORD</h4>
          </div>

          <label className="labe_hamburguesa d-md-none" htmlFor="menu_hamburguesa">
            <svg xmlns="http://www.w3.org/2000/svg" width={35} height={35} fill="#e63946" viewBox="0 0 16 16">
              <path fillRule="evenodd" d="M2.5 12a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5z" />
            </svg>
          </label>

          <input className="menu_hamburguesa d-none" type="checkbox" id="menu_hamburguesa" />
          <NavbarAdmin />
        </nav>
      </header>

      <main className="flex-grow-1" style={{ backgroundColor: '#ffffff', paddingTop: '60px', paddingBottom: '60px' }}>
        <div className="container">
          <div className="text-center mb-5">
            <h1 className="mb-3">Comparación de <span style={{color: '#e63946'}}>Jugadores</span></h1>
            <p className="text-muted">
              Compare estadísticas entre jugadores para identificar fortalezas, áreas de mejora y crear estrategias más efectivas.
            </p>
          </div>

          {error && (
            <div className="alert alert-danger alert-dismissible fade show" role="alert">
              <strong>⚠️ Error:</strong> {error}
              <button type="button" className="btn-close" onClick={() => setError(null)}></button>
            </div>
          )}

          <div className="card shadow-sm mb-4">
            <div className="card-body">
              <div className="row mb-4">
                <div className="col-12">
                  <label className="form-label fw-bold">📋 Seleccione una Categoría</label>
                  <select
                    className="form-select form-select-lg"
                    value={categoriaSeleccionada}
                    onChange={handleCategoriaChange}
                  >
                    <option value="">Seleccione una categoría</option>
                    {categorias && categorias.length > 0 ? (
                      categorias.map(categoria => (
                        <option key={categoria.idCategorias} value={categoria.idCategorias}>
                          {categoria.Descripcion}
                        </option>
                      ))
                    ) : (
                      <option disabled>Cargando categorías...</option>
                    )}
                  </select>
                </div>
              </div>

              {categoriaSeleccionada && (
                <div className="row">
                  <div className="col-md-6 mb-3">
                    <label className="form-label fw-bold">👤 Jugador 1</label>
                    <select
                      className="form-select form-select-lg"
                      value={jugador1Id}
                      onChange={handleJugador1Change}
                      disabled={!categoriaSeleccionada || jugadoresConPersonas.length === 0}
                    >
                      <option value="">Seleccione un jugador</option>
                      {jugadoresConPersonas.map((jugador, index) => (
                        <option key={`jug1-${jugador.id}-${index}`} value={jugador.id}>
                          {jugador.nombreCompleto}
                        </option>
                      ))}
                    </select>
                  </div>

                  <div className="col-md-6 mb-3">
                    <label className="form-label fw-bold">👤 Jugador 2</label>
                    <select
                      className="form-select form-select-lg"
                      value={jugador2Id}
                      onChange={handleJugador2Change}
                      disabled={!categoriaSeleccionada || jugadoresConPersonas.length === 0}
                    >
                      <option value="">Seleccione un jugador</option>
                      {jugadoresConPersonas.map((jugador, index) => (
                        <option key={`jug2-${jugador.id}-${index}`} value={jugador.id}>
                          {jugador.nombreCompleto}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
              )}
            </div>
          </div>

          {loading && (
            <div className="text-center my-5">
              <div className="spinner-border" style={{color: '#e63946', width: '3rem', height: '3rem'}} role="status">
                <span className="visually-hidden">Cargando...</span>
              </div>
              <p className="mt-3 text-muted">Cargando estadísticas...</p>
            </div>
          )}

          {!loading && estadisticas1 && estadisticas2 && (
            <>
              <div className="card shadow mb-4">
                <div className="card-header" style={{backgroundColor: '#e63946', color: 'white'}}>
                  <h5 className="mb-0">📊 Comparación de Estadísticas</h5>
                </div>
                <div className="card-body p-0">
                  <div className="table-responsive">
                    <table className="table table-hover mb-0">
                      <thead style={{backgroundColor: '#f8f9fa'}}>
                        <tr>
                          <th className="text-center py-3">Estadística</th>
                          <th className="text-center py-3">{obtenerNombreJugador(jugador1Id)}</th>
                          <th className="text-center py-3">{obtenerNombreJugador(jugador2Id)}</th>
                          <th className="text-center py-3">Diferencia</th>
                        </tr>
                      </thead>
                      <tbody>
                        {[
                          { key: "goles", label: "🏆 Goles" },
                          { key: "goles_cabeza", label: "⚽ Goles de Cabeza" },
                          { key: "asistencias", label: "👍 Asistencias" },
                          { key: "tiros_puerta", label: "🎯 Tiros a puerta" },
                          { key: "fueras_juego", label: "🚩 Fueras de juego" },
                          { key: "partidos_jugados", label: "📅 Partidos Jugados" },
                          { key: "tarjetas_amarillas", label: "🟨 Tarjetas Amarillas" },
                          { key: "tarjetas_rojas", label: "🟥 Tarjetas Rojas" },
                        ].map((stat, index) => {
                          const stats1 = estadisticas1.estadisticas || estadisticas1;
                          const stats2 = estadisticas2.estadisticas || estadisticas2;
                          const val1 = stats1[stat.key] || 0;
                          const val2 = stats2[stat.key] || 0;
                          
                          return (
                            <tr key={stat.key} className={index % 2 === 0 ? '' : 'bg-light'}>
                              <td className="py-3 ps-3">{stat.label}</td>
                              <td className="text-center fw-bold">{val1}</td>
                              <td className="text-center fw-bold">{val2}</td>
                              <td className={`text-center fw-bold ${getColorDiferencia(val1 - val2)}`}>
                                {calcularDiferencia(val1, val2)}
                              </td>
                            </tr>
                          );
                        })}
                      </tbody>
                    </table>
                  </div>
                  </div>
                
                {error && (
                  <div className="card-footer bg-warning bg-opacity-10">
                    <div className="alert alert-warning mb-0" role="alert">
                      <strong>⚠️ Atención:</strong> {error}
                      <hr className="my-2" />
                      <p className="mb-0 small">
                        💡 Para registrar estadísticas, vaya a <strong>"Perfil Jugador"</strong> → <strong>"Evaluar Jugadores"</strong> 
                        y agregue el rendimiento de los jugadores en los partidos.
                      </p>
                    </div>
                  </div>
                )}
              </div>

              {/* Gráficos de Barras Comparativos */}
              <div className="card shadow">
                <div className="card-header" style={{backgroundColor: '#e63946', color: 'white'}}>
                  <h5 className="mb-0">📈 Visualización Gráfica</h5>
                </div>
                <div className="card-body" style={{backgroundColor: '#f8f9fa'}}>
                  {[
                    { key: "goles", label: "Goles", icon: "🏆", color1: "#3b82f6", color2: "#ef4444" },
                    { key: "goles_cabeza", label: "Goles de Cabeza", icon: "⚽", color1: "#3b82f6", color2: "#ef4444" },
                    { key: "asistencias", label: "Asistencias", icon: "👍", color1: "#3b82f6", color2: "#ef4444" },
                    { key: "tiros_puerta", label: "Tiros a Puerta", icon: "🎯", color1: "#3b82f6", color2: "#ef4444" },
                    { key: "fueras_juego", label: "Fueras de Juego", icon: "🚩", color1: "#3b82f6", color2: "#ef4444" },
                    { key: "partidos_jugados", label: "Partidos Jugados", icon: "📅", color1: "#3b82f6", color2: "#ef4444" },
                    { key: "tarjetas_amarillas", label: "Tarjetas Amarillas", icon: "🟨", color1: "#3b82f6", color2: "#ef4444" },
                    { key: "tarjetas_rojas", label: "Tarjetas Rojas", icon: "🟥", color1: "#3b82f6", color2: "#ef4444" },
                  ].map((stat) => {
                    const stats1 = estadisticas1.estadisticas || estadisticas1;
                    const stats2 = estadisticas2.estadisticas || estadisticas2;
                    const val1 = stats1[stat.key] || 0;
                    const val2 = stats2[stat.key] || 0;
                    const total = val1 + val2;
                    const percentage1 = total > 0 ? (val1 / total) * 100 : 50;
                    const percentage2 = total > 0 ? (val2 / total) * 100 : 50;

                    return (
                      <div key={stat.key} className="mb-4 p-3" style={{backgroundColor: 'white', borderRadius: '12px', boxShadow: '0 2px 8px rgba(0,0,0,0.1)'}}>
                        <div className="d-flex align-items-center justify-content-between mb-3">
                          <div className="d-flex align-items-center">
                            <span style={{fontSize: '28px', marginRight: '12px'}}>{stat.icon}</span>
                            <h6 className="mb-0 fw-bold" style={{fontSize: '16px'}}>{stat.label}</h6>
                          </div>
                          <div className="d-flex gap-3">
                            <span className="badge" style={{backgroundColor: stat.color1, color: 'white', fontSize: '13px', padding: '6px 14px'}}>
                              {val1}
                            </span>
                            <span className="badge" style={{backgroundColor: stat.color2, color: 'white', fontSize: '13px', padding: '6px 14px'}}>
                              {val2}
                            </span>
                          </div>
                        </div>
                        
                        <div className="mb-2">
                          <div className="d-flex justify-content-between mb-2">
                            <small className="fw-semibold" style={{color: stat.color1}}>
                              {obtenerNombreJugador(jugador1Id)}
                            </small>
                            <small className="fw-semibold" style={{color: stat.color2}}>
                              {obtenerNombreJugador(jugador2Id)}
                            </small>
                          </div>
                          
                          <div style={{
                            width: '100%',
                            height: '40px',
                            backgroundColor: '#e5e7eb',
                            borderRadius: '20px',
                            overflow: 'hidden',
                            display: 'flex',
                            boxShadow: 'inset 0 2px 4px rgba(0,0,0,0.1)',
                            border: '2px solid #d1d5db'
                          }}>
                            {/* Jugador 1 */}
                            <div style={{
                              width: `${percentage1}%`,
                              height: '100%',
                              backgroundColor: stat.color1,
                              transition: 'width 1s ease',
                              display: 'flex',
                              alignItems: 'center',
                              justifyContent: 'center',
                              color: 'white',
                              fontWeight: 'bold',
                              fontSize: '14px',
                              position: 'relative'
                            }}>
                              {percentage1 > 15 && `${Math.round(percentage1)}%`}
                            </div>
                            
                            {/* Jugador 2 */}
                            <div style={{
                              width: `${percentage2}%`,
                              height: '100%',
                              backgroundColor: stat.color2,
                              transition: 'width 1s ease',
                              display: 'flex',
                              alignItems: 'center',
                              justifyContent: 'center',
                              color: 'white',
                              fontWeight: 'bold',
                              fontSize: '14px'
                            }}>
                              {percentage2 > 15 && `${Math.round(percentage2)}%`}
                            </div>
                          </div>
                        </div>

                        {/* Indicador de diferencia */}
                        <div className="text-center mt-2">
                          {val1 !== val2 && (
                            <small className={`fw-bold ${val1 > val2 ? 'text-primary' : 'text-danger'}`}>
                              {val1 > val2 
                                ? `${obtenerNombreJugador(jugador1Id).split(' ')[0]} lidera por ${val1 - val2}` 
                                : `${obtenerNombreJugador(jugador2Id).split(' ')[0]} lidera por ${val2 - val1}`
                              }
                            </small>
                          )}
                          {val1 === val2 && total > 0 && (
                            <small className="text-secondary fw-bold">Empate perfecto</small>
                          )}
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            </>
          )}

          {!loading && (!estadisticas1 || !estadisticas2) && (jugador1Id || jugador2Id) && (
            <div className="alert alert-info text-center" role="alert">
              ℹ️ Seleccione ambos jugadores para ver la comparación
            </div>
          )}

          {!loading && !categoriaSeleccionada && (
            <div className="alert alert-secondary text-center" role="alert">
              ⬆️ Seleccione una categoría para comenzar
            </div>
          )}

          {!loading && categoriaSeleccionada && jugadoresConPersonas.length === 0 && (
            <div className="alert alert-warning text-center" role="alert">
              ⚠️ No hay jugadores disponibles en esta categoría
            </div>
          )}
        </div>
      </main>

      <footer className="bg-dark text-white py-4 mt-auto">
        <div className="container">
          <div className="row text-center text-md-start justify-content-center">
            <div className="col-md-4 mb-3">
              <h3 className="text-danger">SCORD</h3>
              <p>Sistema de control y organización deportiva</p>
            </div>
            <div className="col-md-4 mb-3">
              <h3 className="text-danger">Escuela Quilmes</h3>
              <p>Formando talentos para el futuro</p>
            </div>
          </div>
          <hr className="border-light" />
          <p className="text-center mb-0 small">
            © 2025 SCORD | Escuela de Fútbol Quilmes | Todos los derechos reservados
          </p>
        </div>
      </footer>
    </div>
  );
};

export default ComparacionJugadores;