import React from "react";
import { Link } from "react-router-dom";

const CerrarSesion = () => {
  return (
    <div>
  <meta charSet="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Has cerrado sesión - SCORD</title>
  {/* Bootstrap */}
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link rel="stylesheet" href="/Css/InicioJugador.css" />

  <div className="d-flex flex-column min-vh-100">
  {/* Header estilo SCORD */}
<header className="bg-white shadow-sm py-3">
        <div className="container d-flex align-items-center justify-content-between flex-wrap">
          <div className="d-flex align-items-center">
            <img
              src="/Img/logo.jpg"
              alt="Logo"
              className="me-2"
              style={{ height: "50px" }}
            />
            <h4 className="mb-0 text-danger fw-bold">SCORD</h4>
          </div>
        </div>
      </header>
  {/* Contenido principal */}
 <main className="container my-5 text-center flex-grow-1">
        <h1 className="text-danger mb-4">Has cerrado sesión.</h1>
        <p className="mb-4 text-muted">
          Gracias por usar SCORD. ¡Te esperamos pronto!
        </p>
        <Link to="/Index" className="btn btn-danger btn-lg">
          Volver al Inicio
        </Link>
      </main>
  {/* Footer */}
 <footer className="bg-dark text-white py-4 mt-auto">
        <div className="container text-center">
          <div className="row">
            <div className="col-md-6">
              <h5 className="text-danger">SCORD</h5>
              <p>Sistema de control y organización deportiva</p>
            </div>
            <div className="col-md-6">
              <h5 className="text-danger">Escuela Fénix</h5>
              <p>Formando talentos para el futuro</p>
            </div>
          </div>
          <hr className="border-light" />
          <p className="mb-0 small">
            © 2025 SCORD | Escuela de Fútbol Fénix | Todos los derechos reservados
          </p>
        </div>
      </footer>
  {/* Script Bootstrap */}
</div>
</div>

  );
};

export default CerrarSesion;
