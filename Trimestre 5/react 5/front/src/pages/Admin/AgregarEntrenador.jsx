import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import api from "../../config/axiosConfig";
import Swal from "sweetalert2";
import NavbarAdmin from "../../componentes/NavbarAdmin";

const AgregarEntrenador = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [categorias, setCategorias] = useState([]);
  const [tiposDocumento, setTiposDocumento] = useState([]);

  useEffect(() => {
    cargarDatos();
  }, []);

  const cargarDatos = async () => {
    try {
      const token = localStorage.getItem('token');
      if (!token) {
        Swal.fire({
          icon: "warning",
          title: "No autenticado",
          text: "Debes iniciar sesión primero",
          confirmButtonColor: "#e63946",
        }).then(() => {
          navigate('/login');
        });
        return;
      }

      const [categoriasRes, tiposDocRes] = await Promise.all([
        api.get("/categorias"),
        api.get("/tiposdedocumentos")
      ]);
      
      console.log("Categorías cargadas:", categoriasRes.data);
      console.log("Tipos de documento:", tiposDocRes.data);
      
      setCategorias(categoriasRes.data);
      setTiposDocumento(tiposDocRes.data);
    } catch (err) {
      console.error("Error cargando datos:", err);
      
      let errorMsg = "No se pudieron cargar las categorías o tipos de documento";
      
      if (err.response?.status === 401) {
        errorMsg = "Sesión expirada. Por favor, inicia sesión nuevamente.";
        localStorage.removeItem('token');
        navigate('/login');
        return;
      } else if (err.response?.status === 500) {
        errorMsg = "Error en el servidor. Contacta al administrador.";
      }
      
      Swal.fire({
        icon: "error",
        title: "Error al cargar datos",
        text: errorMsg,
        confirmButtonColor: "#e63946",
      });
    }
  };

  const crearEntrenador = async (e) => {
    e.preventDefault();
    const form = e.target;
    const data = new FormData(form);
    const values = Object.fromEntries(data.entries());

    console.log("Valores del formulario:", values);

    if (!validarFormulario(values)) return;

    // Obtener categorías seleccionadas
    const selectCategorias = document.getElementById('categorias');
    const categoriasSeleccionadas = Array.from(selectCategorias.selectedOptions).map(opt => parseInt(opt.value));

    if (categoriasSeleccionadas.length === 0) {
      Swal.fire({
        icon: "warning",
        title: "Categorías requeridas",
        text: "Debes seleccionar al menos una categoría.",
        confirmButtonColor: "#d33",
      });
      return;
    }

    const result = await Swal.fire({
      title: "¿Estás Seguro?",
      html: `
        <b>Documento:</b> ${values.numeroDocumento} <br/>
        <b>Nombre:</b> ${values.primerNombre} ${values.segundoNombre || ""} ${values.primerApellido} <br/>
        <b>Teléfono:</b> ${values.telefono} <br/>
        <b>Correo:</b> ${values.correo} <br/>
        <b>Cargo:</b> ${values.cargo} <br/>
        <b>Años de Experiencia:</b> ${values.anosExperiencia}
      `,
      icon: "question",
      showCancelButton: true,
      confirmButtonText: "Sí, crear",
      cancelButtonText: "Cancelar",
      confirmButtonColor: "#28a745",
      cancelButtonColor: "#d33",
    });

    if (!result.isConfirmed) return;

    setLoading(true);

    try {
      // PASO 1: Crear la persona
      const personaData = {
        NumeroDeDocumento: values.numeroDocumento,
        Nombre1: values.primerNombre,
        Nombre2: values.segundoNombre || null,
        Apellido1: values.primerApellido,
        Apellido2: values.segundoApellido || null,
        correo: values.correo,
        contrasena: values.contrasena,
        contrasena_confirmation: values.contrasena,
        FechaDeNacimiento: values.fechaNacimiento,
        Genero: values.genero,
        Telefono: values.telefono,
        Direccion: values.direccion,
        EpsSisben: values.epsSisben || null,
        idTiposDeDocumentos: parseInt(values.idTiposDeDocumentos),
        idRoles: 2 // Rol de entrenador
      };

      console.log("Enviando persona:", personaData);
      const personaRes = await api.post("/personas", personaData);
      
      console.log("📦 Respuesta COMPLETA del backend:", JSON.stringify(personaRes.data, null, 2));
      
      let idPersonas;
      
      if (personaRes.data && personaRes.data.data && personaRes.data.data.idPersonas) {
        idPersonas = personaRes.data.data.idPersonas;
        console.log("✅ idPersonas extraído de personaRes.data.data.idPersonas:", idPersonas);
      } else if (personaRes.data && personaRes.data.idPersonas) {
        idPersonas = personaRes.data.idPersonas;
        console.log("✅ idPersonas extraído de personaRes.data.idPersonas:", idPersonas);
      } else {
        console.error("❌ Estructura de respuesta inesperada:", personaRes.data);
        throw new Error("No se pudo obtener el ID de la persona creada");
      }
      
      console.log("🎯 idPersonas FINAL extraído:", idPersonas);
      
      if (!idPersonas) {
        throw new Error("No se pudo obtener el ID de la persona creada");
      }

      // PASO 2: Crear el entrenador
      const entrenadorData = {
        idPersonas: idPersonas,
        AnosDeExperiencia: parseInt(values.anosExperiencia),
        Cargo: values.cargo,
        categorias: categoriasSeleccionadas
      };

      console.log("Enviando entrenador:", entrenadorData);
      const entrenadorRes = await api.post("/entrenadores", entrenadorData);
      console.log("📦 Respuesta de entrenador:", entrenadorRes.data);

      await Swal.fire({
        icon: "success",
        title: "¡Entrenador creado!",
        text: "El entrenador se creó correctamente.",
        confirmButtonColor: "#28a745",
      });

      form.reset();
      navigate("/PerfilEntrenadorAdmin");

    } catch (err) {
      console.error("Error creando entrenador:", err);
      console.error("Detalles del error:", err.response?.data);
      
      let errorMsg = "No se pudo crear el entrenador";
      
      if (err.response?.status === 401) {
        errorMsg = "Sesión expirada. Por favor, inicia sesión nuevamente.";
        localStorage.removeItem('token');
        navigate('/login');
        return;
      } else if (err.response?.data?.errors) {
        const errors = err.response.data.errors;
        
        if (errors.NumeroDeDocumento) {
          errorMsg = "El número de documento ya está registrado en el sistema.";
        } else if (errors.correo) {
          errorMsg = "El correo electrónico ya está registrado en el sistema.";
        } else {
          errorMsg = Object.values(errors).flat().join("\n");
        }
      } else if (err.response?.data?.message) {
        errorMsg = err.response.data.message;
      } else if (err.message) {
        errorMsg = err.message;
      }

      Swal.fire({
        icon: "error",
        title: "Error",
        text: errorMsg,
        confirmButtonColor: "#e63946",
      });
    } finally {
      setLoading(false);
    }
  };

  const validarFormulario = (values) => {
    const camposRequeridos = [
      { campo: 'numeroDocumento', nombre: 'Número de Documento' },
      { campo: 'idTiposDeDocumentos', nombre: 'Tipo de Documento' },
      { campo: 'primerNombre', nombre: 'Primer Nombre' },
      { campo: 'primerApellido', nombre: 'Primer Apellido' },
      { campo: 'genero', nombre: 'Género' },
      { campo: 'telefono', nombre: 'Teléfono' },
      { campo: 'direccion', nombre: 'Dirección' },
      { campo: 'fechaNacimiento', nombre: 'Fecha de Nacimiento' },
      { campo: 'correo', nombre: 'Correo' },
      { campo: 'contrasena', nombre: 'Contraseña' },
      { campo: 'anosExperiencia', nombre: 'Años de Experiencia' },
      { campo: 'cargo', nombre: 'Cargo' }
    ];

    for (const { campo, nombre } of camposRequeridos) {
      if (!values[campo] || values[campo].toString().trim() === '') {
        Swal.fire({
          icon: "warning",
          title: "Campo vacío",
          text: `El campo "${nombre}" es obligatorio.`,
          confirmButtonColor: "#d33",
        });
        return false;
      }
    }

    const telRegex = /^3\d{9}$/;
    if (!telRegex.test(values.telefono)) {
      Swal.fire({
        icon: "error",
        title: "Teléfono inválido",
        text: "El teléfono debe iniciar con 3 y tener 10 dígitos.",
        confirmButtonColor: "#d33",
      });
      return false;
    }

    if (!/\S+@\S+\.\S+/.test(values.correo)) {
      Swal.fire({
        icon: "error",
        title: "Correo inválido",
        text: "Ingresa un correo válido.",
        confirmButtonColor: "#d33",
      });
      return false;
    }

    if (values.contrasena.length < 8 || values.contrasena.length > 12) {
      Swal.fire({
        icon: "error",
        title: "Contraseña inválida",
        text: "La contraseña debe tener entre 8 y 12 caracteres.",
        confirmButtonColor: "#d33",
      });
      return false;
    }

    const anos = parseInt(values.anosExperiencia);
    if (isNaN(anos) || anos < 0 || anos > 50) {
      Swal.fire({
        icon: "error",
        title: "Años de experiencia inválidos",
        text: "Los años de experiencia deben estar entre 0 y 50.",
        confirmButtonColor: "#d33",
      });
      return false;
    }

    return true;
  };

  return (
    <div>
      <meta charSet="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Agregar Entrenador - SCORD</title>
      <link
        href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css"
        rel="stylesheet"
      />
      <link rel="stylesheet" href="Css/InicioJugador.css" />

      <header className="header bg-white shadow-sm py-3">
        <nav className="navbar container d-flex align-items-center justify-content-between flex-wrap">
          <div className="d-flex align-items-center">
            <img src="/Img/SCORD.png" alt="Logo SCORD" className="me-2" style={{ height: "60px" }} />
            <h4 className="mb-0 text-danger fw-bold">SCORD</h4>
          </div>
          <input className="menu_hamburguesa d-none" type="checkbox" id="menu_hamburguesa" />
          <NavbarAdmin />
        </nav>
      </header>

      <main className="container my-5">
        <div className="text-center mb-4">
          <h1 className="text-danger">Agregar Entrenador</h1>
        </div>

        <div className="container mt-4">
          <form onSubmit={crearEntrenador}>
            <div className="row">
              <div className="col-md-6">
                <h5 className="text-danger mb-3">Datos Personales</h5>
                
                <div className="mb-3">
                  <label htmlFor="numeroDocumento" className="form-label">Número de Documento *</label>
                  <input type="text" id="numeroDocumento" name="numeroDocumento" className="form-control" required />
                </div>

                <div className="mb-3">
                  <label htmlFor="idTiposDeDocumentos" className="form-label">Tipo de Documento *</label>
                  <select id="idTiposDeDocumentos" name="idTiposDeDocumentos" className="form-select" required>
                    <option value="">Seleccionar</option>
                    {tiposDocumento.map((tipo) => (
                      <option key={tipo.idTiposDeDocumentos} value={tipo.idTiposDeDocumentos}>
                        {tipo.Descripcion}
                      </option>
                    ))}
                  </select>
                </div>

                <div className="mb-3">
                  <label htmlFor="primerNombre" className="form-label">Primer Nombre *</label>
                  <input type="text" id="primerNombre" name="primerNombre" className="form-control" required />
                </div>

                <div className="mb-3">
                  <label htmlFor="segundoNombre" className="form-label">Segundo Nombre</label>
                  <input type="text" id="segundoNombre" name="segundoNombre" className="form-control" />
                </div>

                <div className="mb-3">
                  <label htmlFor="primerApellido" className="form-label">Primer Apellido *</label>
                  <input type="text" id="primerApellido" name="primerApellido" className="form-control" required />
                </div>

                <div className="mb-3">
                  <label htmlFor="segundoApellido" className="form-label">Segundo Apellido</label>
                  <input type="text" id="segundoApellido" name="segundoApellido" className="form-control" />
                </div>

                <div className="mb-3">
                  <label htmlFor="genero" className="form-label">Género *</label>
                  <select id="genero" name="genero" className="form-select" required>
                    <option value="">Seleccionar</option>
                    <option value="M">Masculino</option>
                    <option value="F">Femenino</option>
                  </select>
                </div>

                <div className="mb-3">
                  <label htmlFor="fechaNacimiento" className="form-label">Fecha de Nacimiento *</label>
                  <input type="date" id="fechaNacimiento" name="fechaNacimiento" className="form-control" required />
                </div>
              </div>

              <div className="col-md-6">
                <h5 className="text-danger mb-3">Datos de Contacto</h5>

                <div className="mb-3">
                  <label htmlFor="telefono" className="form-label">Teléfono *</label>
                  <input type="tel" id="telefono" name="telefono" className="form-control" placeholder="3XXXXXXXXX" required />
                </div>

                <div className="mb-3">
                  <label htmlFor="direccion" className="form-label">Dirección *</label>
                  <input type="text" id="direccion" name="direccion" className="form-control" required />
                </div>

                <div className="mb-3">
                  <label htmlFor="correo" className="form-label">Correo Electrónico *</label>
                  <input type="email" id="correo" name="correo" className="form-control" placeholder="ejemplo@correo.com" required />
                </div>

                <div className="mb-3">
                  <label htmlFor="contrasena" className="form-label">Contraseña *</label>
                  <input type="password" id="contrasena" name="contrasena" className="form-control" required />
                  <small className="form-text text-muted">8–12 caracteres</small>
                </div>

                <div className="mb-3">
                  <label htmlFor="epsSisben" className="form-label">EPS/Sisben</label>
                  <input type="text" id="epsSisben" name="epsSisben" className="form-control" />
                </div>
              </div>

              <div className="col-12">
                <hr />
                <h5 className="text-danger">Información Deportiva</h5>
                <div className="row">
                  <div className="col-md-6">
                    <div className="mb-3">
                      <label htmlFor="anosExperiencia" className="form-label">Años de Experiencia *</label>
                      <input type="number" id="anosExperiencia" name="anosExperiencia" className="form-control" min="0" max="50" required />
                    </div>

                    <div className="mb-3">
                      <label htmlFor="cargo" className="form-label">Cargo *</label>
                      <input type="text" id="cargo" name="cargo" className="form-control" required />
                    </div>
                  </div>

                  <div className="col-md-6">
                    <div className="mb-3">
                      <label htmlFor="categorias" className="form-label">Categorías * (Mantén Ctrl para seleccionar múltiples)</label>
                      <select 
                        multiple 
                        id="categorias" 
                        name="categorias" 
                        className="form-select" 
                        style={{ height: "150px" }}
                        required
                      >
                        {categorias.map((cat) => (
                          <option key={cat.idCategorias} value={cat.idCategorias}>
                            {cat.Descripcion}
                          </option>
                        ))}
                      </select>
                      <small className="form-text text-muted">
                        Presiona Ctrl (o Cmd en Mac) y haz clic para seleccionar varias categorías
                      </small>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="mt-4 d-flex justify-content-end gap-2">
              <button type="submit" className="btn btn-success" disabled={loading}>
                {loading ? "Guardando..." : "Guardar"}
              </button>
              <button 
                type="button" 
                className="btn btn-danger" 
                onClick={() => navigate("/PerfilEntrenadorAdmin")}
                disabled={loading}
              >
                Cancelar
              </button>
            </div>
          </form>
        </div>
      </main>

      <footer className="bg-dark text-white py-4">
        <div className="container">
          <div className="row text-center text-md-start justify-content-center">
            <div className="col-md-4 mb-1">
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

export default AgregarEntrenador;