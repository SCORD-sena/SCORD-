import React from "react";
import { Link } from "react-router-dom";
import Swal from "sweetalert2";
import { useNavigate } from "react-router-dom";

const Login = () => {
  const [correo, setCorreo] = React.useState("");
  const [password, setPassword] = React.useState("");
  const [showPassword, setShowPassword] = React.useState(false);
  const navigate = useNavigate();
  const handleLogin = async (e) => {
    e.preventDefault();
    if(!correo || !password) {
      Swal.fire({
        icon: 'warning',
        title: 'Campos Incompletos',
        text: 'Por favor ingresa tu correo y contraseña.',
        confirmButtonColor: "#28a745"
      });
      return;
    }

    if (!correo.includes("@")){
      Swal.fire({
        icon: 'error',
        title: 'Correo invalido',
        text: "El correo debe tener un formato valido (ejemplo@correo.com).",
    });
      return;
    }
    //validacion de caracteres de la contraseña
    if (password.length <8){
      Swal.fire({
       icon: 'info',
        title: 'Contraseña invalida',
        text: "La contraseña debe tener entre 8 y 12 caracteres.",
    });
      return;
    } 

    if (password.length >12){
      Swal.fire({
       icon: 'info',
        title: 'Contraseña invalida',
        text: "La contraseña debe tener entre 8 y 12 caracteres.",
    });
      return;
    } 

    const regex = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]+$/;

      if (!regex.test(password)) {
        Swal.fire({
        icon: "error",
        title: "Contraseña inválida",
        text: "La contraseña debe contener letras y números (solo caracteres alfanuméricos).",
      });
    return;
    }

    // Si pasa todas las validaciones
    Swal.fire({
      icon: "success",
      title: "¡Bienvenido!",
      text: "Inicio de sesión exitoso.",
      timer: 1500,
      showConfirmButton: false,
    });

    //redireccionar a la pagina de inicio
    setTimeout(() => {
      navigate("/InicioAdmin");
    }, 1500);
  }
  return (
    <div className="d-flex flex-column min-vh-100">
      <meta charSet="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Iniciar Sesión - Administrador - SCORD</title>
      {/* Bootstrap */}
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" />
      <link rel="stylesheet" href="Css/Login.css" />
      
      {/* Header SCORD */}
      <header className="bg-white shadow-sm py-3">
        <div className="container d-flex align-items-center">
          <img src="/Img/SCORD.png" 
               alt="Logo SCORD" 
               className="header-logo img-fluid me-3" style={{width:"100px", height: "125px" }} />
          <h1 className="text-danger fw-bold m-0">SCORD</h1>
        </div>
      </header>
      
      {/* Login */}
      <main className="flex-grow-1 d-flex justify-content-center align-items-center py-5">
        <div
          className="login-container bg-white rounded shadow p-4"
          style={{ maxWidth: "500px", width: "100%" }}
        >
          <h2 className="mb-4 text-center">Iniciar Sesión</h2>
          <form onSubmit={handleLogin}>
            <div className="mb-3">
              <label htmlFor="correo" className="form-label fw-semibold">
                Correo
              </label>
              <input
                type="text"
                className="form-control"
                id="correo"
                value={correo}
                onChange={(e) => setCorreo(e.target.value)}
                placeholder="Digite su correo"
                required
              />
            </div>
            <div className="mb-3">
              <label htmlFor="password" className="form-label fw-semibold">
                Contraseña
              </label>
              <input
                type={showPassword ? "text" : "password"}                 className="form-control"
                id="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Digite su contraseña"
                required
              />
 
              <div className="form-check mt-2">
                <input
                  type="checkbox"
                  className="form-check-input"
                  id="show-password"
                  checked={showPassword}
                  onChange={() => setShowPassword(!showPassword)} // 👈 alterna
                />
                <label className="form-check-label" htmlFor="show-password">
                  Mostrar contraseña
                </label>
              </div>
            </div>
            <div className="d-grid gap-2">
              <button type="submit" className="btn btn-danger fw-bold">
                Iniciar Sesión
              </button>
            </div>
            <div className="text-center mt-3">
              <a href="#" className="text-muted text-decoration-none">
                ¿Olvidó su contraseña?
              </a>
            </div>
          </form>
        </div>
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

export default Login;