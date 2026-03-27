import React from "react";
import NavbarJugador from "../../componentes/NavbarJugador";

const EqJugador = () =>{
    return (
        <div>
  <meta charSet="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Pizarra Táctica - SCORD</title>
  <link rel="stylesheet" href="css/InicioJugador.css" />
  {/* Bootstrap 5.2.3 CDN */}
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" />
  <header className="header bg-white shadow-sm py-3">
    <nav className="navbar container d-flex align-items-center justify-content-between flex-wrap">
      {/* Logo y título */}
      <div className="d-flex align-items-center">
        <img src="/Img/logo.jpg" alt="Logo SCORD" className="me-2" style={{height: '50px'}} />
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
            <NavbarJugador /></nav>
  </header>
  {/* Contenido principal */}
  <main className="flex-grow-1 py-4">
    <div className="container">
      <h1 className="mb-4">Gestión del Equipo</h1>
      {/* Sección en dos columnas */}
      <div className="row">
        {/* Columna izquierda: Formación */}
        <div className="col-md-6 mt-3">
          <h2 className="h4">Formación</h2>
          <h5>4 - 3 - 3 (Ataque)</h5>
          <img src="/Img/Formacion Score.png" alt="Formación táctica" className="img-fluid w-100" />
        </div>
        {/* Columna derecha: Lista de jugadores */}
        <div className="col-md-6 mt-5">
          <h3 className="h5">Jugadores Titulares</h3>
          <ul className="list-group">
            <li className="list-group-item">19. DARWIN MENDOZA REINOSO (POR)</li>
            <li className="list-group-item">14. DANIEL TAPIA (LI)</li>
            <li className="list-group-item">17. OMAR NIÑO LOPEZ (DFC)</li>
            <li className="list-group-item">04. SEBASTIAN CALDERÓN (DFC)</li>
            <li className="list-group-item">13. NICOLAS CANGREJO (LD)</li>
            <li className="list-group-item">10. JUSTIN CHANCI (MC)</li>
            <li className="list-group-item">69. ALEJANDRO BONCES (MC)</li>
            <li className="list-group-item">44. FELIPE RODRIGUEZ (MCO)</li>
            <li className="list-group-item">11. SANTIAGO ACOSTA (ED)</li>
            <li className="list-group-item">09. GEORGE SANCHEZ (DC)</li>
            <li className="list-group-item">17. ILIA TUPURIA (EI)</li>
          </ul>
        </div>
      </div>
    </div>
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
export default EqJugador;