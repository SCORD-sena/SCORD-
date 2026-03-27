import React, { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import api from "../config/axiosConfig"; // ✅ Usar la instancia configurada

const Login = () => {
  const navigate = useNavigate();

  // Estados para el formulario
  const [formData, setFormData] = useState({
    correo: "",
    contrasena: "",
  });

  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  // Manejar cambios en los inputs
  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  // Manejar submit del formulario
  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      // ✅ Usar api en lugar de axios directamente
      const response = await api.post("/login", formData);

      if (response.data.success) {
        // Guardar token y datos del usuario
        localStorage.setItem("token", response.data.token);
        localStorage.setItem("user", JSON.stringify(response.data.user));

        console.log("Token guardado:", response.data.token); // 🔍 Debug

        // Redirigir según el rol
        const rolId = response.data.user.Rol.idRoles;

        if (rolId === 1) {
          navigate("/InicioAdmin");
        } else if (rolId === 2) {
          navigate("/InicioEntrenador");
        } else if (rolId === 3) {
          navigate("/InicioJugador");
        } else {
          navigate("/");
        }
      }
    } catch (err) {
      console.error("Error en login:", err);
      if (err.response && err.response.data) {
        setError(err.response.data.message || "Error al iniciar sesión");
      } else {
        setError("Error de conexión. Intente nuevamente.");
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="d-flex flex-column min-vh-100">
      <meta charSet="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Iniciar Sesión - SCORD</title>
      {/* Bootstrap */}
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" />
      <link rel="stylesheet" href="Css/Login.css" />

      {/* Mensaje de error flotante */}
      {error && (
        <div 
          className="alert alert-danger alert-dismissible fade show position-fixed top-0 start-50 translate-middle-x mt-3" 
          role="alert"
          style={{ zIndex: 1050, maxWidth: "500px", width: "90%" }}
        >
          {error}
          <button type="button" className="btn-close" onClick={() => setError("")}></button>
        </div>
      )}

      {/* Header SCORD */}
      <header className="bg-white shadow-sm py-3">
        <div className="container d-flex align-items-center">
          <img src="/Img/logo.jpg" alt="Logo SCORD" className="me-3" style={{ height: "60px" }} />
          <h1 className="text-danger fw-bold m-0">SCORD</h1>
        </div>
      </header>

      {/* Login */}
      <main className="flex-grow-1 d-flex justify-content-center align-items-center py-5">
        <div className="login-container bg-white rounded shadow p-4" style={{ maxWidth: "500px", width: "100%" }}>
          <h2 className="mb-4 text-center">Iniciar Sesión</h2>

          <form onSubmit={handleSubmit}>
            <div className="mb-3">
              <label htmlFor="correo" className="form-label fw-semibold">Correo</label>
              <input
                type="email"
                className="form-control"
                id="correo"
                name="correo"
                placeholder="Digite su correo"
                value={formData.correo}
                onChange={handleChange}
                required
              />
            </div>
            <div className="mb-3">
              <label htmlFor="contrasena" className="form-label fw-semibold">Contraseña</label>
              <input
                type={showPassword ? "text" : "password"}
                className="form-control"
                id="contrasena"
                name="contrasena"
                placeholder="Digite su contraseña"
                value={formData.contrasena}
                onChange={handleChange}
                required
              />
              <div className="form-check mt-2">
                <input
                  type="checkbox"
                  className="form-check-input"
                  id="show-password"
                  checked={showPassword}
                  onChange={(e) => setShowPassword(e.target.checked)}
                />
                <label className="form-check-label" htmlFor="show-password">Mostrar contraseña</label>
              </div>
            </div>
            <div className="d-grid gap-2">
              <button type="submit" className="btn btn-danger fw-bold" disabled={loading}>
                {loading ? "Iniciando sesión..." : "Iniciar Sesión"}
              </button>
            </div>
            <div className="text-center mt-3">
              <a href="#" className="text-muted text-decoration-none">¿Olvidó su contraseña?</a>
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