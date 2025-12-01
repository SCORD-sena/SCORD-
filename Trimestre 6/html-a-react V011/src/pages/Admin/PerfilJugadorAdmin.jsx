import React from "react";
import { Link } from "react-router-dom";
import Swal from "sweetalert2"
import NavbarAdmin from "../../componentes/NavbarAdmin";

const PerfilJugadorAdmin = () => {
  const eliminarJugador = () => {
     
       Swal.fire({
        title: "¿Estás seguro?",
        text: "Se Eliminara el jugador",
        icon: "warning",
        showCancelButton: true,
        confirmButtonText: "Sí, eliminar",
        cancelButtonText: "Cancelar",
        confirmButtonColor: "#d33",
        cancelButtonColor: "#28a745"
      }).then((result) => {
        if (result.isConfirmed) {
          Swal.fire({
            icon: "success",
            title: "¡Datos actualizados!",
            text: "Los jugador se elimino correctamente",
            confirmButtonColor: "#28a745"
          });
    
        }
    });

  };
  return (
    <div>
      <meta charSet="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Inicio - SCORD</title>
      {/* Bootstrap */}
      <link
        href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css"
        rel="stylesheet"
        integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65"
        crossOrigin="anonymous"
      />
      <link rel="stylesheet" href="/Css/InicioAdmin.css" />

      {/* HEADER */}
      <header className="header bg-white shadow-sm py-3">
        <nav className="navbar container d-flex align-items-center justify-content-between flex-wrap">
          <div className="d-flex align-items-center">
            <img src="/Img/SCORD.png" alt="Logo SCORD" className="me-2" style={{height: '60px'}} />
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
          <NavbarAdmin />
        </nav>
      </header>

      {/* MAIN */}
      <main className="container my-5">
        {/* Botones de crud - ARRIBA DE TODO */}
        <div className="d-flex justify-content-center mb-4 gap-2 flex-wrap">
  <Link to="/AgregarJugador" className="btn btn-success fw-bold">Agregar Jugador</Link>
  <Link to="/EditarJugador" className="btn btn-warning fw-bold">Editar Jugador</Link>
  <button className="btn btn-danger fw-bold" onClick={eliminarJugador}>Eliminar Jugador</button>
</div>
        {/* Primera fila - Selectores/Foto y Contacto */}
        <div className="row g-5 align-items-start">
          {/* Columna izquierda */}
          <div className="col-md-6">
            <section className="text-center mb-4">
              {/* Selectores */}
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
                >
                  <option selected disabled>
                    -- Selecciona una categoría --
                  </option>
                  <option value="Sub20">Sub20</option>
                  <option value="2005">2005</option>
                  <option value="2006">2006</option>
                  <option value="2007">2007</option>
                  <option value="2008">2008</option>
                  <option value="2009">2009</option>
                  <option value="2010">2010</option>
                  <option value="2011">2011</option>
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
                >
                  <option selected disabled>
                    -- Selecciona un jugador --
                  </option>
                  <option value="george">George Sanchez</option>
                  <option value="miguel">Miguel Torres</option>
                  <option value="carlos">Carlos Pérez</option>
                </select>
              </div>
              {/* Foto */}
              <img
                src="/Img/Foto_Perfil.webp"
                alt="Foto de Perfil"
                className="rounded-circle shadow mb-4"
                style={{ width: "150px" }}
              />
            </section>
          </div>

          {/* Columna derecha -> Contacto y Tutores */}
          <div className="col-md-6">
            <section>
              <h3 className="fw-semibold mb-1 text-center">
                📞 Información de Contacto
              </h3>
              
              <ul className="list-group list-group-flush shadow-sm rounded-3 mb-4">
                <li className="list-group-item d-flex justify-content-between">
                  <span className="text-danger fw-semibold">Teléfono:</span>
                  <span>3132468703</span>
                </li>
                <li className="list-group-item d-flex justify-content-between">
                  <span className="text-danger fw-semibold">Dirección:</span>
                  <span>Cra 81b #42-24 sur</span>
                </li>
                <li className="list-group-item d-flex justify-content-between">
                  <span className="text-danger fw-semibold">Email:</span>
                  <span>GeorgeAndre@gmail.com</span>
                </li>
                <li className="list-group-item d-flex justify-content-between">
                  <span className="text-danger fw-semibold">EPS:</span>
                  <span>Sisbén</span>
                </li>
              </ul>
            </section>
            <section>
              <h3 className="fw-semibold mb-1 text-center">
                👨‍👩‍👦 Información de Tutores
              </h3>
              <ul className="list-group list-group-flush shadow-sm rounded-3">
                <li className="list-group-item d-flex justify-content-between">
                  <span className="text-danger fw-semibold">
                    Nombre del tutor:
                  </span>
                  <span>Andrea Ibarra</span>
                </li>
                <li className="list-group-item d-flex justify-content-between">
                  <span className="text-danger fw-semibold">
                    Teléfono del Tutor:
                  </span>
                  <span>3213219645</span>
                </li>
              </ul>
            </section>
          </div>
        </div>

        {/* Segunda fila -> Personal y Deportiva */}
        <div className="row g-5 mt-4">
          <div className="col-md-6">
            <h3 className="text-center fw-semibold mb-1">
              👤 Información Personal
            </h3>
            <ul className="list-group list-group-flush shadow-sm rounded-3">
              <li className="list-group-item d-flex justify-content-between">
                <strong>Nombres:</strong> <span>George Andres</span>
              </li>
              <li className="list-group-item d-flex justify-content-between">
                <strong>Apellidos:</strong> <span>Sanchez Duque</span>
              </li>
              <li className="list-group-item d-flex justify-content-between">
                <strong>Edad:</strong> <span>17</span>
              </li>
              <li className="list-group-item d-flex justify-content-between">
                <strong>Fecha de Nacimiento:</strong> <span>06 Abril 2008</span>
              </li>
              <li className="list-group-item d-flex justify-content-between">
                <strong>Documento:</strong> <span>1029220893</span>
              </li>
              <li className="list-group-item d-flex justify-content-between">
                <strong>Genero:</strong> <span>Masculino</span>
              </li>
            </ul>
          </div>

          <div className="col-md-6">
            <h3 className="text-center fw-semibold mb-1">
              ⚽ Información Deportiva
            </h3>
            <ul className="list-group list-group-flush shadow-sm rounded-3">
              <li className="list-group-item d-flex justify-content-between">
                <span className="text-danger fw-semibold">Dorsal:</span>{" "}
                <span>11</span>
              </li>
              <li className="list-group-item d-flex justify-content-between">
                <span className="text-danger fw-semibold">Posición:</span>{" "}
                <span>Mediocampista</span>
              </li>
              <li className="list-group-item d-flex justify-content-between">
                <span className="text-danger fw-semibold">Estatura:</span>{" "}
                <span>175 cm</span>
              </li>
              <li className="list-group-item d-flex justify-content-between">
                <span className="text-danger fw-semibold">UPZ:</span>{" "}
                <span>El Amparo</span>
              </li>
              <li className="list-group-item d-flex justify-content-between">
                <span className="text-danger fw-semibold">Categoría:</span>{" "}
                <span>Sub20</span>
              </li>
            </ul>
          </div>
        </div>
      </main>

      {/* FOOTER */}
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

export default PerfilJugadorAdmin;