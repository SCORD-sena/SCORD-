import React, { useState, useEffect } from "react";
import api from "../../config/axiosConfig";
import NavbarEntrenador from "../../componentes/NavbarEntrenador";

const PerfilJugEntre = () => {
  const [jugadores, setJugadores] = useState([]);
  const [categorias, setCategorias] = useState([]);
  const [categoriaSeleccionada, setCategoriaSeleccionada] = useState("");
  const [jugadorSeleccionado, setJugadorSeleccionado] = useState(null);
  const [jugadoresFiltrados, setJugadoresFiltrados] = useState([]);

  useEffect(() => {
    fetchJugadores();
    fetchCategorias();
  }, []);

  useEffect(() => {
    if (categoriaSeleccionada) {
      const filtrados = jugadores.filter(
        (j) => j.idCategorias === parseInt(categoriaSeleccionada)
      );
      setJugadoresFiltrados(filtrados);
      setJugadorSeleccionado(null);
    } else {
      setJugadoresFiltrados([]);
      setJugadorSeleccionado(null);
    }
  }, [categoriaSeleccionada, jugadores]);

  const fetchJugadores = async () => {
    try {
      const res = await api.get("/jugadores");
      setJugadores(res.data);
    } catch (err) {
      console.error("Error fetching jugadores:", err);
    }
  };

  const fetchCategorias = async () => {
    try {
      const res = await api.get("/categorias");
      setCategorias(res.data);
    } catch (err) {
      console.error("Error fetching categorias:", err);
    }
  };

  const persona = jugadorSeleccionado?.persona || null;
  const categoria = jugadorSeleccionado?.categoria || null;

  const calcularEdad = (fechaNacimiento) => {
    if (!fechaNacimiento) return "-";
    const hoy = new Date();
    const nacimiento = new Date(fechaNacimiento);
    let edad = hoy.getFullYear() - nacimiento.getFullYear();
    const mes = hoy.getMonth() - nacimiento.getMonth();
    if (mes < 0 || (mes === 0 && hoy.getDate() < nacimiento.getDate())) {
      edad--;
    }
    return edad;
  };

  return (
    <div>
      <meta charSet="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Perfil Jugadores - SCORD</title>
      <link
        href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css"
        rel="stylesheet"
        integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65"
        crossOrigin="anonymous"
      />
      <link rel="stylesheet" href="/Css/InicioAdmin.css" />

      <header className="header bg-white shadow-sm py-3">
        <nav className="navbar container d-flex align-items-center justify-content-between flex-wrap">
          <div className="d-flex align-items-center">
            <img
              src="/Img/SCORD.png"
              alt="Logo SCORD"
              className="me-2"
              style={{ height: "60px" }}
            />
            <h4 className="mb-0 text-danger fw-bold">SCORD</h4>
          </div>
          <label className="labe_hamburguesa d-md-none" htmlFor="menu_hamburguesa">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width={35}
              height={35}
              fill="#e63946"
              viewBox="0 0 16 16"
            >
              <path
                fillRule="evenodd"
                d="M2.5 12a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5z"
              />
            </svg>
          </label>
          <input
            className="menu_hamburguesa d-none"
            type="checkbox"
            id="menu_hamburguesa"
          />
          <NavbarEntrenador />
        </nav>
      </header>

      <main className="container my-5">
        <div className="row g-5 align-items-start">
          <div className="col-md-6">
            <section className="text-center mb-4">
              <div className="mb-3">
                <label
                  htmlFor="categoriaSelect"
                  className="form-label fw-semibold text-danger"
                >
                  Seleccionar Categoría:
                </label>
                <select
                  className="form-select mx-auto"
                  id="categoriaSelect"
                  style={{ maxWidth: "300px" }}
                  value={categoriaSeleccionada}
                  onChange={(e) => setCategoriaSeleccionada(e.target.value)}
                >
                  <option value="">-- Selecciona una categoría --</option>
                  {categorias.map((cat) => (
                    <option key={cat.idCategorias} value={cat.idCategorias}>
                      {cat.Descripcion}
                    </option>
                  ))}
                </select>
              </div>

              <div className="mb-3">
                <label
                  htmlFor="jugadorSelect"
                  className="form-label fw-semibold text-danger"
                >
                  Seleccionar Jugador:
                </label>
                <select
                  className="form-select mx-auto"
                  id="jugadorSelect"
                  style={{ maxWidth: "300px" }}
                  value={jugadorSeleccionado?.idJugadores || ""}
                  onChange={(e) => {
                    const jugador = jugadores.find(
                      (j) => j.idJugadores === parseInt(e.target.value)
                    );
                    setJugadorSeleccionado(jugador);
                  }}
                  disabled={!categoriaSeleccionada}
                >
                  <option value="">-- Selecciona un jugador --</option>
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

              <img
                src="/Img/Foto_Perfil.webp"
                alt="Foto de Perfil"
                className="rounded-circle shadow mb-4"
                style={{ width: "150px" }}
              />
            </section>
          </div>

          <div className="col-md-6">
            <section>
              <h3 className="fw-semibold mb-1 text-center">
                📞 Información de Contacto
              </h3>
              <ul className="list-group list-group-flush shadow-sm rounded-3 mb-4">
                <li className="list-group-item d-flex justify-content-between">
                  <span className="text-danger fw-semibold">Teléfono:</span>
                  <span>{persona?.Telefono || "-"}</span>
                </li>
                <li className="list-group-item d-flex justify-content-between">
                  <span className="text-danger fw-semibold">Dirección:</span>
                  <span>{persona?.Direccion || "-"}</span>
                </li>
                <li className="list-group-item d-flex justify-content-between">
                  <span className="text-danger fw-semibold">Email:</span>
                  <span>{persona?.correo || "-"}</span>
                </li>
                <li className="list-group-item d-flex justify-content-between">
                  <span className="text-danger fw-semibold">EPS:</span>
                  <span>{persona?.EpsSisben || "-"}</span>
                </li>
              </ul>
            </section>

            <section>
              <h3 className="fw-semibold mb-1 text-center">
                👨‍👩‍👦 Información de Tutores
              </h3>
              <ul className="list-group list-group-flush shadow-sm rounded-3">
                <li className="list-group-item d-flex justify-content-between">
                  <span className="text-danger fw-semibold">Nombre del tutor:</span>
                  <span>
                    {jugadorSeleccionado
                      ? `${jugadorSeleccionado.NomTutor1 || ""} ${
                          jugadorSeleccionado.ApeTutor1 || ""
                        }`.trim() || "-"
                      : "-"}
                  </span>
                </li>
                <li className="list-group-item d-flex justify-content-between">
                  <span className="text-danger fw-semibold">Teléfono del Tutor:</span>
                  <span>{jugadorSeleccionado?.TelefonoTutor || "-"}</span>
                </li>
              </ul>
            </section>
          </div>
        </div>

        <div className="row g-5 mt-4">
          <div className="col-md-6">
            <h3 className="text-center fw-semibold mb-1">👤 Información Personal</h3>
            <ul className="list-group list-group-flush shadow-sm rounded-3">
              <li className="list-group-item d-flex justify-content-between">
                <strong>Nombres:</strong>
                <span>
                  {persona ? `${persona.Nombre1} ${persona.Nombre2 || ""}`.trim() : "-"}
                </span>
              </li>
              <li className="list-group-item d-flex justify-content-between">
                <strong>Apellidos:</strong>
                <span>
                  {persona ? `${persona.Apellido1} ${persona.Apellido2}`.trim() : "-"}
                </span>
              </li>
              <li className="list-group-item d-flex justify-content-between">
                <strong>Edad:</strong>
                <span>{persona ? calcularEdad(persona.FechaDeNacimiento) : "-"}</span>
              </li>
              <li className="list-group-item d-flex justify-content-between">
                <strong>Fecha de Nacimiento:</strong>
                <span>
                  {persona?.FechaDeNacimiento
                    ? new Date(persona.FechaDeNacimiento).toLocaleDateString("es-CO", {
                        day: "2-digit",
                        month: "2-digit",
                        year: "numeric",
                      })
                    : "-"}
                </span>
              </li>
              <li className="list-group-item d-flex justify-content-between">
                <strong>Documento:</strong>
                <span>{persona?.NumeroDeDocumento || "-"}</span>
              </li>
              <li className="list-group-item d-flex justify-content-between">
                <strong>Genero:</strong>
                <span>{persona?.Genero || "-"}</span>
              </li>
            </ul>
          </div>

          <div className="col-md-6">
            <h3 className="text-center fw-semibold mb-1">⚽ Información Deportiva</h3>
            <ul className="list-group list-group-flush shadow-sm rounded-3">
              <li className="list-group-item d-flex justify-content-between">
                <span className="text-danger fw-semibold">Dorsal:</span>
                <span>{jugadorSeleccionado?.Dorsal || "-"}</span>
              </li>
              <li className="list-group-item d-flex justify-content-between">
                <span className="text-danger fw-semibold">Posición:</span>
                <span>{jugadorSeleccionado?.Posicion || "-"}</span>
              </li>
              <li className="list-group-item d-flex justify-content-between">
                <span className="text-danger fw-semibold">Estatura:</span>
                <span>
                  {jugadorSeleccionado?.Estatura
                    ? `${jugadorSeleccionado.Estatura} cm`
                    : "-"}
                </span>
              </li>
              <li className="list-group-item d-flex justify-content-between">
                <span className="text-danger fw-semibold">UPZ:</span>
                <span>{jugadorSeleccionado?.Upz || "-"}</span>
              </li>
              <li className="list-group-item d-flex justify-content-between">
                <span className="text-danger fw-semibold">Categoría:</span>
                <span>{categoria?.Descripcion || "-"}</span>
              </li>
            </ul>
          </div>
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

export default PerfilJugEntre;