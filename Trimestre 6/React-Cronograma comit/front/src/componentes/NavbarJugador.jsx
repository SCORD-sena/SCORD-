import React from "react";
import { Link } from "react-router-dom";

function NavbarJugador() {
  return (
    <ul className="ul_links nav flex-md-row flex-column">
      <li className="nav-item">
        <Link to="/InicioJugador" className="nav-link">
          Inicio
        </Link>
      </li>
      <li className="nav-item">
        <Link to="/CrJugador" className="nav-link">
          Cronograma
        </Link>
      </li>
      <li className="nav-item">
        <Link to="/EqJugador" className="nav-link">
          Pizarra Táctica
        </Link>
      </li>
      <li className="nav-item">
        <Link to="/JugEstadisticas" className="nav-link">
          Estadísticas
        </Link>
      </li>
      <li className="nav-item">
        <Link to="/CerrarSesion" className="nav-link btn btn-outline-danger btn-sm">
          Cerrar Sesión
        </Link>
      </li>
    </ul>
  );
}

export default NavbarJugador;
