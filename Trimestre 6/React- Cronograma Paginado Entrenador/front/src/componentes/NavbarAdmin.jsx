import React from "react";
import { Link } from "react-router-dom";

function NavbarAdmin() {
  return (
    <ul className="ul_links nav flex-md-row flex-column">
      <li className="nav-item">
        <Link to="/InicioAdmin" className="nav-link">
          Inicio
        </Link>
      </li>
      <li className="nav-item">
        <Link to="/CrEntrenadorAdmin" className="nav-link">
          Cronograma 
        </Link>
      </li>
      <li className="nav-item">
        <Link to="/PerfilJugadorAdmin" className="nav-link">
          Perfil Jugador
        </Link>
      </li>
      <li className="nav-item">
        <Link to="/EstadisticasJugador" className="nav-link">
          Estadisticas Jugadores
        </Link>
      </li>
      <li className="nav-item">
        <Link to="/PerfilEntrenadorAdmin" className="nav-link">
          Perfil Entrenador
        </Link>
      </li>
      <li className="nav-item">
        <Link to="/EstJugadorAdmin" className="nav-link">
          Evaluar Jugadores
        </Link>
      </li>
      {/*  Agregar la vista de agregar un jugador
      <li className="nav-item">
        <Link to="/AgregarJugador" className="nav-link">
          Agregar Usuario
        </Link>
      </li>
       */}
      
      <li className="nav-item">
        <Link to="/CerrarSesion" className="nav-link btn btn-outline-danger btn-sm">
          Cerrar Sesión
        </Link>
      </li>
    </ul>
  );
}

export default NavbarAdmin;
