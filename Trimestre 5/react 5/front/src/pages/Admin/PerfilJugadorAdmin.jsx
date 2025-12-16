import React, { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import api from "../../config/axiosConfig";
import Swal from "sweetalert2";
import NavbarAdmin from "../../componentes/NavbarAdmin";

const PerfilJugadorAdmin = () => {
  const [jugadores, setJugadores] = useState([]);
  const [categorias, setCategorias] = useState([]);
  const [tiposDocumento, setTiposDocumento] = useState([]);
  const [categoriaSeleccionada, setCategoriaSeleccionada] = useState("");
  const [jugadorSeleccionado, setJugadorSeleccionado] = useState(null);
  const [jugadoresFiltrados, setJugadoresFiltrados] = useState([]);
  const [modoEdicion, setModoEdicion] = useState(false);
  const [loading, setLoading] = useState(false);

  const [formData, setFormData] = useState({
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
    fetchJugadores();
    fetchCategorias();
    fetchTiposDocumento();
  }, []);

  useEffect(() => {
    if (categoriaSeleccionada) {
      const filtrados = jugadores.filter(
        (j) => j.idCategorias === parseInt(categoriaSeleccionada)
      );
      setJugadoresFiltrados(filtrados);
      setJugadorSeleccionado(null);
      setModoEdicion(false);
    } else {
      setJugadoresFiltrados([]);
      setJugadorSeleccionado(null);
      setModoEdicion(false);
    }
  }, [categoriaSeleccionada, jugadores]);

  const fetchJugadores = async () => {
    try {
      const res = await api.get("/jugadores");
      setJugadores(res.data);
    } catch (err) {
      console.error("Error fetching jugadores:", err);
    }
  };

  const fetchCategorias = async () => {
    try {
      const res = await api.get("/categorias");
      setCategorias(res.data);
    } catch (err) {
      console.error("Error fetching categorias:", err);
    }
  };

  const fetchTiposDocumento = async () => {
    try {
      const res = await api.get("/tiposdedocumentos");
      setTiposDocumento(res.data);
    } catch (err) {
      console.error("Error fetching tipos documento:", err);
    }
  };

  const activarEdicion = () => {
    console.log("=== ACTIVAR EDICIÓN ===");
  console.log("1. jugadorSeleccionado completo:", jugadorSeleccionado);
  console.log("2. persona:", jugadorSeleccionado?.persona);
  console.log("3. tiposDeDocumentos:", jugadorSeleccionado?.persona?.tiposDeDocumentos);
  console.log("4. Propiedades de persona:", jugadorSeleccionado?.persona ? Object.keys(jugadorSeleccionado.persona) : "persona es null");
  if (!jugadorSeleccionado) {
    Swal.fire({
      icon: "warning",
      title: "No hay jugador seleccionado",
      text: "Por favor selecciona un jugador primero",
      confirmButtonColor: "#e63946",
    });
    return;
   }

    const persona = jugadorSeleccionado.persona;

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
      fechaNacimiento: persona.FechaDeNacimiento?.split('T')[0] || "",
      correo: persona.correo || "",
      contrasena: "",
      epsSisben: persona.EpsSisben || "",
      dorsal: jugadorSeleccionado.Dorsal || "",
      posicion: jugadorSeleccionado.Posicion || "",
      estatura: jugadorSeleccionado.Estatura || "",
      upz: jugadorSeleccionado.Upz || "",
      categoria: jugadorSeleccionado.idCategorias || "",
      nomTutor1: jugadorSeleccionado.NomTutor1 || "",
      nomTutor2: jugadorSeleccionado.NomTutor2 || "",
      apeTutor1: jugadorSeleccionado.ApeTutor1 || "",
      apeTutor2: jugadorSeleccionado.ApeTutor2 || "",
      telefonoTutor: jugadorSeleccionado.TelefonoTutor || "",
    });

    setModoEdicion(true);
  };

  const cancelarEdicion = () => {
    setModoEdicion(false);
    setFormData({});
  };

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const guardarCambios = async () => {
    if (!validarFormulario(formData)) return;

    const result = await Swal.fire({
      title: "¿Estás Seguro?",
      html: `
        <b>Documento:</b> ${formData.numeroDocumento} <br/>
        <b>Nombre:</b> ${formData.primerNombre} ${formData.segundoNombre || ""} ${formData.primerApellido} <br/>
        <b>Dorsal:</b> ${formData.dorsal} — <b>Posición:</b> ${formData.posicion}
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
      const personaData = {
        NumeroDeDocumento: formData.numeroDocumento,
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

      if (formData.contrasena) {
        personaData.contrasena = formData.contrasena;
      }

      await api.put(`/personas/${jugadorSeleccionado.idPersonas}`, personaData);

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

      await api.put(`/jugadores/${jugadorSeleccionado.idJugadores}`, jugadorData);

      await Swal.fire({
        icon: "success",
        title: "Jugador actualizado",
        text: "Los datos se actualizaron correctamente.",
        confirmButtonColor: "#28a745",
      });

      setModoEdicion(false);
      await fetchJugadores();
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

  const eliminarJugador = async () => {
    if (!jugadorSeleccionado) {
      Swal.fire({
        icon: "warning",
        title: "No hay jugador seleccionado",
        text: "Por favor selecciona un jugador primero",
        confirmButtonColor: "#e63946",
      });
      return;
    }

    Swal.fire({
      title: "¿Estás seguro?",
      text: "Se eliminará el jugador",
      icon: "warning",
      showCancelButton: true,
      confirmButtonText: "Sí, eliminar",
      cancelButtonText: "Cancelar",
      confirmButtonColor: "#d33",
      cancelButtonColor: "#28a745",
    }).then(async (result) => {
      if (result.isConfirmed) {
        try {
          await api.delete(`/jugadores/${jugadorSeleccionado.idJugadores}`);
          await fetchJugadores();
          setJugadorSeleccionado(null);
          setModoEdicion(false);

          Swal.fire({
            icon: "success",
            title: "Jugador eliminado",
            text: "El jugador se eliminó correctamente",
            confirmButtonColor: "#28a745",
          });
        } catch (err) {
          console.error("Error eliminando jugador:", err);
          Swal.fire({
            icon: "error",
            title: "Error",
            text: "No se pudo eliminar el jugador",
            confirmButtonColor: "#e63946",
          });
        }
      }
    });
  };

  const persona = jugadorSeleccionado?.persona || null;
  const categoria = jugadorSeleccionado?.categoria || null;

  const calcularEdad = (fechaNacimiento) => {
    if (!fechaNacimiento) return "-";
    const hoy = new Date();
    const nacimiento = new Date(fechaNacimiento);
    let edad = hoy.getFullYear() - nacimiento.getFullYear();
    const mes = hoy.getMonth() - nacimiento.getMonth();
    if (mes < 0 || (mes === 0 && hoy.getDate() < nacimiento.getDate())) {
      edad--;
    }
    return edad;
  };

  return (
    <div>
      <meta charSet="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Inicio - SCORD</title>
      <link
        href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css"
        rel="stylesheet"
      />
      <link rel="stylesheet" href="/Css/InicioAdmin.css" />

      <header className="header bg-white shadow-sm py-3">
        <nav className="navbar container d-flex align-items-center justify-content-between flex-wrap">
          <div className="d-flex align-items-center">
            <img src="/Img/SCORD.png" alt="Logo SCORD" className="me-2" style={{ height: "60px" }} />
            <h4 className="mb-0 text-danger fw-bold">SCORD</h4>
          </div>
          <label className="labe_hamburguesa d-md-none" htmlFor="menu_hamburguesa">
            <svg xmlns="http://www.w3.org/2000/svg" width={35} height={35} fill="#e63946" viewBox="0 0 16 16">
              <path
                fillRule="evenodd"
                d="M2.5 12a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5z"
              />
            </svg>
          </label>
          <input className="menu_hamburguesa d-none" type="checkbox" id="menu_hamburguesa" />
          <NavbarAdmin />
        </nav>
      </header>

      <main className="container my-5">
        <div className="d-flex justify-content-center mb-4 gap-2 flex-wrap">
          <Link to="/AgregarJugador" className="btn btn-success fw-bold">
            Agregar Jugador
          </Link>
          
          {!modoEdicion ? (
            <>
              <button className="btn btn-warning fw-bold" onClick={activarEdicion}>
                Editar Jugador
              </button>
              <button className="btn btn-danger fw-bold" onClick={eliminarJugador}>
                Eliminar Jugador
              </button>
            </>
          ) : (
            <>
              <button className="btn btn-success fw-bold" onClick={guardarCambios} disabled={loading}>
                {loading ? "Guardando..." : "Guardar Cambios"}
              </button>
              <button className="btn btn-secondary fw-bold" onClick={cancelarEdicion} disabled={loading}>
                Cancelar
              </button>
            </>
          )}
        </div>

        <div className="row g-5 align-items-start">
          <div className="col-md-6">
            <section className="text-center mb-4">
              <div className="mb-3">
                <label htmlFor="categoriaSelect" className="form-label fw-semibold text-danger">
                  Seleccionar Categoría:
                </label>
                <select
                  className="form-select mx-auto"
                  id="categoriaSelect"
                  style={{ maxWidth: "300px" }}
                  value={categoriaSeleccionada}
                  onChange={(e) => setCategoriaSeleccionada(e.target.value)}
                  disabled={modoEdicion}
                >
                  <option value="">-- Selecciona una categoría --</option>
                  {categorias.map((cat) => (
                    <option key={cat.idCategorias} value={cat.idCategorias}>
                      {cat.Descripcion}
                    </option>
                  ))}
                </select>
              </div>

              <div className="mb-3">
                <label htmlFor="jugadorSelect" className="form-label fw-semibold text-danger">
                  Seleccionar Jugador:
                </label>
                <select
                  className="form-select mx-auto"
                  id="jugadorSelect"
                  style={{ maxWidth: "300px" }}
                  value={jugadorSeleccionado?.idJugadores || ""}
                  onChange={(e) => {
                    const jugador = jugadores.find(
                      (j) => j.idJugadores === parseInt(e.target.value)
                    );
                    setJugadorSeleccionado(jugador);
                    setModoEdicion(false);
                  }}
                  disabled={!categoriaSeleccionada || modoEdicion}
                >
                  <option value="">-- Selecciona un jugador --</option>
                  {jugadoresFiltrados.map((jug) => {
                    const pers = jug.persona;
                    return (
                      <option key={jug.idJugadores} value={jug.idJugadores}>
                        {pers ? `${pers.Nombre1} ${pers.Apellido1}` : "Sin nombre"}
                      </option>
                    );
                  })}
                </select>
              </div>

              <img
                src="/Img/Foto_Perfil.webp"
                alt="Foto de Perfil"
                className="rounded-circle shadow mb-4"
                style={{ width: "150px" }}
              />
            </section>
          </div>

          <div className="col-md-6">
            <section>
              <h3 className="fw-semibold mb-1 text-center">📞 Información de Contacto</h3>
              <ul className="list-group list-group-flush shadow-sm rounded-3 mb-4">
                <li className="list-group-item d-flex justify-content-between align-items-center">
                  <span className="text-danger fw-semibold">Teléfono:</span>
                  {modoEdicion ? (
                    <input
                      type="tel"
                      name="telefono"
                      className="form-control form-control-sm"
                      style={{ maxWidth: "200px" }}
                      value={formData.telefono}
                      onChange={handleChange}
                    />
                  ) : (
                    <span>{persona?.Telefono || "-"}</span>
                  )}
                </li>
                <li className="list-group-item d-flex justify-content-between align-items-center">
                  <span className="text-danger fw-semibold">Dirección:</span>
                  {modoEdicion ? (
                    <input
                      type="text"
                      name="direccion"
                      className="form-control form-control-sm"
                      style={{ maxWidth: "200px" }}
                      value={formData.direccion}
                      onChange={handleChange}
                    />
                  ) : (
                    <span>{persona?.Direccion || "-"}</span>
                  )}
                </li>
                <li className="list-group-item d-flex justify-content-between align-items-center">
                  <span className="text-danger fw-semibold">Email:</span>
                  {modoEdicion ? (
                    <input
                      type="email"
                      name="correo"
                      className="form-control form-control-sm"
                      style={{ maxWidth: "200px" }}
                      value={formData.correo}
                      onChange={handleChange}
                    />
                  ) : (
                    <span>{persona?.correo || "-"}</span>
                  )}
                </li>
                <li className="list-group-item d-flex justify-content-between align-items-center">
                  <span className="text-danger fw-semibold">EPS:</span>
                  {modoEdicion ? (
                    <input
                      type="text"
                      name="epsSisben"
                      className="form-control form-control-sm"
                      style={{ maxWidth: "200px" }}
                      value={formData.epsSisben}
                      onChange={handleChange}
                    />
                  ) : (
                    <span>{persona?.EpsSisben || "-"}</span>
                  )}
                </li>
              </ul>
            </section>

            <section>
              <h3 className="fw-semibold mb-1 text-center">👨‍👩‍👦 Información de Tutores</h3>
              <ul className="list-group list-group-flush shadow-sm rounded-3">
                <li className="list-group-item d-flex justify-content-between align-items-center">
                  <span className="text-danger fw-semibold">Nombre del tutor:</span>
                  {modoEdicion ? (
                    <div className="d-flex gap-1">
                      <input
                        type="text"
                        name="nomTutor1"
                        className="form-control form-control-sm"
                        style={{ maxWidth: "95px" }}
                        placeholder="Nombre"
                        value={formData.nomTutor1}
                        onChange={handleChange}
                      />
                      <input
                        type="text"
                        name="apeTutor1"
                        className="form-control form-control-sm"
                        style={{ maxWidth: "95px" }}
                        placeholder="Apellido"
                        value={formData.apeTutor1}
                        onChange={handleChange}
                      />
                    </div>
                  ) : (
                    <span>
                      {jugadorSeleccionado
                        ? `${jugadorSeleccionado.NomTutor1 || ""} ${
                            jugadorSeleccionado.ApeTutor1 || ""
                          }`.trim() || "-"
                        : "-"}
                    </span>
                  )}
                </li>
                <li className="list-group-item d-flex justify-content-between align-items-center">
                  <span className="text-danger fw-semibold">Teléfono del Tutor:</span>
                  {modoEdicion ? (
                    <input
                      type="tel"
                      name="telefonoTutor"
                      className="form-control form-control-sm"
                      style={{ maxWidth: "200px" }}
                      value={formData.telefonoTutor}
                      onChange={handleChange}
                    />
                  ) : (
                    <span>{jugadorSeleccionado?.TelefonoTutor || "-"}</span>
                  )}
                </li>
              </ul>
            </section>
          </div>
        </div>

        <div className="row g-5 mt-4">
          <div className="col-md-6">
            <h3 className="text-center fw-semibold mb-1">👤 Información Personal</h3>
            <ul className="list-group list-group-flush shadow-sm rounded-3">
              <li className="list-group-item d-flex justify-content-between align-items-center">
                <strong>Nombres:</strong>
                {modoEdicion ? (
                  <div className="d-flex gap-1">
                    <input
                      type="text"
                      name="primerNombre"
                      className="form-control form-control-sm"
                      style={{ maxWidth: "95px" }}
                      placeholder="Primer"
                      value={formData.primerNombre}
                      onChange={handleChange}
                    />
                    <input
                      type="text"
                      name="segundoNombre"
                      className="form-control form-control-sm"
                      style={{ maxWidth: "95px" }}
                      placeholder="Segundo"
                      value={formData.segundoNombre}
                      onChange={handleChange}
                    />
                  </div>
                ) : (
                  <span>
                    {persona ? `${persona.Nombre1} ${persona.Nombre2 || ""}`.trim() : "-"}
                  </span>
                )}
              </li>
              <li className="list-group-item d-flex justify-content-between align-items-center">
                <strong>Apellidos:</strong>
                {modoEdicion ? (
                  <div className="d-flex gap-1">
                    <input
                      type="text"
                      name="primerApellido"
                      className="form-control form-control-sm"
                      style={{ maxWidth: "95px" }}
                      placeholder="Primer"
                      value={formData.primerApellido}
                      onChange={handleChange}
                    />
                    <input
                      type="text"
                      name="segundoApellido"
                      className="form-control form-control-sm"
                      style={{ maxWidth: "95px" }}
                      placeholder="Segundo"
                      value={formData.segundoApellido}
                      onChange={handleChange}
                    />
                  </div>
                ) : (
                  <span>
                    {persona ? `${persona.Apellido1} ${persona.Apellido2}`.trim() : "-"}
                  </span>
                )}
              </li>
              <li className="list-group-item d-flex justify-content-between align-items-center">
                <strong>Edad:</strong>
                <span>{persona ? calcularEdad(persona.FechaDeNacimiento) : "-"}</span>
              </li>
              <li className="list-group-item d-flex justify-content-between align-items-center">
                <strong>Fecha de Nacimiento:</strong>
                {modoEdicion ? (
                  <input
                    type="date"
                    name="fechaNacimiento"
                    className="form-control form-control-sm"
                    style={{ maxWidth: "200px" }}
                    value={formData.fechaNacimiento}
                    onChange={handleChange}
                  />
                ) : (
                  <span>
               {persona?.FechaDeNacimiento 
               ? new Date(persona.FechaDeNacimiento).toLocaleDateString('es-CO', {
                 day: '2-digit',
                 month: '2-digit',
                 year: 'numeric'
              })
                : "-"
                       }
              </span>
                )}
              </li>
              <li className="list-group-item d-flex justify-content-between align-items-center">
                <strong>Documento:</strong>
                {modoEdicion ? (
                  <input
                    type="text"
                    name="numeroDocumento"
                    className="form-control form-control-sm"
                    style={{ maxWidth: "200px" }}
                    value={formData.numeroDocumento}
                    onChange={handleChange}
                  />
                ) : (
                  <span>{persona?.NumeroDeDocumento || "-"}</span>
                )}
              </li>
              <li className="list-group-item d-flex justify-content-between align-items-center">
                <strong>Tipo de Documento:</strong>
                {modoEdicion ? (
                  <select
                  name="tipoDocumento"
                  className="form-select form-select-sm"
                  style={{ maxWidth: "200px" }}
                  value={formData.tipoDocumento}
                  onChange={handleChange}
                >
                <option value="">Seleccionar</option>
                {tiposDocumento.map((tipo) => (
                <option key={tipo.idTiposDeDocumentos} value={tipo.idTiposDeDocumentos}>
                {tipo.Descripcion}
                </option>
               ))}
                   </select>
                ) : (
                  <span>{persona?.tipos_de_documentos?.Descripcion || "-"}</span>
                )}
              </li>
                            <li className="list-group-item d-flex justify-content-between align-items-center">
                <strong>Género:</strong>
                {modoEdicion ? (
                  <select
                    name="genero"
                    className="form-select form-select-sm"
                    style={{ maxWidth: "200px" }}
                    value={formData.genero}
                    onChange={handleChange}
                  >
                    <option value="">Seleccionar</option>
                    <option value="M">Masculino</option>
                    <option value="F">Femenino</option>
                  </select>
                ) : (
                  <span>{persona?.Genero || "-"}</span>
                )}
              </li>
            </ul>
          </div>

          <div className="col-md-6">
            <h3 className="text-center fw-semibold mb-1">⚽ Información Deportiva</h3>
            <ul className="list-group list-group-flush shadow-sm rounded-3">
              <li className="list-group-item d-flex justify-content-between align-items-center">
                <span className="text-danger fw-semibold">Dorsal:</span>
                {modoEdicion ? (
                  <input
                    type="number"
                    name="dorsal"
                    className="form-control form-control-sm"
                    style={{ maxWidth: "200px" }}
                    min="1"
                    max="99"
                    value={formData.dorsal}
                    onChange={handleChange}
                  />
                ) : (
                  <span>{jugadorSeleccionado?.Dorsal || "-"}</span>
                )}
              </li>
              <li className="list-group-item d-flex justify-content-between align-items-center">
                <span className="text-danger fw-semibold">Posición:</span>
                {modoEdicion ? (
                  <input
                    type="text"
                    name="posicion"
                    className="form-control form-control-sm"
                    style={{ maxWidth: "200px" }}
                    value={formData.posicion}
                    onChange={handleChange}
                  />
                ) : (
                  <span>{jugadorSeleccionado?.Posicion || "-"}</span>
                )}
              </li>
              <li className="list-group-item d-flex justify-content-between align-items-center">
                <span className="text-danger fw-semibold">Estatura:</span>
                {modoEdicion ? (
                  <input
                    type="number"
                    name="estatura"
                    className="form-control form-control-sm"
                    style={{ maxWidth: "200px" }}
                    min="120"
                    max="220"
                    step="0.1"
                    value={formData.estatura}
                    onChange={handleChange}
                  />
                ) : (
                  <span>
                    {jugadorSeleccionado?.Estatura ? `${jugadorSeleccionado.Estatura} cm` : "-"}
                  </span>
                )}
              </li>
              <li className="list-group-item d-flex justify-content-between align-items-center">
                <span className="text-danger fw-semibold">UPZ:</span>
                {modoEdicion ? (
                  <input
                    type="text"
                    name="upz"
                    className="form-control form-control-sm"
                    style={{ maxWidth: "200px" }}
                    value={formData.upz}
                    onChange={handleChange}
                  />
                ) : (
                  <span>{jugadorSeleccionado?.Upz || "-"}</span>
                )}
              </li>
              <li className="list-group-item d-flex justify-content-between align-items-center">
                <span className="text-danger fw-semibold">Categoría:</span>
                {modoEdicion ? (
                  <select
                    name="categoria"
                    className="form-select form-select-sm"
                    style={{ maxWidth: "200px" }}
                    value={formData.categoria}
                    onChange={handleChange}
                  >
                    <option value="">Seleccionar</option>
                    {categorias.map((cat) => (
                      <option key={cat.idCategorias} value={cat.idCategorias}>
                        {cat.Descripcion}
                      </option>
                    ))}
                  </select>
                ) : (
                  <span>{categoria?.Descripcion || "-"}</span>
                )}
              </li>
            </ul>
          </div>
        </div>

        {modoEdicion && (
          <div className="row mt-4">
            <div className="col-12">
              <div className="alert alert-info">
                <strong>Contraseña:</strong> Dejar vacío si no deseas cambiarla
                <input
                  type="password"
                  name="contrasena"
                  className="form-control form-control-sm mt-2"
                  placeholder="Nueva contraseña (8-12 caracteres)"
                  value={formData.contrasena}
                  onChange={handleChange}
                />
              </div>
            </div>
          </div>
        )}
      </main>

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
          <p className="text-center mb-0 small">
            © 2025 SCORD | Escuela de Fútbol Quilmes | Todos los derechos reservados
          </p>
        </div>
      </footer>
    </div>
  );
};
export default PerfilJugadorAdmin;