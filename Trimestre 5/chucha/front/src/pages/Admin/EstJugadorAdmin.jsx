import React, { useState, useEffect } from 'react';

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
      console.log('=== CATEGORÍAS DISPONIBLES ===', data);

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
      console.log('Cargando jugadores para categoría ID:', idCategorias);
      
      const response = await fetch(`http://localhost:8000/api/categorias/${idCategorias}/jugadores`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Accept': 'application/json'
        }
      });
      
      const data = await response.json();
      console.log('Jugadores recibidos:', data);
      
      if (data.data && Array.isArray(data.data)) {
        console.log('Jugadores encontrados:', data.data);
        setJugadores(data.data);
        await cargarInformacionPersonas(data.data);
      } else {
        console.warn('No hay jugadores en esta categoría');
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
          // Obtener el ID del jugador - puede ser idJugadores o id
          const jugadorId = jugador.idJugadores || jugador.id;
          
          if (!jugadorId) {
            console.warn('Jugador sin ID:', jugador);
            continue;
          }

          // Obtener el identificador de la persona
          const personaId = jugador.NumeroDeDocumento || jugador.idPersonas;
          
          if (!personaId) {
            // Si no hay identificador de persona, usar datos básicos
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
            console.log('Datos de persona:', personaData);
            
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
          console.error(`Error al cargar persona para jugador:`, error);
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

      console.log('Jugadores con información de personas:', jugadoresConInfo);
      setJugadoresConPersonas(jugadoresConInfo);
      
    } catch (error) {
      console.error('Error general al cargar información de personas:', error);
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

  // ✅ CORREGIDO: Calcular totales desde los rendimientos del jugador
  const cargarEstadisticasJugador = async (idJugador) => {
    try {
      const token = localStorage.getItem('token');
      console.log(`Cargando rendimientos para jugador ID: ${idJugador}`);
      
      // PLAN A: Intentar con el endpoint de totales
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
          console.log(`Totales recibidos para jugador ${idJugador}:`, dataTotales);
          
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
      
      // PLAN B: Obtener todos los rendimientos y calcular totales manualmente
      console.log(`Calculando totales manualmente para jugador ${idJugador}`);
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
      console.log(`Todos los rendimientos:`, data);
      
      // Filtrar rendimientos del jugador
      const rendimientos = (data.data || data).filter(r => r.idJugadores == idJugador);
      console.log(`Rendimientos del jugador ${idJugador}:`, rendimientos);
      
      if (rendimientos.length === 0) {
        return {
          jugador_id: idJugador,
          estadisticas: null,
          sinDatos: true
        };
      }
      
      // Calcular totales
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
      
      console.log(`Totales calculados para jugador ${idJugador}:`, totales);
      
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

  // ✅ Cargar estadísticas de ambos jugadores
  const cargarEstadisticasComparadas = async (id1, id2) => {
    try {
      setError(null);
      console.log('Comparando jugadores IDs:', id1, id2);
      
      // Cargar ambas estadísticas en paralelo
      const [stats1, stats2] = await Promise.all([
        cargarEstadisticasJugador(id1),
        cargarEstadisticasJugador(id2)
      ]);
      
      console.log('Estadísticas cargadas:', { stats1, stats2 });
      
      // Verificar si alguno no tiene datos
      if (stats1.sinDatos && stats2.sinDatos) {
        setError('Ninguno de los jugadores tiene estadísticas registradas. Debe agregar rendimientos en partidos primero.');
      } else if (stats1.sinDatos) {
        setError(`El jugador ${obtenerNombreJugador(id1)} no tiene estadísticas registradas.`);
      } else if (stats2.sinDatos) {
        setError(`El jugador ${obtenerNombreJugador(id2)} no tiene estadísticas registradas.`);
      }
      
      // Establecer las estadísticas (con valores en 0 si no hay datos)
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
      
      // Establecer estadísticas vacías
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
    console.log('Categoría seleccionada ID:', categoriaId);
    
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
    console.log('Jugador 1 seleccionado ID:', id);
    setJugador1Id(id);
    setEstadisticas1(null);
    setEstadisticas2(null);
    setError(null);
  };

  const handleJugador2Change = (e) => {
    const id = e.target.value;
    console.log('Jugador 2 seleccionado ID:', id);
    setJugador2Id(id);
    setEstadisticas1(null);
    setEstadisticas2(null);
    setError(null);
  };

  // Cargar comparación cuando ambos jugadores estén seleccionados
  useEffect(() => {
    if (jugador1Id && jugador2Id) {
      console.log('Ambos jugadores seleccionados, cargando comparación...');
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
    <div className="min-vh-100 bg-light">
      <div className="container py-5">
        <div className="text-center mb-5">
          <h1 className="mb-3">Comparación de <span style={{color: '#e63946'}}>Jugadores</span></h1>
          <p className="text-muted">
            Compare estadísticas entre jugadores para identificar fortalezas, áreas de mejora y crear estrategias más efectivas.
          </p>
        </div>

        {/* Mensaje de error */}
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
                <label className="form-label fw-bold">
                  📋 Seleccione una Categoría
                </label>
                <select
                  className="form-select form-select-lg"
                  value={categoriaSeleccionada}
                  onChange={handleCategoriaChange}
                >
                  <option value="">Seleccione una categoría</option>
                  {categorias && categorias.length > 0 ? (
                    categorias.map(categoria => (
                      <option key={`cat-${categoria.idCategorias}`} value={categoria.idCategorias}>
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
          <div className="card shadow">
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
        )}

        {!loading && (!estadisticas1 || !estadisticas2) && (jugador1Id || jugador2Id) && (
          <div className="alert alert-info text-center" role="alert">
            <i className="bi bi-info-circle me-2"></i>
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
    </div>
  );
};

export default ComparacionJugadores;