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
      <li className="nav-item">
        <Link to="/CompetenciasAdmin" className="nav-link">
          competencias
        </Link>
      </li>
       
      <li className="nav-item">
        <Link to="/ResultadosAdmin" className="nav-link">
          Resultados
        </Link>
      </li>

      {/* ✅ NUEVO ITEM - HISTORIAL */}
      <li className="nav-item">
        <Link to="/HistorialAdmin" className="nav-link">
          <i className="bi bi-clock-history me-1"></i> Historial
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

export default NavbarAdmin;