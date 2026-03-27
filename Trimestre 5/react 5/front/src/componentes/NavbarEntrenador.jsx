import React from "react";
import { Link } from "react-router-dom";

function NavbarEntrenador() {
  return (
    <ul className="ul_links nav flex-md-row flex-column">
      <li className="nav-item">
        <Link to="/InicioEntrenador" className="nav-link">
          Inicio
        </Link>
      </li>
      <li className="nav-item">
        <Link to="/CrEntrenador" className="nav-link">
          Cronograma 
        </Link>
      </li>
      <li className="nav-item">
        <Link to="/PerfilJugEntre" className="nav-link">
          Perfil de Jugadores
        </Link>
      </li>
      <li className="nav-item">
        <Link to="/EstJugador" className="nav-link">Estadisticas Jugadores</Link>
      </li>
      <li className="nav-item">
        <Link to="/EstJugadorEntrenador" className="nav-link">
          Evaluar Jugadores
        </Link>
      </li>
      <li className="nav-item">
        <Link to="/EqEntrenador" className="nav-link">
          Pizarra Tactica
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

export default NavbarEntrenador;
