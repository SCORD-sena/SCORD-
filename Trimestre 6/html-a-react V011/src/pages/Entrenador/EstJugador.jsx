import React from "react";
import { Link } from "react-router-dom";
import NavbarAdmin from "../../componentes/NavbarAdmin";
import EstJugadorEntrenador from "../Entrenador/EstJugadorEntrenador";
import Estadisticas from "../Entrenador/Estadisticas";
import Swal from "sweetalert2";
import NavbarEntrenador from "../../componentes/NavbarEntrenador";

const EstJugador = () => {
    const eliminarEstadistica = () => {
               Swal.fire({
                title: "¿Estás seguro?",
                text: "Se Eliminara el ultimo registro",
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
                    text: "Los registro se elimino correctamente",
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
        {/* Bootstrap 5.2.3 */}
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossOrigin="anonymous" />
        <link rel="stylesheet" href="/Css/InicioAdmin.css" />
        <header className="header bg-white shadow-sm py-3">
          <nav className="navbar container d-flex align-items-center justify-content-between flex-wrap">
            {/* Logo y título */}
            <div className="d-flex align-items-center">
              <img src="/Img/SCORD.png" alt="Logo SCORD" className="me-2" style={{height: '60px'}} />
              <h4 className="mb-0 text-danger fw-bold">SCORD</h4>
            </div>
            {/* Icono hamburguesa */}
            <label className="labe_hamburguesa d-md-none" htmlFor="menu_hamburguesa">
              <svg xmlns="http://www.w3.org/2000/svg" width={35} height={35} fill="#e63946" viewBox="0 0 16 16">
                <path fillRule="evenodd" d="M2.5 12a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5z" />
              </svg>
            </label>
            {/* Checkbox oculto */}
            <input className="menu_hamburguesa d-none" type="checkbox" id="menu_hamburguesa" />
            {/* Menu de navegación importado */}
            <NavbarEntrenador />
      </nav>
        </header>

        <div className="d-flex justify-content-center mb-4 gap-2 flex-wrap">
  <Link to="/AgregarEst" className="btn btn-success fw-bold">Agregar Estadísticas</Link>
  <Link to="/EditarEst" className="btn btn-warning fw-bold">Editar Estadísticas</Link>
  <button className="btn btn-danger fw-bold" onClick={eliminarEstadistica}>Eliminar Estadísticas</button>
</div>

        <main className="container my-5">
  <div className="row g-5 align-items-start">
    {/* Columna izquierda */}
    <div className="col-md-6">
      <div className="card shadow-sm rounded-3 h-100">
        <div className="card-body text-center">
          {/* Selección */}
          <div className="mb-3">
            <label htmlFor="categoriaSelect" className="form-label fw-semibold text-danger">Seleccionar Categoría:</label>
            <select className="form-select mx-auto" id="categoriaSelect" style={{ maxWidth: "300px" }}>
              <option selected disabled>-- Selecciona una categoría --</option>
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
            <label htmlFor="jugadorSelect" className="form-label fw-semibold text-danger">Seleccionar Jugador:</label>
            <select className="form-select mx-auto" id="jugadorSelect" style={{ maxWidth: "300px" }}>
              <option selected disabled>-- Selecciona un jugador --</option>
              <option value="george">George Sanchez</option>
              <option value="miguel">Miguel Torres</option>
              <option value="carlos">Carlos Pérez</option>
            </select>
          </div>

          {/* Foto y datos */}
          <img src="/Img/Foto_Perfil.webp" alt="Foto de Perfil"
            className="rounded-circle shadow mb-4"
            style={{ width: "150px" }} />
          
          <h5 className="fw-bold mb-3 text-danger">Información Personal</h5>
          <ul className="list-group list-group-flush text-start">
            <li className="list-group-item d-flex justify-content-between"><strong>Nombre:</strong> <span>George Sanchez</span></li>
            <li className="list-group-item d-flex justify-content-between"><strong>Edad:</strong> <span>17</span></li>
            <li className="list-group-item d-flex justify-content-between"><strong>Documento:</strong> <span>1029220893</span></li>
            <li className="list-group-item d-flex justify-content-between"><strong>Contacto:</strong> <span>3114792068</span></li>
          </ul>

          <h5 className="fw-bold mt-4 mb-3 text-danger">Información Deportiva</h5>
          <ul className="list-group list-group-flush text-start">
            <li className="list-group-item d-flex justify-content-between"><strong>Categoría:</strong> <span>2007</span></li>
            <li className="list-group-item d-flex justify-content-between"><strong>Dorsal:</strong> <span>10</span></li>
            <li className="list-group-item d-flex justify-content-between"><strong>Posición:</strong> <span>DC</span></li>
          </ul>
        </div>
      </div>
    </div>

    {/* Columna derecha */}
    <div className="col-md-6">
      <div className="card shadow-sm rounded-3 h-100">
        <div className="card-body">
          <h3 className="text-center fw-semibold mb-4">Temporada 24/25 - Estadísticas Básicas</h3>
          <ul className="list-group list-group-flush mb-4">
            <li className="list-group-item d-flex justify-content-between"><span className="fw-semibold text-danger">⚽ Goles:</span> <span>10</span></li>
            <li className="list-group-item d-flex justify-content-between"><span className="fw-semibold text-danger">🎯 Asistencias:</span> <span>24</span></li>
            <li className="list-group-item d-flex justify-content-between"><span className="fw-semibold text-danger">📋 Partidos:</span> <span>20</span></li>
            <li className="list-group-item d-flex justify-content-between"><span className="fw-semibold text-danger">⏱️ Minutos:</span> <span>1750</span></li>
          </ul>

          <h4 className="text-center fw-semibold mb-4">Estadísticas Detalladas</h4>
          <ul className="list-group list-group-flush">
            <li className="list-group-item d-flex justify-content-between"><span className="text-danger">⚽ Goles de Cabeza</span> <span>2</span></li>
            <li className="list-group-item d-flex justify-content-between"><span className="text-danger">📊 Goles por Partido</span> <span>0,51</span></li>
            <li className="list-group-item d-flex justify-content-between"><span className="text-danger">🎯 Tiros a puerta</span> <span>12</span></li>
            <li className="list-group-item d-flex justify-content-between"><span className="text-danger">🚩 Fueras de Juego</span> <span>20</span></li>
            <li className="list-group-item d-flex justify-content-between"><span className="text-danger">🟨 Tarjetas Amarillas</span> <span>2</span></li>
            <li className="list-group-item d-flex justify-content-between"><span className="text-danger">🟥 Tarjetas Rojas</span> <span>0</span></li>
            <li className="list-group-item d-flex justify-content-between"><span className="text-danger">🧤 Arco en cero</span> <span>0</span></li>
          </ul>
        </div>
      </div>
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
            <p className="text-center mb-0 small">© 2025 SCORD | Escuela de Fútbol Quilmes | Todos los derechos reservados
            </p>
          </div>
        </footer>
      </div>
);
};

export default EstJugador;