import React, { useState, useEffect } from 'react';
import NavbarAdmin from "../../componentes/NavbarAdmin";

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

  useEffect(() => {
    cargarCategorias();
  }, []);

  // ✅ Traer categorías
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
    }
  };

  // ✅ Traer jugadores filtrados por categoría
  const cargarJugadoresPorCategoria = async (categoriaId) => {
    try {
      const token = localStorage.getItem('token');
      console.log('Cargando jugadores para categoría ID:', categoriaId);
      
      const response = await fetch(`http://localhost:8000/api/categorias/${categoriaId}/jugadores`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Accept': 'application/json'
        }
      });
      
      console.log('Response status:', response.status);
      const data = await response.json();
      console.log('Jugadores recibidos:', data);
      
      if (data.data && Array.isArray(data.data)) {
        console.log('Jugadores encontrados:', data.data);
        setJugadores(data.data);
        
        // Cargar información de personas para cada jugador
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

  // ✅ Cargar información de personas para los jugadores
  const cargarInformacionPersonas = async (jugadoresData) => {
    try {
      const token = localStorage.getItem('token');
      const jugadoresConInfo = [];

      for (const jugador of jugadoresData) {
        try {
          // Asumiendo que el jugador tiene un campo NumeroDeDocumento o idPersonas
          const response = await fetch(`http://localhost:8000/api/personas/${jugador.NumeroDeDocumento || jugador.idPersonas}`, {
            headers: {
              'Authorization': `Bearer ${token}`,
              'Accept': 'application/json'
            }
          });

          if (response.ok) {
            const personaData = await response.json();
            console.log('Datos de persona:', personaData);
            
            // Combinar datos del jugador con datos de la persona
            jugadoresConInfo.push({
              ...jugador,
              persona: personaData.data,
              nombreCompleto: `${personaData.data.Nombre1 || ''} ${personaData.data.Nombre2 || ''} ${personaData.data.Apellido1 || ''} ${personaData.data.Apellido2 || ''}`.trim()
            });
          } else {
            // Si no se puede cargar la persona, usar datos básicos del jugador
            jugadoresConInfo.push({
              ...jugador,
              persona: null,
              nombreCompleto: jugador.nombre || `Jugador ${jugador.id}`
            });
          }
        } catch (error) {
          console.error(`Error al cargar persona para jugador ${jugador.id}:`, error);
          jugadoresConInfo.push({
            ...jugador,
            persona: null,
            nombreCompleto: jugador.nombre || `Jugador ${jugador.id}`
          });
        }
      }

      console.log('Jugadores con información de personas:', jugadoresConInfo);
      setJugadoresConPersonas(jugadoresConInfo);
      
    } catch (error) {
      console.error('Error general al cargar información de personas:', error);
      // Si falla, usar los datos básicos de jugadores
      const jugadoresBasicos = jugadoresData.map(jugador => ({
        ...jugador,
        persona: null,
        nombreCompleto: jugador.nombre || `Jugador ${jugador.id}`
      }));
      setJugadoresConPersonas(jugadoresBasicos);
    }
  };

  // ✅ CORREGIDO: Usar el método compararJugadores
  const cargarEstadisticasComparadas = async (id1, id2) => {
    try {
      const token = localStorage.getItem('token');
      console.log('Comparando jugadores IDs:', id1, id2);
      
      // Asegurarnos de que los IDs sean números
      const idJugador1 = parseInt(id1);
      const idJugador2 = parseInt(id2);
      
      console.log('IDs convertidos a números:', idJugador1, idJugador2);
      
      const response = await fetch(`http://localhost:8000/api/jugadores/comparar`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          ids: [idJugador1, idJugador2]
        })
      });
      
      console.log('Response status:', response.status);
      
      if (!response.ok) {
        const errorData = await response.json();
        console.error('Error response:', errorData);
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      console.log('Estadísticas comparadas recibidas:', data);

      if (data.data && Array.isArray(data.data) && data.data.length === 2) {
        // Asignar las estadísticas a cada jugador
        setEstadisticas1(data.data[0]);
        setEstadisticas2(data.data[1]);
      } else {
        throw new Error('Formato de respuesta inesperado');
      }
    } catch (error) {
      console.error('Error al cargar estadísticas comparadas:', error);
      // Crear objetos vacíos en caso de error
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

  // ✅ Cambiar categoría
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

    if (categoriaId) {
      setLoading(true);
      await cargarJugadoresPorCategoria(categoriaId);
      setLoading(false);
    }
  };

  // ✅ CORREGIDO: Seleccionar jugador 1
  const handleJugador1Change = (e) => {
    const id = e.target.value;
    console.log('Jugador 1 seleccionado ID:', id, 'Tipo:', typeof id);
    setJugador1Id(id);
    setEstadisticas1(null);
    setEstadisticas2(null);
  };

  // ✅ CORREGIDO: Seleccionar jugador 2
  const handleJugador2Change = (e) => {
    const id = e.target.value;
    console.log('Jugador 2 seleccionado ID:', id, 'Tipo:', typeof id);
    setJugador2Id(id);
    setEstadisticas1(null);
    setEstadisticas2(null);
  };

  // ✅ Cargar comparación cuando ambos jugadores estén seleccionados
  useEffect(() => {
    if (jugador1Id && jugador2Id) {
      console.log('Ambos jugadores seleccionados, cargando comparación...');
      setLoading(true);
      cargarEstadisticasComparadas(jugador1Id, jugador2Id)
        .finally(() => setLoading(false));
    }
  }, [jugador1Id, jugador2Id]);

  // ✅ Obtener nombre del jugador por ID
  const obtenerNombreJugador = (jugadorId) => {
    const jugador = jugadoresConPersonas.find(j => j.id == jugadorId);
    return jugador ? jugador.nombreCompleto : `Jugador ${jugadorId}`;
  };

  // ✅ Utilidades
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
      {/* Links de estilos */}
      <meta charSet="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Comparación de Jugadores - SCORD</title>
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossOrigin="anonymous" />
      <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" />
      <link rel="stylesheet" href="/Css/InicioAdmin.css" />

      <header className="header bg-white shadow-sm py-3">
        <nav className="navbar container d-flex align-items-center justify-content-between flex-wrap">
          <div className="d-flex align-items-center">
            <img src="/Img/SCORD.png" alt="Logo SCORD" className="me-2" style={{ height: '50px' }} />
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

      <main className="container my-5 flex-grow-1">
        <section className="text-center mb-5">
          <h1 className="mb-3">Comparación de <span className="text-danger">Jugadores</span></h1>
          <p className="text-muted">
            Compare estadísticas entre jugadores para identificar fortalezas, áreas de mejora y crear estrategias más efectivas.
          </p>
        </section>

        <section className="mb-5">
          {/* Selección de Categoría */}
          <div className="row mb-4">
            <div className="col-md-12 mb-4">
              <label className="form-label fw-bold fs-5">
                <i className="bi bi-filter-circle text-danger me-2"></i>
                Seleccione una Categoría
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

          {/* Selección de Jugadores - ACTUALIZADO */}
          {categoriaSeleccionada && (
            <div className="row mb-4">
              <div className="col-md-6 mb-3">
                <label className="form-label fw-bold">Jugador 1</label>
                <select
                  className="form-select form-select-lg"
                  value={jugador1Id}
                  onChange={handleJugador1Change}
                  disabled={!categoriaSeleccionada || jugadoresConPersonas.length === 0}
                >
                  <option value="">Seleccione un jugador</option>
                  {jugadoresConPersonas.map(jugador => {
                    console.log('Jugador con persona:', jugador);
                    return (
                      <option key={`jug-${jugador.id}`} value={jugador.id}>
                        {jugador.nombreCompleto}
                      </option>
                    );
                  })}
                </select>
              </div>

              <div className="col-md-6 mb-3">
                <label className="form-label fw-bold">Jugador 2</label>
                <select
                  className="form-select form-select-lg"
                  value={jugador2Id}
                  onChange={handleJugador2Change}
                  disabled={!categoriaSeleccionada || jugadoresConPersonas.length === 0}
                >
                  <option value="">Seleccione un jugador</option>
                  {jugadoresConPersonas.map(jugador => (
                    <option key={`jug-${jugador.id}`} value={jugador.id}>
                      {jugador.nombreCompleto}
                    </option>
                  ))}
                </select>
              </div>
            </div>
          )}

          {/* Loader */}
          {loading && (
            <div className="text-center my-5">
              <div className="spinner-border text-danger" role="status" style={{ width: "3rem", height: "3rem" }}>
                <span className="visually-hidden">Cargando...</span>
              </div>
            </div>
          )}

          {/* Tabla Comparativa - MEJORADA */}
          {!loading && estadisticas1 && estadisticas2 && (
            <div className="bg-light rounded shadow p-4">
              <div className="table-responsive">
                <table className="table table-hover mb-0 bg-white">
                  <thead className="table-light">
                    <tr>
                      <th className="text-center py-3">Estadística</th>
                      <th className="text-center py-3">{obtenerNombreJugador(jugador1Id)}</th>
                      <th className="text-center py-3">{obtenerNombreJugador(jugador2Id)}</th>
                      <th className="text-center py-3">Diferencia</th>
                    </tr>
                  </thead>
                  <tbody>
                    {[
                      { key: "goles", label: "Goles", icon: "bi bi-trophy-fill text-danger" },
                      { key: "goles_cabeza", label: "Goles de Cabeza", icon: "bi bi-person-fill text-warning" },
                      { key: "asistencias", label: "Asistencias", icon: "bi bi-hand-thumbs-up-fill text-primary" },
                      { key: "tiros_puerta", label: "Tiros a puerta", icon: "bi bi-bullseye text-info" },
                      { key: "fueras_juego", label: "Fueras de juego", icon: "bi bi-flag-fill text-secondary" },
                      { key: "partidos_jugados", label: "Partidos Jugados", icon: "bi bi-calendar-check-fill text-success" },
                      { key: "tarjetas_amarillas", label: "Tarjetas Amarillas", icon: "bi bi-card-text text-warning" },
                      { key: "tarjetas_rojas", label: "Tarjetas Rojas", icon: "bi bi-card-text text-danger" },
                    ].map((stat, index) => {
                      const stats1 = estadisticas1.estadisticas || {};
                      const stats2 = estadisticas2.estadisticas || {};
                      const val1 = stats1[stat.key] || 0;
                      const val2 = stats2[stat.key] || 0;
                      
                      return (
                        <tr key={stat.key} className={index % 2 === 0 ? '' : 'bg-light'}>
                          <td className="py-3">
                            <i className={`${stat.icon} me-2`}></i>
                            {stat.label}
                          </td>
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
          )}

          {!loading && (!estadisticas1 || !estadisticas2) && (jugador1Id || jugador2Id) && (
            <div className="alert alert-info text-center" role="alert">
              <i className="bi bi-info-circle me-2"></i>
              Seleccione ambos jugadores para ver la comparación
            </div>
          )}

          {!loading && !categoriaSeleccionada && (
            <div className="alert alert-secondary text-center" role="alert">
              <i className="bi bi-arrow-up me-2"></i>
              Seleccione una categoría para comenzar
            </div>
          )}

          {!loading && categoriaSeleccionada && jugadoresConPersonas.length === 0 && (
            <div className="alert alert-warning text-center" role="alert">
              <i className="bi bi-exclamation-triangle me-2"></i>
              No hay jugadores disponibles en esta categoría
            </div>
          )}
        </section>
      </main>

      <footer className="bg-dark text-white py-4 mt-auto">
        <div className="container">
          <div className="row text-center text-md-start justify-content-center">
            <div className="col-md-4 mb-3">
              <h3 className="text-danger">SCORD</h3>
              <p>Sistema de control y organización deportiva</p>
            </div>
            <div className="col-md-4 mb-3">
              <h3 className="text-danger">Escuela Fénix</h3>
              <p>Formando talentos para el futuro</p>
            </div>
          </div>
          <hr className="border-light" />
          <p className="text-center mb-0 small">© 2025 SCORD | Escuela de Fútbol Fénix | Todos los derechos reservados</p>
        </div>
      </footer>
    </div>
  );
};

export default ComparacionJugadores;