import React, { useState, useEffect } from "react";
import api from "../../config/axiosConfig";
import NavbarJugador from "../../componentes/NavbarJugador";
import Swal from "sweetalert2";

const JugEstadisticas = () => {
  const [estadisticas, setEstadisticas] = useState(null);
  const [loading, setLoading] = useState(true);
  const [jugadorInfo, setJugadorInfo] = useState(null);

  useEffect(() => {
    cargarEstadisticas();
  }, []);

  const obtenerMiPerfil = async () => {
    try {
      const res = await api.get("/jugadores/mi-perfil");
      if (res.data.success) {
        return res.data.data;
      }
      return null;
    } catch (err) {
      console.error("Error obteniendo perfil del jugador:", err);
      
      if (err.response?.status === 404) {
        Swal.fire({
          icon: "info",
          title: "Sin perfil de jugador",
          text: "Tu usuario no está asociado a un jugador",
          confirmButtonColor: "#e63946",
        });
      }
      return null;
    }
  };

  const cargarEstadisticas = async () => {
    try {
      const userStr = localStorage.getItem("user");
      
      if (!userStr) {
        Swal.fire({
          icon: "warning",
          title: "Sesión no encontrada",
          text: "Por favor inicia sesión nuevamente",
          confirmButtonColor: "#e63946",
        });
        setLoading(false);
        return;
      }

      const jugador = await obtenerMiPerfil();
      
      if (!jugador || !jugador.idJugadores) {
        setLoading(false);
        return;
      }

      setJugadorInfo(jugador);

      const resEstadisticas = await api.get(`/rendimientospartidos/jugador/${jugador.idJugadores}/totales`);
      
      if (resEstadisticas.data.success) {
        setEstadisticas(resEstadisticas.data.data);
      } else {
        setEstadisticas(getEstadisticasVacias());
      }
    } catch (err) {
      console.error("Error cargando estadísticas:", err);
      
      if (err.response?.status === 404) {
        setEstadisticas(getEstadisticasVacias());
      } else {
        Swal.fire({
          icon: "error",
          title: "Error",
          text: "No se pudieron cargar las estadísticas",
          confirmButtonColor: "#e63946",
        });
      }
    } finally {
      setLoading(false);
    }
  };

  const getEstadisticasVacias = () => ({
    totales: {
      total_goles: 0,
      total_asistencias: 0,
      total_partidos_jugados: 0,
      total_minutos_jugados: 0,
      total_goles_cabeza: 0,
      total_tiros_apuerta: 0,
      total_fueras_de_lugar: 0,
      total_tarjetas_amarillas: 0,
      total_tarjetas_rojas: 0,
      total_arco_en_cero: 0
    },
    promedios: {
      goles_por_partido: 0
    }
  });

  return (
    <div>
      <meta charSet="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Estadísticas - SCORD</title>
      <link rel="stylesheet" href="Css/InicioEntrenador.css" />
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" />
      
      <header className="header bg-white shadow-sm py-3">
        <nav className="navbar container d-flex align-items-center justify-content-between flex-wrap">
          <div className="d-flex align-items-center">
            <img src="./Img/logo.jpg" alt="Logo SCORD" className="me-2" style={{height: '50px'}} />
            <h4 className="mb-0 text-danger fw-bold">SCORD</h4>
          </div>
          <label className="labe_hamburguesa d-md-none" htmlFor="menu_hamburguesa">
            <svg xmlns="http://www.w3.org/2000/svg" width={35} height={35} fill="#e63946" viewBox="0 0 16 16">
              <path fillRule="evenodd" d="M2.5 12a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5z" />
            </svg>
          </label>
          <input className="menu_hamburguesa d-none" type="checkbox" id="menu_hamburguesa" />
          <NavbarJugador />
        </nav>
      </header>

      {/* Contenido Principal */}
      <main className="container my-5 flex-grow-1">
        <section className="text-center mb-5">
          {loading ? (
            <div
              className="d-flex flex-column justify-content-center align-items-center"
              style={{ minHeight: "400px" }}
            >
              <div className="spinner-border text-danger mb-3" role="status" style={{ width: "3rem", height: "3rem" }}>
                <span className="visually-hidden">Cargando...</span>
              </div>
              <p className="text-muted">Cargando tus estadísticas...</p>
            </div>
          ) : (
            <>
              <div className="d-flex align-items-center justify-content-center mb-4">
                <img 
                  src="/Img/SCORD.png" 
                  alt="Logo SCORD" 
                  style={{ height: '50px', marginRight: '15px' }} 
                />
                <h1 className="mb-0 text-danger fw-bold">Mis Estadísticas</h1>
              </div>

              {jugadorInfo && jugadorInfo.persona && (
                <div className="alert alert-light border border-danger mb-4 shadow-sm">
                  <strong className="text-danger">Jugador:</strong> {jugadorInfo.persona.Nombre1} {jugadorInfo.persona.Apellido1}
                  {jugadorInfo.Dorsal && <> | <strong className="text-danger">Dorsal:</strong> {jugadorInfo.Dorsal}</>}
                  {jugadorInfo.Posicion && <> | <strong className="text-danger">Posición:</strong> {jugadorInfo.Posicion}</>}
                </div>
              )}

              {/* Estadísticas Principales */}
              <h3 className="fw-bold mb-4 text-danger">Estadísticas Principales</h3>
              <div className="row justify-content-center mb-5">
                <div className="col-lg-3 col-md-6 mb-4">
                  <div className="card stat-card main-stat-card shadow h-100 border-0">
                    <div className="card-body text-center py-4">
                      <div className="stat-icon mb-3">⚽</div>
                      <h5 className="card-title text-danger fw-bold mb-2">Goles</h5>
                      <p className="display-4 fw-bold text-dark mb-0">{estadisticas?.totales?.total_goles ?? 0}</p>
                    </div>
                  </div>
                </div>

                <div className="col-lg-3 col-md-6 mb-4">
                  <div className="card stat-card main-stat-card shadow h-100 border-0">
                    <div className="card-body text-center py-4">
                      <div className="stat-icon mb-3">🎯</div>
                      <h5 className="card-title text-danger fw-bold mb-2">Asistencias</h5>
                      <p className="display-4 fw-bold text-dark mb-0">{estadisticas?.totales?.total_asistencias ?? 0}</p>
                    </div>
                  </div>
                </div>

                <div className="col-lg-3 col-md-6 mb-4">
                  <div className="card stat-card main-stat-card shadow h-100 border-0">
                    <div className="card-body text-center py-4">
                      <div className="stat-icon mb-3">📋</div>
                      <h5 className="card-title text-danger fw-bold mb-2">Partidos</h5>
                      <p className="display-4 fw-bold text-dark mb-0">{estadisticas?.totales?.total_partidos_jugados ?? 0}</p>
                    </div>
                  </div>
                </div>

                <div className="col-lg-3 col-md-6 mb-4">
                  <div className="card stat-card main-stat-card shadow h-100 border-0">
                    <div className="card-body text-center py-4">
                      <div className="stat-icon mb-3">⏱️</div>
                      <h5 className="card-title text-danger fw-bold mb-2">Minutos</h5>
                      <p className="display-4 fw-bold text-dark mb-0">{estadisticas?.totales?.total_minutos_jugados ?? 0}</p>
                    </div>
                  </div>
                </div>
              </div>

              {/* Estadísticas Detalladas */}
              <h3 className="fw-bold mb-4 text-danger">Estadísticas Detalladas</h3>
              <div className="row justify-content-center">
                {[
                  { label: "Goles de cabeza", value: estadisticas?.totales?.total_goles_cabeza, icon: "⚽" },
                  { label: "Goles por partido", value: estadisticas?.promedios?.goles_por_partido?.toFixed(2), icon: "📊" },
                  { label: "Tiros a puerta", value: estadisticas?.totales?.total_tiros_apuerta, icon: "🎯" },
                  { label: "Fueras de juego", value: estadisticas?.totales?.total_fueras_de_lugar, icon: "🚩" },
                  { label: "Tarjetas amarillas", value: estadisticas?.totales?.total_tarjetas_amarillas, icon: "🟨" },
                  { label: "Tarjetas rojas", value: estadisticas?.totales?.total_tarjetas_rojas, icon: "🟥" },
                  { label: "Arco en cero", value: estadisticas?.totales?.total_arco_en_cero, icon: "🧤" },
                ].map((stat, idx) => (
                  <div key={idx} className="col-lg-3 col-md-4 col-sm-6 mb-4">
                    <div className="card stat-card shadow h-100 border-0">
                      <div className="card-body text-center py-4">
                        <div className="stat-icon text-danger mb-3">{stat.icon}</div>
                        <h6 className="card-title text-danger fw-bold mb-2">{stat.label}</h6>
                        <p className="display-6 fw-bold text-dark mb-0">{stat.value ?? 0}</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </>
          )}
        </section>
      </main>

      {/* Footer */}
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

export default JugEstadisticas;