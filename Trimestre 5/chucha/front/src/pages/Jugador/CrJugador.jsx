import React, { useState, useEffect } from "react";
import axios from "axios";
import Swal from "sweetalert2";
import NavbarJugador from "../../componentes/NavbarJugador";

const api = axios.create({
  baseURL: "http://127.0.0.1:8000/api",
});

api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem("token");
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

const CrJugador = () => {
  const [entrenamientos, setEntrenamientos] = useState([]);
  const [partidos, setPartidos] = useState([]);
  const [categoriaJugador, setCategoriaJugador] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDatosJugador();
  }, []);

  const fetchDatosJugador = async () => {
    try {
      setLoading(true);
      
      // Obtener información del usuario autenticado desde la API
      const resUser = await api.get("/me");
      console.log("Respuesta completa de /me:", resUser.data);
      
      // La respuesta tiene estructura: { success: true, data: {...} }
      const userData = resUser.data.data || resUser.data;
      console.log("Datos del usuario:", userData);
      
      // Obtener la categoría desde los datos del jugador
      const idCategoria = userData.idCategorias;
      console.log("ID de Categoría:", idCategoria);
      
      if (!idCategoria) {
        Swal.fire({
          icon: "warning",
          title: "Categoría no encontrada",
          text: "No se pudo determinar tu categoría. Contacta al administrador.",
          confirmButtonColor: "#e63946"
        });
        setLoading(false);
        return;
      }
      
      setCategoriaJugador(idCategoria);
      
      // Obtener cronogramas
      const resCronogramas = await api.get("/cronogramas");
      console.log("Todos los cronogramas:", resCronogramas.data);
      
      // Convertir a número para comparación
      const idCategoriaNum = parseInt(idCategoria);
      
      // Filtrar cronogramas por categoría
      const cronogramasFiltrados = resCronogramas.data.filter((c) => {
        const categoriaMatch = parseInt(c.idCategorias) === idCategoriaNum;
        console.log(`Cronograma ${c.idCronogramas}: idCategorias=${c.idCategorias}, Match=${categoriaMatch}`);
        return categoriaMatch;
      });
      
      console.log("Cronogramas filtrados:", cronogramasFiltrados);
      
      // Separar entrenamientos
      const entrenamientosFiltrados = cronogramasFiltrados.filter(
        (c) => c.TipoDeEventos === "Entrenamiento"
      );
      console.log("Entrenamientos encontrados:", entrenamientosFiltrados);
      setEntrenamientos(entrenamientosFiltrados);
      
      // Obtener partidos
      const resPartidos = await api.get("/partidos");
      console.log("Todos los partidos:", resPartidos.data);
      
      // Filtrar partidos que pertenezcan a cronogramas de la categoría
      const partidosFiltrados = resPartidos.data.filter((partido) => {
        const cronograma = cronogramasFiltrados.find(
          (c) => c.idCronogramas === partido.idCronogramas
        );
        return cronograma !== undefined;
      });
      
      console.log("Partidos filtrados:", partidosFiltrados);
      
      // Combinar datos de partidos con cronogramas
      const partidosConDatos = partidosFiltrados.map((partido) => {
        const cronograma = cronogramasFiltrados.find(
          (c) => c.idCronogramas === partido.idCronogramas
        );
        return {
          ...partido,
          FechaDeEventos: cronograma?.FechaDeEventos,
          Ubicacion: cronograma?.Ubicacion,
          CanchaPartido: cronograma?.CanchaPartido,
        };
      });
      
      console.log("Partidos con datos completos:", partidosConDatos);
      setPartidos(partidosConDatos);
      
    } catch (err) {
      console.error("Error cargando datos:", err);
      console.error("Detalles del error:", err.response?.data);
      Swal.fire({
        icon: "error",
        title: "Error",
        text: err.response?.data?.message || "No se pudieron cargar los datos del cronograma",
        confirmButtonColor: "#e63946"
      });
    } finally {
      setLoading(false);
    }
  };

  const formatearFecha = (fecha) => {
    if (!fecha) return "-";
    const date = new Date(fecha);
    return date.toLocaleDateString("es-CO", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric"
    });
  };

  const obtenerDiaSemana = (fecha) => {
    if (!fecha) return "-";
    const date = new Date(fecha);
    const dias = ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"];
    return dias[date.getDay()];
  };

  return (
    <div>
      <meta charSet="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Cronograma - SCORD</title>
      <link rel="stylesheet" href="Css/InicioEntrenador.css" />
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" />
      
      <div className="d-flex flex-column min-vh-100">
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

      <main className="container my-5">
        <h1 className="text-center text-danger mb-4">Calendario de Actividades</h1>
        
        {loading ? (
          <div className="text-center my-5">
            <div className="spinner-border text-danger" role="status">
              <span className="visually-hidden">Cargando...</span>
            </div>
            <p className="mt-3">Cargando tu cronograma...</p>
          </div>
        ) : (
          <>
            {/* Entrenamientos */}
            <section className="mb-5">
              <h2 className="mb-3">Entrenamientos Programados</h2>
              <div className="table-responsive">
                <table className="table table-bordered table-striped">
                  <thead className="table-danger">
                    <tr>
                      <th>Día</th>
                      <th>Fecha</th>
                      <th>Ubicación</th>
                      <th>Sede</th>
                      <th>Descripción</th>
                    </tr>
                  </thead>
                  <tbody>
                    {entrenamientos.length > 0 ? (
                      entrenamientos.map((entrenamiento) => (
                        <tr key={entrenamiento.idCronogramas}>
                          <td>{obtenerDiaSemana(entrenamiento.FechaDeEventos)}</td>
                          <td>{formatearFecha(entrenamiento.FechaDeEventos)}</td>
                          <td>{entrenamiento.Ubicacion || "-"}</td>
                          <td>{entrenamiento.SedeEntrenamiento || "-"}</td>
                          <td>{entrenamiento.Descripcion || "-"}</td>
                        </tr>
                      ))
                    ) : (
                      <tr>
                        <td colSpan="5" className="text-center">
                          No hay entrenamientos programados para tu categoría
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </section>

            {/* Partidos */}
            <section className="mb-5">
              <h2 className="mb-3">Partidos Programados</h2>
              <div className="table-responsive">
                <table className="table table-bordered table-striped">
                  <thead className="table-danger">
                    <tr>
                      <th>Fecha</th>
                      <th>Equipo Rival</th>
                      <th>Formación</th>
                      <th>Ubicación</th>
                      <th>Cancha</th>
                    </tr>
                  </thead>
                  <tbody>
                    {partidos.length > 0 ? (
                      partidos.map((partido) => (
                        <tr key={partido.idPartidos}>
                          <td>{formatearFecha(partido.FechaDeEventos)}</td>
                          <td>{partido.EquipoRival || "-"}</td>
                          <td>{partido.Formacion || "-"}</td>
                          <td>{partido.Ubicacion || "-"}</td>
                          <td>{partido.CanchaPartido || "-"}</td>
                        </tr>
                      ))
                    ) : (
                      <tr>
                        <td colSpan="5" className="text-center">
                          No hay partidos programados para tu categoría
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </section>
          </>
        )}
      </main>

       <footer className="bg-dark text-white py-4 mt-auto">
    <div className="container">
      <div className="row text-center text-md-start">
        <div className="col-md-6 mb-3">
          <h5 className="text-danger">SCORD</h5>
          <p className="mb-0">Sistema de control y organización deportiva</p>
        </div>
        <div className="col-md-6 mb-3">
          <h5 className="text-danger">Escuela Quilmes</h5>
          <p className="mb-0">Formando talentos para el futuro</p>
        </div>
      </div>
      <hr className="border-light" />
      <p className="text-center small mb-0">
        © 2025 SCORD | Escuela de Fútbol Quilmes | Todos los derechos reservados
      </p>
    </div>
  </footer>
    </div>
    </div>
  );
};

export default CrJugador;