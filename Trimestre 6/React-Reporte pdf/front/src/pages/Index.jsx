import React from "react";
import { Link } from "react-router-dom";

const Index = () => {
  return (
<div>
  <meta charSet="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>SCORD - Inicio</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link rel="stylesheet" href="/Css/Index.css" />
  
  {/* VIDEO DE FONDO */}
  <video autoPlay muted loop className="bg-video">
    <source src="video/Fondo-red.mp4" type="video/mp4" />
    Tu navegador no soporta el video HTML5.
  </video>
  {/* CAPA DIFUMINADA OSCURA */}
  <div className="overlay" />
  {/* CONTENIDO PRINCIPAL */}
  <div className="d-flex justify-content-center align-items-center vh-100 position-relative z-1">
    <div className="position-relative">
      {/* LOGO FLOTANTE */}
      <img src="img/SCORD.png" alt="Logo SCORD" className="floating-logo img-fluid"  style={{width:"auto", height: "240px" }}/>
      
      {/* CONTENEDOR BLANCO */}
      <div className="bg-white bg-opacity-75 rounded-4 shadow-lg text-center" 
           style={{padding: '4rem 3rem 2rem'}}>
        <h1 className="text-danger fw-bold mb-2">SCORD</h1>
        <p className="fst-italic text-secondary mb-3">
          "Un verdadero amigo te dice en qué fallas, qué mejor amigo que SCORD".
        </p>
        <Link to="/Login" className="btn btn-danger px-4 py-2 rounded-pill fw-bold">
          Iniciar Sesión
        </Link>
      </div>
    </div>
  </div>
  {/* Bootstrap JS */}
</div>
  );
};

export default Index;