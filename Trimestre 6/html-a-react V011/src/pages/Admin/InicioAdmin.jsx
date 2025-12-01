import React from "react";
import NavbarAdmin from "../../componentes/NavbarAdmin";



const InicioAdmin = () => {
  return (
    <div>
        <meta charSet="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Inicio - SCORD</title>
        {/* Bootstrap 5.2.3 */}
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossOrigin="anonymous" />
        <link rel="stylesheet" href="Css/InicioAdmin.css" />

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
            <NavbarAdmin />
      </nav>
        </header>

        {/* Contenido principal */}
        <main className="container my-5">
          {/* Bienvenida + info usuario */}
          <section className="text-center mb-5">
            <h1 className="mb-3">Bienvenido(a), <span className="text-danger">Jose Niño</span></h1>
            <img src="/Img/FotoPerfil.png" alt="Foto de Perfil" className="rounded-circle shadow mb-3" style={{width: '150px'}} />
            <div className="row justify-content-center mt-3">
              <div className="col-md-6">
                <ul className="list-group list-group-flush shadow-sm">
                  <li className="list-group-item d-flex justify-content-between">
                    <strong>Nombre:</strong> <span>Jose David Niño Lopez</span>
                  </li>
                  <li className="list-group-item d-flex justify-content-between">
                    <strong>Edad:</strong> <span>34</span>
                  </li>
                  <li className="list-group-item d-flex justify-content-between">
                    <strong>Genero:</strong> <span>Masculino</span>
                  </li>
                </ul>
              </div>
            </div>
          </section>
          {/* Carrusel de contenido */}
          <section className="mb-5">
            <div id="carouselInfo" className="carousel slide" data-bs-ride="carousel">
              <div className="carousel-inner bg-light rounded shadow" style={{minHeight: '400px'}}>
                {/* Quiénes Somos */}
                <div className="carousel-item active text-center p-5">
                  <h2 className="text-danger mb-4">¿Quiénes Somos?</h2>
                  <p className="mb-4">Somos Fénix, una escuela de fútbol apasionada por la formación deportiva y el desarrollo integral de nuestros jugadores. Ubicados en la 8va localidad de Bogotá, Kennedy, entrenamos en el Parque Timiza...</p>
                  <img src="/Img/Escudo quilmes.jpg" className="rounded shadow" style={{maxWidth: '300px'}} alt="Escudo del equipo" />
                </div>
                {/* Misión */}
                <div className="carousel-item text-center p-5">
                  <h2 className="text-danger mb-4">Misión</h2>
                  <p>En Fénix, nuestra misión es formar futbolistas íntegros, promoviendo valores como el respeto, la disciplina y la perseverancia. A través de entrenamientos de alta calidad y participación en torneos, buscamos potenciar el talento de nuestros jugadores y brindarles oportunidades para crecer tanto en lo deportivo como en lo personal.</p>
                  <img src="/Img/+3.png" className="rounded shadow mt-3" style={{maxWidth: '500px'}} alt="Entrenamiento" />
                </div>
                {/* Visión */}
                <div className="carousel-item text-center p-5">
                  <h2 className="text-danger mb-4">Visión</h2>
                  <p>Nos proyectamos como una de las academias más reconocidas de Bogotá, destacándonos por nuestra excelencia en la formación de jugadores y nuestra contribución al desarrollo social. Aspiramos a ser un referente en el fútbol profesional y personal.</p>
                  <img src="/Img/Niños-Fiesta.jpg" className="rounded shadow mt-3" style={{maxWidth: '500px'}} alt="Entrenamiento" />
                </div>
              </div>
              {/* Controles del carrusel */}
              <button className="carousel-control-prev" type="button" data-bs-target="#carouselInfo" data-bs-slide="prev">
                <span className="carousel-control-prev-icon" />
              </button>
              <button className="carousel-control-next" type="button" data-bs-target="#carouselInfo" data-bs-slide="next">
                <span className="carousel-control-next-icon" />
              </button>
            </div>
          </section>
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
            <p className="text-center mb-0 small">© 2025 SCORD | Escuela de Fútbol Quilmes | Todos los derechos reservados</p>
          </div>
        </footer>
      </div>
  );
};

export default InicioAdmin;