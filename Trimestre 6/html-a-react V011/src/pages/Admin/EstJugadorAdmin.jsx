
import React from "react";
import NavbarAdmin from "../../componentes/NavbarAdmin";

const EstJugadorAdmin = () => {
    return (
<div>
        <meta charSet="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>Estadísticas SCORD - Admin</title>
        <link rel="stylesheet" href="/Css/InicioJugador.css" />
        {/* Bootstrap 5.2.3 */}
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" />
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

            {/* Menú de enlaces */}
            <NavbarAdmin />
      </nav>
        </header>

        {/* Contenido principal */}
        <main className="container my-5">
          <h2 className="text-center text-danger mb-4">Comparación de Jugadores</h2>
          <p className="text-center mb-4">Compare estadísticas entre jugadores para identificar fortalezas, áreas de mejora y crear estrategias más efectivas.</p>
          
          {/* Selección de jugadores */}
          <div className="row justify-content-center mb-4">
            <div className="col-md-5">
              <label className="form-label fw-semibold">Jugador 1</label>
              <select className="form-select">
                <option selected>Seleccionar jugador...</option>
                <option>George Sanchez</option>
                <option>Juan Pérez</option>
                <option>Miguel Fernández</option>
                <option>Luis Rodríguez</option>
                <option>Diego Sánchez</option>
              </select>
            </div>
            <div className="col-md-5">
              <label className="form-label fw-semibold">Jugador 2</label>
              <select className="form-select">
                <option selected>Seleccionar jugador...</option>
                <option>Carlos Martínez</option>
                <option>Juan Pérez</option>
                <option>Miguel Fernández</option>
                <option>Luis Rodríguez</option>
                <option>Diego Sánchez</option>
              </select>
            </div>
          </div>
    
          {/* Tabla comparativa */}
          <div className="table-responsive">
            <table className="table table-bordered table-striped text-center">
              <thead className="table-danger">
                <tr>
                  <th>Estadística</th>
                  <th>Jugador 1</th>
                  <th>Jugador 2</th>
                  <th>Diferencia</th>
                </tr>
              </thead>
              <tbody>
                <tr><td>🎯 Goles</td><td>10</td><td>25</td><td className="text-danger">-15</td></tr>
                <tr><td>👨‍🦲 Goles de cabeza</td><td>2</td><td>5</td><td className="text-danger">-3</td></tr>
                <tr><td>🤝 Asistencias</td><td>15</td><td>10</td><td className="text-success">+5</td></tr>
                <tr><td>🎯 Tiros a puerta</td><td>24</td><td>10</td><td className="text-success">+14</td></tr>
                <tr><td>🚩 Fueras de juego</td><td>20</td><td>4</td><td className="text-success">+16</td></tr>
                <tr><td>⏱️ Partidos jugados</td><td>20</td><td>38</td><td className="text-danger">-18</td></tr>
                <tr><td>🟨 Tarjetas Amarillas</td><td>2</td><td>4</td><td className="text-warning">-2</td></tr>
                <tr><td>🟥 Tarjetas Rojas</td><td>0</td><td>0</td><td className="text">0</td></tr>
              </tbody>
            </table>
          </div>
        </main>

        {/* Footer */}
        <footer className="bg-dark text-white py-4">
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
            <p className="text-center mb-0 small">© 2025 SCORD | Escuela de Fútbol Quilmes | Todos los derechos reservados</p>
          </div>
        </footer>
      </div>

);
};



export default EstJugadorAdmin;