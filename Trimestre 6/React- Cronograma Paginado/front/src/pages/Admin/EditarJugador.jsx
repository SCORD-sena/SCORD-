import React, { useState, useEffect } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import api from "../../config/axiosConfig";
import Swal from "sweetalert2";
import NavbarAdmin from "../../componentes/NavbarAdmin";

const EditarJugador = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const jugadorInicial = location.state?.jugador;

  const [loading, setLoading] = useState(false);
  const [categorias, setCategorias] = useState([]);
  const [tiposDocumento, setTiposDocumento] = useState([]);
  
  // Estados para el formulario
  const [formData, setFormData] = useState({
    // Datos de Persona
    numeroDocumento: "",
    tipoDocumento: "",
    primerNombre: "",
    segundoNombre: "",
    primerApellido: "",
    segundoApellido: "",
    genero: "",
    telefono: "",
    direccion: "",
    fechaNacimiento: "",
    correo: "",
    contrasena: "",
    epsSisben: "",
    // Datos de Jugador
    dorsal: "",
    posicion: "",
    estatura: "",
    upz: "",
    categoria: "",
    nomTutor1: "",
    nomTutor2: "",
    apeTutor1: "",
    apeTutor2: "",
    telefonoTutor: "",
  });

  useEffect(() => {
    if (!jugadorInicial) {
      Swal.fire({
        icon: "warning",
        title: "No hay jugador seleccionado",
        text: "Por favor selecciona un jugador desde el perfil",
        confirmButtonColor: "#e63946",
      }).then(() => {
        navigate("/PerfilJugadorAdmin");
      });
      return;
    }

    cargarDatos();
    cargarDatosJugador();
  }, []);

  const cargarDatos = async () => {
    try {
      const [categoriasRes, tiposDocRes] = await Promise.all([
        api.get("/categorias"),
        api.get("/tiposdedocumentos"),
      ]);
      setCategorias(categoriasRes.data);
      setTiposDocumento(tiposDocRes.data);
    } catch (err) {
      console.error("Error cargando datos:", err);
    }
  };

  const cargarDatosJugador = async () => {
    try {
      // Obtener datos completos del jugador con relaciones
      const res = await api.get(`/jugadores/${jugadorInicial.idJugadores}`);
      const jugador = res.data;
      const persona = jugador.persona;

      // Pre-llenar el formulario
      setFormData({
        numeroDocumento: persona.NumeroDeDocumento || "",
        tipoDocumento: persona.idTiposDeDocumentos || "",
        primerNombre: persona.Nombre1 || "",
        segundoNombre: persona.Nombre2 || "",
        primerApellido: persona.Apellido1 || "",
        segundoApellido: persona.Apellido2 || "",
        genero: persona.Genero || "",
        telefono: persona.Telefono || "",
        direccion: persona.Direccion || "",
        fechaNacimiento: persona.FechaDeNacimiento || "",
        correo: persona.correo || "",
        contrasena: "", // No mostramos la contraseña por seguridad
        epsSisben: persona.EpsSisben || "",
        dorsal: jugador.Dorsal || "",
        posicion: jugador.Posicion || "",
        estatura: jugador.Estatura || "",
        upz: jugador.Upz || "",
        categoria: jugador.idCategorias || "",
        nomTutor1: jugador.NomTutor1 || "",
        nomTutor2: jugador.NomTutor2 || "",
        apeTutor1: jugador.ApeTutor1 || "",
        apeTutor2: jugador.ApeTutor2 || "",
        telefonoTutor: jugador.TelefonoTutor || "",
      });
    } catch (err) {
      console.error("Error cargando jugador:", err);
      Swal.fire({
        icon: "error",
        title: "Error",
        text: "No se pudieron cargar los datos del jugador",
        confirmButtonColor: "#e63946",
      });
    }
  };

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const actualizarJugador = async (e) => {
    e.preventDefault();

    if (!validarFormulario(formData)) return;

    const result = await Swal.fire({
      title: "¿Estás Seguro?",
      html: `
        <b>Documento:</b> ${formData.numeroDocumento} <br/>
        <b>Nombre:</b> ${formData.primerNombre} ${formData.segundoNombre || ""} ${formData.primerApellido} <br/>
        <b>Teléfono:</b> ${formData.telefono} <br/>
        <b>Correo:</b> ${formData.correo} <br/>
        <b>Tutor:</b> ${formData.nomTutor1} ${formData.apeTutor1} <br/>
        <b>Dorsal:</b> ${formData.dorsal} — <b>Posición:</b> ${formData.posicion} <br/>
        <b>Estatura:</b> ${formData.estatura} cm
      `,
      icon: "question",
      showCancelButton: true,
      confirmButtonText: "Sí, actualizar",
      cancelButtonText: "Cancelar",
      confirmButtonColor: "#28a745",
      cancelButtonColor: "#d33",
    });

    if (!result.isConfirmed) return;

    setLoading(true);

    try {
      // PASO 1: Actualizar la persona
      const personaData = {
        NumeroDeDocumento: parseInt(formData.numeroDocumento),
        Nombre1: formData.primerNombre,
        Nombre2: formData.segundoNombre || null,
        Apellido1: formData.primerApellido,
        Apellido2: formData.segundoApellido || null,
        correo: formData.correo,
        FechaDeNacimiento: formData.fechaNacimiento,
        Genero: formData.genero,
        Telefono: formData.telefono,
        Direccion: formData.direccion,
        EpsSisben: formData.epsSisben || null,
        idTiposDeDocumentos: parseInt(formData.tipoDocumento),
      };

      // Solo incluir contraseña si se cambió
      if (formData.contrasena) {
        personaData.contrasena = formData.contrasena;
      }

      await api.put(`/personas/${jugadorInicial.idPersonas}`, personaData);

      // PASO 2: Actualizar el jugador
      const jugadorData = {
        Dorsal: parseInt(formData.dorsal),
        Posicion: formData.posicion,
        Upz: formData.upz || null,
        Estatura: parseFloat(formData.estatura),
        NomTutor1: formData.nomTutor1,
        NomTutor2: formData.nomTutor2 || null,
        ApeTutor1: formData.apeTutor1,
        ApeTutor2: formData.apeTutor2 || null,
        TelefonoTutor: formData.telefonoTutor,
        idCategorias: parseInt(formData.categoria),
      };

      await api.put(`/jugadores/${jugadorInicial.idJugadores}`, jugadorData);

      await Swal.fire({
        icon: "success",
        title: "¡Jugador actualizado!",
        text: "Los datos se actualizaron correctamente.",
        confirmButtonColor: "#28a745",
      });

      navigate("/PerfilJugadorAdmin");
    } catch (err) {
      console.error("Error actualizando jugador:", err);

      let errorMsg = "No se pudo actualizar el jugador";

      if (err.response?.data?.errors) {
        const errors = err.response.data.errors;
        errorMsg = Object.values(errors).flat().join("\n");
      } else if (err.response?.data?.message) {
        errorMsg = err.response.data.message;
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
      { key: 'numeroDocumento', label: 'Número de Documento' },
      { key: 'tipoDocumento', label: 'Tipo de Documento' },
      { key: 'primerNombre', label: 'Primer Nombre' },
      { key: 'primerApellido', label: 'Primer Apellido' },
      { key: 'genero', label: 'Género' },
      { key: 'telefono', label: 'Teléfono' },
      { key: 'direccion', label: 'Dirección' },
      { key: 'fechaNacimiento', label: 'Fecha de Nacimiento' },
      { key: 'correo', label: 'Correo' },
      { key: 'nomTutor1', label: 'Nombre del Tutor' },
      { key: 'apeTutor1', label: 'Apellido del Tutor' },
      { key: 'telefonoTutor', label: 'Teléfono del Tutor' },
      { key: 'dorsal', label: 'Dorsal' },
      { key: 'posicion', label: 'Posición' },
      { key: 'estatura', label: 'Estatura' },
      { key: 'categoria', label: 'Categoría' },
    ];

    for (const campo of camposRequeridos) {
      if (!values[campo.key] || values[campo.key].toString().trim() === "") {
        Swal.fire({
          icon: "warning",
          title: "Campo vacío",
          text: `El campo "${campo.label}" es obligatorio.`,
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

    if (!telRegex.test(values.telefonoTutor)) {
      Swal.fire({
        icon: "error",
        title: "Teléfono del tutor inválido",
        text: "El teléfono del tutor debe iniciar con 3 y tener 10 dígitos.",
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

    // Solo validar contraseña si se ingresó una nueva
    if (values.contrasena && (values.contrasena.length < 8 || values.contrasena.length > 12)) {
      Swal.fire({
        icon: "error",
        title: "Contraseña inválida",
        text: "La contraseña debe tener entre 8 y 12 caracteres.",
        confirmButtonColor: "#d33",
      });
      return false;
    }

    const dorsal = parseInt(values.dorsal);
    if (isNaN(dorsal) || dorsal < 1 || dorsal > 99) {
      Swal.fire({
        icon: "error",
        title: "Dorsal inválido",
        text: "El dorsal debe ser entre 1 y 99.",
        confirmButtonColor: "#d33",
      });
      return false;
    }

    const estatura = parseFloat(values.estatura);
    if (isNaN(estatura) || estatura < 120 || estatura > 220) {
      Swal.fire({
        icon: "error",
        title: "Estatura inválida",
        text: "La estatura debe estar entre 120 y 220 cm.",
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
      <title>Editar Jugador - SCORD</title>
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
          <h1 className="text-danger">Editar Jugador</h1>
        </div>

        <div className="container mt-4">
          <form onSubmit={actualizarJugador}>
            <div className="row">
              <div className="col-md-6">
                <h5 className="text-danger mb-3">Datos Personales</h5>

                <div className="mb-3">
                  <label htmlFor="numeroDocumento" className="form-label">Número de Documento</label>
                  <input 
                    type="text" 
                    id="numeroDocumento" 
                    name="numeroDocumento" 
                    className="form-control"
                    value={formData.numeroDocumento}
                    onChange={handleChange}
                    required
                  />
                </div>

                <div className="mb-3">
                  <label htmlFor="tipoDocumento" className="form-label">Tipo de Documento</label>
                  <select 
                    id="tipoDocumento" 
                    name="tipoDocumento" 
                    className="form-select"
                    value={formData.tipoDocumento}
                    onChange={handleChange}
                    required
                  >
                    <option value="">Seleccionar</option>
                    {tiposDocumento.map((tipo) => (
                      <option key={tipo.idTiposDeDocumentos} value={tipo.idTiposDeDocumentos}>
                        {tipo.TipoDocumento}
                      </option>
                    ))}
                  </select>
                </div>

                <div className="mb-3">
                  <label htmlFor="primerNombre" className="form-label">Primer Nombre</label>
                  <input 
                    type="text" 
                    id="primerNombre" 
                    name="primerNombre" 
                    className="form-control"
                    value={formData.primerNombre}
                    onChange={handleChange}
                    required
                  />
                </div>

                <div className="mb-3">
                  <label htmlFor="segundoNombre" className="form-label">Segundo Nombre</label>
                  <input 
                    type="text" 
                    id="segundoNombre" 
                    name="segundoNombre" 
                    className="form-control"
                    value={formData.segundoNombre}
                    onChange={handleChange}
                  />
                </div>

                <div className="mb-3">
                  <label htmlFor="primerApellido" className="form-label">Primer Apellido</label>
                  <input 
                    type="text" 
                    id="primerApellido" 
                    name="primerApellido" 
                    className="form-control"
                    value={formData.primerApellido}
                    onChange={handleChange}
                    required
                  />
                </div>

                <div className="mb-3">
                  <label htmlFor="segundoApellido" className="form-label">Segundo Apellido</label>
                  <input 
                    type="text" 
                    id="segundoApellido" 
                    name="segundoApellido" 
                    className="form-control"
                    value={formData.segundoApellido}
                    onChange={handleChange}
                  />
                </div>

                <div className="mb-3">
                  <label htmlFor="genero" className="form-label">Género</label>
                  <select 
                    id="genero" 
                    name="genero" 
                    className="form-select"
                    value={formData.genero}
                    onChange={handleChange}
                    required
                  >
                    <option value="">Seleccionar</option>
                    <option value="M">Masculino</option>
                    <option value="F">Femenino</option>
                  </select>
                </div>

                <div className="mb-3">
                  <label htmlFor="fechaNacimiento" className="form-label">Fecha de Nacimiento</label>
                  <input 
                    type="date" 
                    id="fechaNacimiento" 
                    name="fechaNacimiento" 
                    className="form-control"
                    value={formData.fechaNacimiento}
                    onChange={handleChange}
                    required
                  />
                </div>
              </div>

              <div className="col-md-6">
                <h5 className="text-danger mb-3">Datos de Contacto</h5>

                <div className="mb-3">
                  <label htmlFor="telefono" className="form-label">Teléfono</label>
                  <input 
                    type="tel" 
                    id="telefono" 
                    name="telefono" 
                    className="form-control" 
                    placeholder="3XXXXXXXXX"
                    value={formData.telefono}
                    onChange={handleChange}
                    required
                  />
                </div>

                <div className="mb-3">
                  <label htmlFor="direccion" className="form-label">Dirección</label>
                  <input 
                    type="text" 
                    id="direccion" 
                    name="direccion" 
                    className="form-control"
                    value={formData.direccion}
                    onChange={handleChange}
                    required
                  />
                </div>

                <div className="mb-3">
                  <label htmlFor="correo" className="form-label">Correo Electrónico</label>
                  <input 
                    type="email" 
                    id="correo" 
                    name="correo" 
                    className="form-control" 
                    placeholder="ejemplo@correo.com"
                    value={formData.correo}
                    onChange={handleChange}
                    required
                  />
                </div>

                <div className="mb-3">
                  <label htmlFor="contrasena" className="form-label">Contraseña</label>
                  <input 
                    type="password" 
                    id="contrasena" 
                    name="contrasena" 
                    className="form-control"
                    value={formData.contrasena}
                    onChange={handleChange}
                    placeholder="Dejar vacío para mantener la actual"
                  />
                  <small className="form-text text-muted">8–12 caracteres (dejar vacío si no deseas cambiarla)</small>
                </div>

                <div className="mb-3">
                  <label htmlFor="epsSisben" className="form-label">EPS/Sisben</label>
                  <input 
                    type="text" 
                    id="epsSisben" 
                    name="epsSisben" 
                    className="form-control"
                    value={formData.epsSisben}
                    onChange={handleChange}
                  />
                </div>

                <hr />
                <h5 className="text-danger">Datos del Tutor</h5>

                <div className="mb-3">
                  <label htmlFor="nomTutor1" className="form-label">Nombre del Tutor</label>
                  <input 
                    type="text" 
                    id="nomTutor1" 
                    name="nomTutor1" 
                    className="form-control"
                    value={formData.nomTutor1}
                    onChange={handleChange}
                    required
                  />
                </div>

                <div className="mb-3">
                  <label htmlFor="apeTutor1" className="form-label">Apellido del Tutor</label>
                  <input 
                    type="text" 
                    id="apeTutor1" 
                    name="apeTutor1" 
                    className="form-control"
                    value={formData.apeTutor1}
                    onChange={handleChange}
                    required
                  />
                </div>

                <div className="mb-3">
                  <label htmlFor="telefonoTutor" className="form-label">Teléfono del Tutor</label>
                  <input 
                    type="tel" 
                    id="telefonoTutor" 
                    name="telefonoTutor" 
                    className="form-control" 
                    placeholder="3XXXXXXXXX"
                    value={formData.telefonoTutor}
                    onChange={handleChange}
                    required
                  />
                </div>
              </div>

              <div className="col-12">
                <hr />
                <h5 className="text-danger">Información Deportiva</h5>
                <div className="row">
                  <div className="col-md-6">
                    <div className="mb-3">
                      <label htmlFor="dorsal" className="form-label">Dorsal</label>
                      <input 
                        type="number" 
                        id="dorsal" 
                        name="dorsal" 
                        className="form-control" 
                        min="1" 
                        max="99"
                        value={formData.dorsal}
                        onChange={handleChange}
                        required
                      />
                    </div>

                    <div className="mb-3">
                      <label htmlFor="posicion" className="form-label">Posición</label>
                      <input 
                        type="text" 
                        id="posicion" 
                        name="posicion" 
                        className="form-control"
                        value={formData.posicion}
                        onChange={handleChange}
                        required
                      />
                    </div>

                    <div className="mb-3">
                      <label htmlFor="estatura" className="form-label">Estatura (cm)</label>
                      <input 
                        type="number" 
                        id="estatura" 
                        name="estatura" 
                        className="form-control" 
                        min="120" 
                        max="220" 
                        step="0.1"
                        value={formData.estatura}
                        onChange={handleChange}
                        required
                      />
                    </div>
                  </div>

                  <div className="col-md-6">
                    <div className="mb-3">
                      <label htmlFor="upz" className="form-label">UPZ</label>
                      <input 
                        type="text" 
                        id="upz" 
                        name="upz" 
                        className="form-control"
                        value={formData.upz}
                        onChange={handleChange}
                      />
                    </div>

                    <div className="mb-3">
                      <label htmlFor="categoria" className="form-label">Categoría</label>
                      <select 
                        id="categoria" 
                        name="categoria" 
                        className="form-select"
                        value={formData.categoria}
                        onChange={handleChange}
                        required
                      >
                        <option value="">Seleccionar</option>
                        {categorias.map((cat) => (
                          <option key={cat.idCategorias} value={cat.idCategorias}>
                            {cat.Descripcion}
                          </option>
                        ))}
                      </select>
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
                onClick={() => navigate("/PerfilJugadorAdmin")}
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

export default EditarJugador;