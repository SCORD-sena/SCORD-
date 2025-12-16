import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import api from "../../config/axiosConfig";
import Swal from "sweetalert2";
import NavbarAdmin from "../../componentes/NavbarAdmin";

const AgregarEstadistica = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [jugadores, setJugadores] = useState([]);
  const [categorias, setCategorias] = useState([]);
  const [partidos, setPartidos] = useState([]);
  const [categoriaSeleccionada, setCategoriaSeleccionada] = useState("");
  const [jugadoresFiltrados, setJugadoresFiltrados] = useState([]);

  useEffect(() => {
    cargarDatos();
  }, []);

  useEffect(() => {
    if (categoriaSeleccionada) {
      const filtrados = jugadores.filter((j) => j.idCategorias === parseInt(categoriaSeleccionada));
      setJugadoresFiltrados(filtrados);
    } else {
      setJugadoresFiltrados([]);
    }
  }, [categoriaSeleccionada, jugadores]);

  const cargarDatos = async () => {
    try {
      const [jugadoresRes, categoriasRes, partidosRes] = await Promise.all([
        api.get("/jugadores"),
        api.get("/categorias"),
        api.get("/partidos")
      ]);

      setJugadores(jugadoresRes.data.data || jugadoresRes.data);
      setCategorias(categoriasRes.data);
      setPartidos(partidosRes.data);
    } catch (err) {
      console.error("Error cargando datos:", err);
      Swal.fire({
        icon: "error",
        title: "Error",
        text: "No se pudieron cargar los datos necesarios",
        confirmButtonColor: "#e63946",
      });
    }
  };

  const crearEstadistica = async (e) => {
    e.preventDefault();
    const form = e.target;
    const data = new FormData(form);
    const values = Object.fromEntries(data.entries());

    if (!validarFormulario(values)) return;

    const result = await Swal.fire({
      title: "¿Guardar Estadística?",
      html: `
        <b>Goles:</b> ${values.goles}<br/>
        <b>Asistencias:</b> ${values.asistencias}<br/>
        <b>Minutos Jugados:</b> ${values.minutosJugados}<br/>
      `,
      icon: "question",
      showCancelButton: true,
      confirmButtonText: "Sí, guardar",
      cancelButtonText: "Cancelar",
      confirmButtonColor: "#28a745",
      cancelButtonColor: "#d33",
    });

    if (!result.isConfirmed) return;

    setLoading(true);

    try {
      const estadisticaData = {
        Goles: parseInt(values.goles) || 0,
        GolesDeCabeza: parseInt(values.golesDeCabeza) || 0,
        MinutosJugados: parseInt(values.minutosJugados) || 0,
        Asistencias: parseInt(values.asistencias) || 0,
        TirosApuerta: parseInt(values.tirosApuerta) || 0,
        TarjetasRojas: parseInt(values.tarjetasRojas) || 0,
        TarjetasAmarillas: parseInt(values.tarjetasAmarillas) || 0,
        FuerasDeLugar: parseInt(values.fuerasDeLugar) || 0,
        ArcoEnCero: parseInt(values.arcoEnCero) || 0,
        idPartidos: parseInt(values.idPartidos),
        idJugadores: parseInt(values.idJugadores)
      };

      console.log("Enviando estadística:", estadisticaData);

      await api.post("/rendimientospartidos", estadisticaData);

      await Swal.fire({
        icon: "success",
        title: "Estadística guardada",
        text: "Los datos se registraron correctamente.",
        confirmButtonColor: "#28a745",
      });

      form.reset();
      navigate("/EstadisticasJugador");
    } catch (err) {
      console.error("Error creando estadística:", err);

      let errorMsg = "No se pudo guardar la estadística";

      if (err.response?.data?.errors) {
        const errors = err.response.data.errors;
        errorMsg = Object.values(errors).flat().join("\n");
      } else if (err.response?.data?.message) {
        errorMsg = err.response.data.message;
      }

      Swal.fire({
        icon: "error",
        title: "Error",
        text: errorMsg,
        confirmButtonColor: "#e63946",
      });
    } finally {
      setLoading(false);
    }
  };

  const validarFormulario = (values) => {
    if (!values.idCategorias) {
      Swal.fire({
        icon: "warning",
        title: "Categoría requerida",
        text: "Debes seleccionar una categoría",
        confirmButtonColor: "#d33",
      });
      return false;
    }

    if (!values.idJugadores) {
      Swal.fire({
        icon: "warning",
        title: "Jugador requerido",
        text: "Debes seleccionar un jugador",
        confirmButtonColor: "#d33",
      });
      return false;
    }

    if (!values.idPartidos) {
      Swal.fire({
        icon: "warning",
        title: "Partido requerido",
        text: "Debes seleccionar un partido",
        confirmButtonColor: "#d33",
      });
      return false;
    }

    const camposNumericos = [
      { key: "goles", label: "Goles" },
      { key: "asistencias", label: "Asistencias" },
      { key: "minutosJugados", label: "Minutos Jugados" },
    ];

    for (const campo of camposNumericos) {
      const valor = values[campo.key];
      if (!valor || valor.trim() === "") {
        Swal.fire({
          icon: "warning",
          title: "Campo vacío",
          text: `El campo "${campo.label}" es obligatorio`,
          confirmButtonColor: "#d33",
        });
        return false;
      }

      if (isNaN(valor) || parseInt(valor) < 0) {
        Swal.fire({
          icon: "error",
          title: "Valor inválido",
          text: `El campo "${campo.label}" debe ser un número positivo`,
          confirmButtonColor: "#d33",
        });
        return false;
      }
    }

    if (values.minutosJugados && parseInt(values.minutosJugados) > 120) {
      Swal.fire({
        icon: "error",
        title: "Minutos inválidos",
        text: "Los minutos jugados no pueden ser mayores a 120",
        confirmButtonColor: "#d33",
      });
      return false;
    }

    return true;
  };

  return (
    <div>
      <meta charSet="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Agregar Estadística - SCORD</title>
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" />
      <link rel="stylesheet" href="/Css/InicioAdmin.css" />

      <header className="header bg-white shadow-sm py-3">
        <nav className="navbar container d-flex align-items-center justify-content-between flex-wrap">
          <div className="d-flex align-items-center">
            <img src="/Img/SCORD.png" alt="Logo SCORD" className="me-2" style={{ height: "60px" }} />
            <h4 className="mb-0 text-danger fw-bold">SCORD</h4>
          </div>
          <NavbarAdmin />
        </nav>
      </header>

      <main className="container my-5">
        <div className="text-center mb-4">
          <h1 className="text-danger">Agregar Registro Estadístico</h1>
        </div>

        <form onSubmit={crearEstadistica}>
          <div className="row">
            {/* Selección de Categoría, Jugador y Partido */}
            <div className="col-12 mb-4">
              <div className="card shadow-sm">
                <div className="card-body">
                  <h5 className="text-danger mb-3">Seleccionar Jugador y Partido</h5>
                  
                  <div className="row">
                    <div className="col-md-4 mb-3">
                      <label className="form-label">Categoría *</label>
                      <select
                        name="idCategorias"
                        className="form-select"
                        value={categoriaSeleccionada}
                        onChange={(e) => setCategoriaSeleccionada(e.target.value)}
                        required
                      >
                        <option value="">Seleccionar categoría</option>
                        {categorias.map((cat) => (
                          <option key={cat.idCategorias} value={cat.idCategorias}>
                            {cat.Descripcion}
                          </option>
                        ))}
                      </select>
                    </div>

                    <div className="col-md-4 mb-3">
                      <label className="form-label">Jugador *</label>
                      <select
                        name="idJugadores"
                        className="form-select"
                        disabled={!categoriaSeleccionada}
                        required
                      >
                        <option value="">Seleccionar jugador</option>
                        {jugadoresFiltrados.map((jug) => {
                          const pers = jug.persona;
                          return (
                            <option key={jug.idJugadores} value={jug.idJugadores}>
                              {pers ? `${pers.Nombre1} ${pers.Apellido1}` : "Sin nombre"}
                            </option>
                          );
                        })}
                      </select>
                    </div>

                    <div className="col-md-4 mb-3">
                      <label className="form-label">Partido *</label>
                      <select name="idPartidos" className="form-select" required>
                        <option value="">Seleccionar partido</option>
                        {partidos.map((partido) => (
                          <option key={partido.idPartidos} value={partido.idPartidos}>
                            {partido.Rival || `Partido #${partido.idPartidos}`}
                          </option>
                        ))}
                      </select>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Columna izquierda */}
            <div className="col-md-6">
              <div className="mb-3">
                <label className="form-label">⚽ Goles *</label>
                <input type="number" name="goles" className="form-control" min="0" required />
              </div>
              <div className="mb-3">
                <label className="form-label">🎯 Asistencias *</label>
                <input type="number" name="asistencias" className="form-control" min="0" required />
              </div>
              <div className="mb-3">
                <label className="form-label">⏱️ Minutos Jugados *</label>
                <input type="number" name="minutosJugados" className="form-control" min="0" max="120" required />
              </div>
              <div className="mb-3">
                <label className="form-label">⚽ Goles de Cabeza</label>
                <input type="number" name="golesDeCabeza" className="form-control" min="0" defaultValue="0" />
              </div>
              <div className="mb-3">
                <label className="form-label">🎯 Tiros a puerta</label>
                <input type="number" name="tirosApuerta" className="form-control" min="0" defaultValue="0" />
              </div>
            </div>

            {/* Columna derecha */}
            <div className="col-md-6">
              <div className="mb-3">
                <label className="form-label">🚩 Fueras de Juego</label>
                <input type="number" name="fuerasDeLugar" className="form-control" min="0" defaultValue="0" />
              </div>
              <div className="mb-3">
                <label className="form-label">🟨 Tarjetas Amarillas</label>
                <input type="number" name="tarjetasAmarillas" className="form-control" min="0" defaultValue="0" />
              </div>
              <div className="mb-3">
                <label className="form-label">🟥 Tarjetas Rojas</label>
                <input type="number" name="tarjetasRojas" className="form-control" min="0" defaultValue="0" />
              </div>
              <div className="mb-3">
                <label className="form-label">🧤 Arco en cero</label>
                <input type="number" name="arcoEnCero" className="form-control" min="0" defaultValue="0" />
              </div>
            </div>
          </div>

          {/* Botones */}
          <div className="mt-4 d-flex justify-content-end gap-3">
            <button type="submit" className="btn btn-success px-4" disabled={loading}>
              {loading ? "Guardando..." : "Guardar"}
            </button>
            <button
              type="button"
              className="btn btn-danger px-4"
              onClick={() => navigate("/EstadisticasJugador")}
              disabled={loading}
            >
              Cancelar
            </button>
          </div>
        </form>
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

export default AgregarEstadistica;