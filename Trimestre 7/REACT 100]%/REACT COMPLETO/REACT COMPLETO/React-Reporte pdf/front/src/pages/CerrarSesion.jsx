import React, { useEffect } from "react";
import { useNavigate } from "react-router-dom";

const CerrarSesion = () => {
  const navigate = useNavigate();

  useEffect(() => {
    const logout = async () => {
      try {
        const token = localStorage.getItem('token');
        
        console.log('Token encontrado:', token);
        
        if (token) {
          const response = await fetch('http://localhost:8000/api/logout', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${token}`,
              'Accept': 'application/json'
            }
          });
          
          if (response.ok) {
            const data = await response.json();
            console.log('Respuesta del servidor:', data);
          }
        }
      } catch (error) {
        console.error('Error al cerrar sesión:', error);
      } finally {
        localStorage.clear();
        sessionStorage.clear();
        console.log('Sesión destruida completamente');
        
        setTimeout(() => {
          navigate('/Index', { replace: true });
          window.history.pushState(null, '', window.location.href);
          window.onpopstate = () => {
            window.history.pushState(null, '', window.location.href);
          };
        }, 1500);
      }
    };
    
    logout();
  }, [navigate]);

  return (
    <div>
      <meta charSet="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Cerrando sesión - SCORD</title>
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" />
      <link rel="stylesheet" href="/Css/InicioJugador.css" />

      <div className="d-flex flex-column min-vh-100">
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

        <main className="container my-5 text-center flex-grow-1">
          <div className="spinner-border text-danger mb-4" role="status" style={{ width: "3rem", height: "3rem" }}>
            <span className="visually-hidden">Cerrando sesión...</span>
          </div>
          <h1 className="text-danger mb-4">Cerrando sesión...</h1>
          <p className="mb-4 text-muted">
            Gracias por usar SCORD. ¡Te esperamos pronto!
          </p>
          <p className="small text-muted">Redirigiendo al inicio...</p>
        </main>

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
      </div>
    </div>
  );
};

export default CerrarSesion;