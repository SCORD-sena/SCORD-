import React from "react";
import NavbarJugador from "../../componentes/NavbarJugador";

const CrJugador = () =>{
    return (
        <div>
  <meta charSet="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Cronograma - SCORD</title>
  <link rel="stylesheet" href="Css/InicioEntrenador.css" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" />
  <header className="header bg-white shadow-sm py-3">
    <nav className="navbar container d-flex align-items-center justify-content-between flex-wrap">
      {/* Logo y título */}
      <div className="d-flex align-items-center">
        <img src="./Img/logo.jpg" alt="Logo SCORD" className="me-2" style={{height: '50px'}} />
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
  {/* Contenido */}
  <main className="container my-5">
    <h1 className="text-center text-danger mb-4">Calendario de Actividades</h1>
    {/* Entrenamientos */}
    <section className="mb-5">
      <h2 className="mb-3">Entrenamientos Programados</h2>
      <div className="table-responsive">
        <table className="table table-bordered table-striped">
          <thead className="table-danger">
            <tr>
              <th>Día</th>
              <th>Hora</th>
              <th>Fecha</th>
              <th>Categoría</th>
              <th>Sede</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Lunes</td>
              <td>4:00pm - 6:00pm</td>
              <td>10/05/2025</td>
              <td>2007</td>
              <td>Cayetano Cañizares</td>
            </tr>
            <tr>
              <td>Miércoles</td>
              <td>4:00pm - 6:00pm</td>
              <td>12/05/2025</td>
              <td>2007</td>
              <td>Timiza</td>
            </tr>
            <tr>
              <td>Viernes</td>
              <td>4:00pm - 6:00pm</td>
              <td>14/05/2025</td>
              <td>2007</td>
              <td>Timiza</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
    {/* Partidos */}
    <section className="mb-5">
      <h2 className="mb-3">Partidos Programados</h2>
      <div className="table-responsive">
        <table className="table table-bordered table-striped">
          <thead className="table-danger">
            <tr>
              <th>Fecha</th>
              <th>Hora</th>
              <th>Equipo Rival</th>
              <th>Categoría</th>
              <th>Ubicación</th>
              <th>Cancha</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>22/03/2025</td>
              <td>10:00 am</td>
              <td>Invictus FC</td>
              <td>2007</td>
              <td>Xcoli</td>
              <td>2</td>
            </tr>
            <tr>
              <td>06/04/2025</td>
              <td>8:00 am</td>
              <td>Onceno Capitalino</td>
              <td>2007</td>
              <td>La Morena</td>
              <td>10</td>
            </tr>
            <tr>
              <td>13/04/2025</td>
              <td>2:00 pm</td>
              <td>Santa Fe-C</td>
              <td>2007</td>
              <td>La Conejera</td>
              <td>10</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
    {/* Torneos */}
    <section className="mb-5 text-center">
      <h2 className="text-danger">Torneos Activos Categoría (2007)</h2>
      <div className="row mt-4">
        <div className="col-md-6 mb-3">
          <h4>Liga Bogotá</h4>
          <img src="/Img/Imagen Liga Bogota.png" alt="Liga Bogotá" className="img-fluid rounded shadow" />
        </div>
        <div className="col-md-6 mb-3">
          <h4>Copa Metropolitana</h4>
          <img src="/Img/Metropolitana.png" alt="Copa Metropolitana" className="img-fluid rounded shadow" />
        </div>
      </div>
    </section>
  </main>
  {/* Footer */}
  <footer className="bg-dark text-white py-4">
    <div className="container">
      <div className="row text-center text-md-start">
        <div className="col-md-6 mb-3">
          <h5 className="text-danger">SCORD</h5>
          <p>Sistema de control y organización deportiva</p>
        </div>
        <div className="col-md-6 mb-3">
          <h5 className="text-danger">Escuela Fénix</h5>
          <p>Formando talentos para el futuro</p>
        </div>
      </div>
      <hr className="border-light" />
      <p className="text-center small mb-0">© 2025 SCORD | Escuela de Fútbol Fénix | Todos los derechos
        reservados</p>
    </div>
  </footer>
  {/* JS Bootstrap */}
</div>

);
};
export default CrJugador;
