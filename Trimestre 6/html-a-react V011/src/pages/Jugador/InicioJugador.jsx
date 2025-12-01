import React from "react";
import NavbarJugador from "../../componentes/NavbarJugador";

const InicioJugador = () =>{
    return (
        <div>
  <meta charSet="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Perfil Jugador - SCORD</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link rel="stylesheet" href="Css/InicioEntrenador.css" />
  <header className="header bg-white shadow-sm py-3">
    <nav className="navbar container d-flex align-items-center justify-content-between flex-wrap">
      {/* Logo y título */}
      <div className="d-flex align-items-center">
        <img src="/Img/logo.jpg" alt="Logo SCORD" className="me-2" style={{height: '50px'}} />
        <h4 className="mb-0 text-danger fw-bold">SCORD</h4>
      </div>
      {/* Checkbox oculto */}
      <input className="menu_hamburguesa d-none" type="checkbox" id="menu_hamburguesa" />
      {/* Menu de navegación importado */}
            <NavbarJugador /></nav>
  </header>
  <main className="container my-5">
    <div className="row g-5">
      {/* Información personal y deportiva */}
      <div className="col-md-6">
        <section className="text-center mb-4">
          <h2 className="fw-semibold">Bienvenido(a), <span className="fw-bold">George Sanchez</span></h2>
          <img src="/img/FotoPerfil.png" alt="Foto de Perfil" className="rounded-circle shadow mb-4" style={{width: '150px'}} />
          <ul className="list-group list-group-flush shadow-sm rounded-3">
            <li className="list-group-item d-flex justify-content-between"><strong>Nombre:</strong> <span>George
                Sanchez</span></li>
            <li className="list-group-item d-flex justify-content-between"><strong>Edad:</strong> <span>17</span></li>
            <li className="list-group-item d-flex justify-content-between"><strong>Documento:</strong>
              <span>1029220893</span>
            </li>
            <li className="list-group-item d-flex justify-content-between"><strong>Contacto:</strong>
              <span>3114792068</span>
            </li>
          </ul>
        </section>
        <section>
          <h3 className="text-center fw-semibold mb-4">Información Deportiva</h3>
          <ul className="list-group list-group-flush shadow-sm rounded-3">
            <li className="list-group-item d-flex justify-content-between"><strong>Categoría:</strong> <span>2007</span>
            </li>
            <li className="list-group-item d-flex justify-content-between"><strong>Dorsal:</strong> <span>10</span></li>
            <li className="list-group-item d-flex justify-content-between"><strong>Posición:</strong> <span>DC</span></li>
          </ul>
        </section>
      </div>
      {/* Estadísticas */}
      <div className="col-md-5 mt-auto">
        <section>
          <h3 className="text-center fw-semibold mb-4">Temporada 24/25 - Estadísticas Básicas</h3>
          <ul className="list-group list-group-flush shadow-sm rounded-3 mb-4">
            <li className="list-group-item d-flex justify-content-between"><strong>⚽ Goles:</strong> <span>10</span></li>
            <li className="list-group-item d-flex justify-content-between"><strong>🎯 Asistencias:</strong> <span>24</span>
            </li>
            <li className="list-group-item d-flex justify-content-between"><strong>📋 Partidos:</strong> <span>20</span>
            </li>
            <li className="list-group-item d-flex justify-content-between"><strong>⏱️ Minutos:</strong> <span>1750</span>
            </li>
          </ul>
          <h4 className="text-center fw-semibold mb-3">Estadísticas Detalladas</h4>
          <ul className="list-group list-group-flush shadow-sm rounded-3">
            <li className="list-group-item d-flex justify-content-between"><span className="text-danger">⚽ Goles de
                Cabeza</span> <span>2</span></li>
            <li className="list-group-item d-flex justify-content-between"><span className="text-danger">📊 Goles por
                Partido</span> <span>0,51</span></li>
            <li className="list-group-item d-flex justify-content-between"><span className="text-danger">🎯 Tiros a
                puerta</span> <span>12</span></li>
            <li className="list-group-item d-flex justify-content-between"><span className="text-danger">🚩 Fueras de
                Juego</span> <span>20</span></li>
            <li className="list-group-item d-flex justify-content-between"><span className="text-danger">🟨 Tarjetas
                Amarillas</span> <span>2</span></li>
            <li className="list-group-item d-flex justify-content-between"><span className="text-danger">🟥 Tarjetas
                Rojas</span> <span>0</span></li>
            <li className="list-group-item d-flex justify-content-between"><span className="text-danger">🧤 Arco en cero</span>
              <span>0</span>
            </li>
          </ul>
        </section>
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
      <p className="text-center mb-0 small">© 2025 SCORD | Escuela de Fútbol Quilmes | Todos los derechos reservados
      </p>
    </div>
  </footer>
</div>
);
};
export default InicioJugador;