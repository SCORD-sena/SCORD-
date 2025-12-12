import React from "react";
import NavbarEntrenador from "../../componentes/NavbarEntrenador";

const Estadisticas = () =>{
    return (
        <div className="d-flex flex-column min-vh-100">
  <meta charSet="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Registro de Estadísticas - SCORD</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link rel="stylesheet" href="/Css/InicioEntrenador.css" />
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
            <NavbarEntrenador /></nav>
  </header>
  {/* MAIN */}
  <main className="container my-5">
    <h2 className="text-center text-danger mb-4">Registrar Estadísticas del Partido (2007)</h2>
    <form className="shadow p-4 rounded bg-light">
      <div className="row g-3 mb-4">
        <div className="col-md-6">
          <label htmlFor="partido" className="form-label fw-semibold">Partido</label>
          <select id="partido" className="form-select" required>
            <option selected disabled>Selecciona un partido</option>
            <option value={1}>vs Golden Score - 10/05/2025</option>
            <option value={2}>vs Real Carvajal - 14/05/2025</option>
            <option value={3}>vs Millonarios C - 20/05/2025</option>
          </select>
        </div>
        <div className="col-md-6">
          <label htmlFor="jugador" className="form-label fw-semibold">Jugador</label>
          <select id="jugador" className="form-select" required>
            <option selected disabled>Selecciona un jugador</option>
            <option>George Sánchez</option>
            <option>Carlos Martínez</option>
            <option>Juan Pérez</option>
          </select>
        </div>
      </div>
      {/*RELLENAR ESTADÍSTICAS DEL JUGADOR!*/}
      <div className="row g-3">
        <div className="col-md-4">
          <label className="form-label">Goles</label>
          <input type="number" className="form-control" min={0} defaultValue={0} />
        </div>
        <div className="col-md-4">
          <label className="form-label">Goles de Cabeza</label>
          <input type="number" className="form-control" min={0} defaultValue={0} />
        </div>
        <div className="col-md-4">
          <label className="form-label">Asistencias</label>
          <input type="number" className="form-control" min={0} defaultValue={0} />
        </div>
        <div className="col-md-4">
          <label className="form-label">Minutos Jugados</label>
          <input type="number" className="form-control" min={0} max={90} defaultValue={0} />
        </div>
        <div className="col-md-4">
          <label className="form-label">Tiros a Puerta</label>
          <input type="number" className="form-control" min={0} defaultValue={0} />
        </div>
        <div className="col-md-4">
          <label className="form-label">Fueras de Juego</label>
          <input type="number" className="form-control" min={0} defaultValue={0} />
        </div>
        <div className="col-md-4">
          <label className="form-label">Tarjetas Amarillas</label>
          <input type="number" className="form-control" min={0} max={2} defaultValue={0} />
        </div>
        <div className="col-md-4">
          <label className="form-label">Tarjetas Rojas</label>
          <input type="number" className="form-control" min={0} max={1} defaultValue={0} />
        </div>
      </div>
      <div className="text-center mt-4">
        <button type="submit" className="btn btn-danger px-4">Guardar Estadísticas</button>
      </div>
    </form> 
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
      <p className="text-center mb-0 small">© 2025 SCORD | Escuela de Fútbol Quilmes | Todos los derechos reservados</p>
    </div>
  </footer>
</div>

    );
};
export default Estadisticas;