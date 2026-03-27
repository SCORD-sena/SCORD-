import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import NavbarJugador from "../../componentes/NavbarJugador";
import axios from "axios";

const InicioJugador = () => {
  const navigate = useNavigate();
  const [jugadorData, setJugadorData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const cargarDatosJugador = async () => {
      try {
        setLoading(true);

        const token = localStorage.getItem("token");
        const userStr = localStorage.getItem("user");

        if (!token || !userStr) {
          throw new Error("No hay sesión activa. Por favor inicia sesión.");
        }

        const user = JSON.parse(userStr);

        if (user.Rol?.idRoles !== 3 && user.idRoles !== 3) {
          throw new Error("No tienes permisos para acceder a esta página");
        }

        try {
          // ✅ Llamar al nuevo endpoint misDatos
          const response = await axios.get(
            `http://127.0.0.1:8000/api/jugadores/misDatos`,
            {
              headers: {
                Authorization: `Bearer ${token}`,
                "Content-Type": "application/json",
                Accept: "application/json",
              },
            }
          );

          if (response.data.success) {
            setJugadorData(response.data.data);
          } else {
            throw new Error("Error al cargar datos");
          }
        } catch (err) {
          console.error("Error al cargar datos de la API:", err);
          throw new Error("No se pudieron cargar tus datos. Contacta al administrador.");
        }

        setError(null);
      } catch (err) {
        console.error("Error:", err);
        setError(err.message);

        if (err.message.includes("sesión") || err.message.includes("permisos")) {
          setTimeout(() => {
            navigate("/login");
          }, 2000);
        }
      } finally {
        setLoading(false);
      }
    };

    cargarDatosJugador();
  }, [navigate]);

  const calcularEdad = (fechaNacimiento) => {
    if (!fechaNacimiento) return "";
    const hoy = new Date();
    const nacimiento = new Date(fechaNacimiento);
    let edad = hoy.getFullYear() - nacimiento.getFullYear();
    const mes = hoy.getMonth() - nacimiento.getMonth();
    if (mes < 0 || (mes === 0 && hoy.getDate() < nacimiento.getDate())) {
      edad--;
    }
    return edad;
  };

  const formatearFecha = (fecha) => {
    if (!fecha) return "N/A";
    const date = new Date(fecha);
    return date.toLocaleDateString("es-CO", {
      year: "numeric",
      month: "long",
      day: "numeric",
    });
  };

  if (!localStorage.getItem("token") || !localStorage.getItem("user")) {
    return (
      <div className="d-flex justify-content-center align-items-center min-vh-100">
        <div className="alert alert-warning text-center">
          <h4>No hay sesión activa</h4>
          <p>Redirigiendo al login...</p>
          <div className="spinner-border text-danger" role="status">
            <span className="visually-hidden">Cargando...</span>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="d-flex flex-column min-vh-100">
      <meta charSet="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Inicio Jugador - SCORD</title>
      <link
        href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css"
        rel="stylesheet"
      />
      <link rel="stylesheet" href="Css/InicioJugador.css" />

      {/* Header */}
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

          <label
            className="labe_hamburguesa d-md-none"
            htmlFor="menu_hamburguesa"
          >
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
          <NavbarJugador />
        </nav>
      </header>

      {/* Contenido Principal */}
      <main className="container my-5 flex-grow-1">
        <section className="text-center mb-5">
          {loading ? (
            <div
              className="d-flex justify-content-center align-items-center"
              style={{ minHeight: "200px" }}
            >
              <div className="spinner-border text-danger" role="status">
                <span className="visually-hidden">Cargando...</span>
              </div>
            </div>
          ) : error ? (
            <div className="alert alert-danger" role="alert">
              <h4>Error</h4>
              <p>{error}</p>
              {error.includes("sesión") && <p>Redirigiendo al login...</p>}
            </div>
          ) : jugadorData ? (
            <>
              <h1 className="mb-3">
                Bienvenido(a),{" "}
                <span className="text-danger">
                  {jugadorData.Nombre1} {jugadorData.Apellido1}
                </span>
              </h1>
              <img
                src="/Img/FotoPerfil.png"
                alt="Foto de Perfil"
                className="rounded-circle shadow mb-3"
                style={{
                  width: "150px",
                  height: "150px",
                  objectFit: "cover",
                }}
              />

              {/* Info Básica + Info Deportiva + Info Tutores */} 
              <div className="row mt-3">
                {/* Info Básica - Izquierda */}
                <div className="col-md-4">
                  <ul className="list-group list-group-flush shadow-sm">
                    <li className="list-group-item d-flex justify-content-between">
                      <strong>Nombre Completo:</strong>
                      <span>
                        {jugadorData.Nombre1} {jugadorData.Nombre2 || ""}{" "}
                        {jugadorData.Apellido1} {jugadorData.Apellido2 || ""}
                      </span>
                    </li>
                    <li className="list-group-item d-flex justify-content-between">
                      <strong>Edad:</strong>
                      <span>{calcularEdad(jugadorData.FechaDeNacimiento)} años</span>
                    </li>
                    <li className="list-group-item d-flex justify-content-between">
                      <strong>Fecha de Nacimiento:</strong>
                      <span>{formatearFecha(jugadorData.FechaDeNacimiento)}</span>
                    </li>
                    <li className="list-group-item d-flex justify-content-between">
                      <strong>Género:</strong>
                      <span>{jugadorData.Genero || "N/A"}</span>
                    </li>
                    <li className="list-group-item d-flex justify-content-between">
                      <strong>Teléfono:</strong>
                      <span>{jugadorData.Telefono || "N/A"}</span>
                    </li>
                    <li className="list-group-item d-flex justify-content-between">
                      <strong>Correo:</strong>
                      <span>{jugadorData.correo || "N/A"}</span>
                    </li>
                  </ul>
                </div>

                {/* Info Deportiva - Centro */}
                <div className="col-md-4">
                  <ul className="list-group list-group-flush shadow-sm">
                    <li className="list-group-item d-flex justify-content-between">
                      <strong>Categoría:</strong>
                      <span>{jugadorData.Categoria || "N/A"}</span>
                    </li>
                    <li className="list-group-item d-flex justify-content-between">
                      <strong>Dorsal:</strong>
                      <span>{jugadorData.Dorsal || "N/A"}</span>
                    </li>
                    <li className="list-group-item d-flex justify-content-between">
                      <strong>Posición:</strong>
                      <span>{jugadorData.Posicion || "N/A"}</span>
                    </li>
                    <li className="list-group-item d-flex justify-content-between">
                      <strong>Estatura:</strong>
                      <span>
                        {jugadorData.Estatura ? jugadorData.Estatura + " cm" : "N/A"}
                      </span>
                    </li>
                  </ul>
                </div>

                {/* Info Tutores - Derecha */}
                <div className="col-md-4">
                  <ul className="list-group list-group-flush shadow-sm">
                    <li className="list-group-item d-flex justify-content-between">
                      <strong>Tutor 1:</strong>
                      <span>
                        {jugadorData.NomTutor1 || "N/A"} {jugadorData.ApeTutor1 || ""}
                      </span>
                    </li>
                    <li className="list-group-item d-flex justify-content-between">
                      <strong>Tutor 2:</strong>
                      <span>
                        {jugadorData.NomTutor2 || "N/A"} {jugadorData.ApeTutor2 || ""}
                      </span>
                    </li>
                    <li className="list-group-item d-flex justify-content-between">
                      <strong>Teléfono Tutor:</strong>
                      <span>{jugadorData.TelefonoTutor || "N/A"}</span>
                    </li>
                  </ul>
                </div>
              </div>
            </>
          ) : null}
        </section>

        {/* Carousel */}
        <section className="mb-5">
          <div
            id="carouselInfo"
            className="carousel slide"
            data-bs-ride="carousel"
          >
            <div
              className="carousel-inner bg-light rounded shadow"
              style={{ minHeight: "400px" }}
            >
              <div className="carousel-item active text-center p-5">
                <h2 className="text-danger mb-4">¿Quiénes Somos?</h2>
                <p className="mb-4">
                  Somos Fénix, una escuela de fútbol apasionada por la formación
                  deportiva y el desarrollo integral de nuestros jugadores.
                  Ubicados en la 8va localidad de Bogotá, Kennedy, entrenamos en
                  el Parque Timiza...
                </p>
                <img
                  src="/Img/Escudo quilmes.jpg"
                  className="rounded shadow"
                  style={{ maxWidth: "300px" }}
                  alt="Escudo del equipo"
                />
              </div>

              <div className="carousel-item text-center p-5">
                <h2 className="text-danger mb-4">Misión</h2>
                <p>
                  En Fénix, nuestra misión es formar futbolistas íntegros,
                  promoviendo valores como el respeto, la disciplina y la
                  perseverancia. A través de entrenamientos de alta calidad y
                  participación en torneos, buscamos potenciar el talento de
                  nuestros jugadores y brindarles oportunidades para crecer
                  tanto en lo deportivo como en lo personal.
                </p>
                <img
                  src="/Img/+3.png"
                  className="rounded shadow mt-3"
                  style={{ maxWidth: "500px" }}
                  alt="Entrenamiento"
                />
              </div>

              <div className="carousel-item text-center p-5">
                <h2 className="text-danger mb-4">Visión</h2>
                <p>
                  Nos proyectamos como una de las academias más reconocidas de
                  Bogotá, destacándonos por nuestra excelencia en la formación
                  de jugadores y nuestra contribución al desarrollo social.
                  Aspiramos a ser un referente en el fútbol profesional y
                  personal.
                </p>
                <img
                  src="/Img/Niños-Fiesta.jpg"
                  className="rounded shadow mt-3"
                  style={{ maxWidth: "500px" }}
                  alt="Entrenamiento"
                />
              </div>
            </div>

            <button
              className="carousel-control-prev"
              type="button"
              data-bs-target="#carouselInfo"
              data-bs-slide="prev"
            >
              <span className="carousel-control-prev-icon" />
            </button>
            <button
              className="carousel-control-next"
              type="button"
              data-bs-target="#carouselInfo"
              data-bs-slide="next"
            >
              <span className="carousel-control-next-icon" />
            </button>
          </div>
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
            © 2025 SCORD | Escuela de Fútbol Quilmes | Todos los derechos
            reservados
          </p>
        </div>
      </footer>
    </div>
  );
};

export default InicioJugador;