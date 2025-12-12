import React, { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import api from "../../config/axiosConfig";
import Swal from "sweetalert2";
import NavbarAdmin from "../../componentes/NavbarAdmin";

const PerfilEntrenadorAdmin = () => {
  const [entrenadores, setEntrenadores] = useState([]);
  const [categorias, setCategorias] = useState([]);
  const [tiposDocumento, setTiposDocumento] = useState([]);
  const [categoriaSeleccionada, setCategoriaSeleccionada] = useState("");
  const [entrenadorSeleccionado, setEntrenadorSeleccionado] = useState(null);
  const [entrenadoresFiltrados, setEntrenadoresFiltrados] = useState([]);
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
    anosExperiencia: "",
    cargo: "",
    categoriasAsignadas: [],
  });

  useEffect(() => {
    fetchEntrenadores();
    fetchCategorias();
    fetchTiposDocumento();
  }, []);

  useEffect(() => {
    if (categoriaSeleccionada) {
      const filtrados = entrenadores.filter((e) =>
        e.categorias.some((cat) => cat.idCategorias === parseInt(categoriaSeleccionada))
      );
      setEntrenadoresFiltrados(filtrados);
      setEntrenadorSeleccionado(null);
      setModoEdicion(false);
    } else {
      setEntrenadoresFiltrados([]);
      setEntrenadorSeleccionado(null);
      setModoEdicion(false);
    }
  }, [categoriaSeleccionada, entrenadores]);

  const fetchEntrenadores = async () => {
    try {
      const res = await api.get("/entrenadores");
      setEntrenadores(res.data.data || res.data);
    } catch (err) {
      console.error("Error fetching entrenadores:", err);
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
    if (!entrenadorSeleccionado) {
      Swal.fire({
        icon: "warning",
        title: "No hay entrenador seleccionado",
        text: "Por favor selecciona un entrenador primero",
        confirmButtonColor: "#e63946",
      });
      return;
    }

    const persona = entrenadorSeleccionado.persona;
    const categoriasIds = entrenadorSeleccionado.categorias.map((c) => c.idCategorias);

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
      fechaNacimiento: persona.FechaDeNacimiento?.split("T")[0] || "",
      correo: persona.correo || "",
      contrasena: "",
      epsSisben: persona.EpsSisben || "",
      anosExperiencia: entrenadorSeleccionado.AnosDeExperiencia || "",
      cargo: entrenadorSeleccionado.Cargo || "",
      categoriasAsignadas: categoriasIds,
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

  const handleCategoriaChange = (e) => {
    const options = e.target.options;
    const selected = [];
    for (let i = 0; i < options.length; i++) {
      if (options[i].selected) {
        selected.push(parseInt(options[i].value));
      }
    }
    setFormData({
      ...formData,
      categoriasAsignadas: selected,
    });
  };

  const guardarCambios = async () => {
    if (!validarFormulario(formData)) return;

    const result = await Swal.fire({
      title: "¿Estás Seguro?",
      html: `
        <b>Documento:</b> ${formData.numeroDocumento} <br/>
        <b>Nombre:</b> ${formData.primerNombre} ${formData.segundoNombre || ""} ${formData.primerApellido} <br/>
        <b>Cargo:</b> ${formData.cargo} <br/>
        <b>Años de Experiencia:</b> ${formData.anosExperiencia}
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

      await api.put(`/personas/${entrenadorSeleccionado.idPersonas}`, personaData);

      const entrenadorData = {
        AnosDeExperiencia: parseInt(formData.anosExperiencia),
        Cargo: formData.cargo,
        categorias: formData.categoriasAsignadas,
      };

      await api.put(`/entrenadores/${entrenadorSeleccionado.idEntrenadores}`, entrenadorData);

      await Swal.fire({
        icon: "success",
        title: "Entrenador actualizado",
        text: "Los datos se actualizaron correctamente.",
        confirmButtonColor: "#28a745",
      });

      setModoEdicion(false);
      await fetchEntrenadores();
    } catch (err) {
      console.error("Error actualizando entrenador:", err);

      let errorMsg = "No se pudo actualizar el entrenador";

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
      { key: "numeroDocumento", label: "Número de Documento" },
      { key: "tipoDocumento", label: "Tipo de Documento" },
      { key: "primerNombre", label: "Primer Nombre" },
      { key: "primerApellido", label: "Primer Apellido" },
      { key: "genero", label: "Género" },
      { key: "telefono", label: "Teléfono" },
      { key: "direccion", label: "Dirección" },
      { key: "fechaNacimiento", label: "Fecha de Nacimiento" },
      { key: "correo", label: "Correo" },
      { key: "anosExperiencia", label: "Años de Experiencia" },
      { key: "cargo", label: "Cargo" },
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

    if (values.categoriasAsignadas.length === 0) {
      Swal.fire({
        icon: "warning",
        title: "Categorías requeridas",
        text: "Debes seleccionar al menos una categoría.",
        confirmButtonColor: "#d33",
      });
      return false;
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

    if (values.contrasena && (values.contrasena.length < 8 || values.contrasena.length > 12)) {
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

  const eliminarEntrenador = async () => {
    if (!entrenadorSeleccionado) {
      Swal.fire({
        icon: "warning",
        title: "No hay entrenador seleccionado",
        text: "Por favor selecciona un entrenador primero",
        confirmButtonColor: "#e63946",
      });
      return;
    }

    Swal.fire({
      title: "¿Estás seguro?",
      text: "Se eliminará el entrenador",
      icon: "warning",
      showCancelButton: true,
      confirmButtonText: "Sí, eliminar",
      cancelButtonText: "Cancelar",
      confirmButtonColor: "#d33",
      cancelButtonColor: "#28a745",
    }).then(async (result) => {
      if (result.isConfirmed) {
        try {
          await api.delete(`/entrenadores/${entrenadorSeleccionado.idEntrenadores}`);
          await fetchEntrenadores();
          setEntrenadorSeleccionado(null);
          setModoEdicion(false);

          Swal.fire({
            icon: "success",
            title: "Entrenador eliminado",
            text: "El entrenador se eliminó correctamente",
            confirmButtonColor: "#28a745",
          });
        } catch (err) {
          console.error("Error eliminando entrenador:", err);
          Swal.fire({
            icon: "error",
            title: "Error",
            text: "No se pudo eliminar el entrenador",
            confirmButtonColor: "#e63946",
          });
        }
      }
    });
  };

  const persona = entrenadorSeleccionado?.persona || null;
  const categoriasEntrenador = entrenadorSeleccionado?.categorias || [];

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
        integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65"
        crossOrigin="anonymous"
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

      <main className="container my-4">
        <div className="d-flex justify-content-center mb-4 gap-2">
          <Link to="/AgregarEntrenador" className="btn btn-success fw-bold">
            Agregar Entrenador
          </Link>

          {!modoEdicion ? (
            <>
              <button className="btn btn-warning fw-bold" onClick={activarEdicion}>
                Editar Entrenador
              </button>
              <button className="btn btn-danger fw-bold" onClick={eliminarEntrenador}>
                Eliminar Entrenador
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
          <div className="d-flex flex-column align-items-center">
            <section className="card p-4 shadow-sm" style={{ width: "350px" }}>
              <div className="mb-3">
                <label htmlFor="categoriaSelect" className="form-label fw-semibold text-danger">
                  Seleccionar Categoría:
                </label>
                <select
                  className="form-select"
                  id="categoriaSelect"
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
                <label htmlFor="entrenadorSelect" className="form-label fw-semibold text-danger">
                  Seleccionar Entrenador:
                </label>
                <select
                  className="form-select"
                  id="entrenadorSelect"
                  value={entrenadorSeleccionado?.idEntrenadores || ""}
                  onChange={(e) => {
                    const entrenador = entrenadores.find(
                      (ent) => ent.idEntrenadores === parseInt(e.target.value)
                    );
                    setEntrenadorSeleccionado(entrenador);
                    setModoEdicion(false);
                  }}
                  disabled={!categoriaSeleccionada || modoEdicion}
                >
                  <option value="">-- Selecciona un entrenador --</option>
                  {entrenadoresFiltrados.map((ent) => {
                    const pers = ent.persona;
                    return (
                      <option key={ent.idEntrenadores} value={ent.idEntrenadores}>
                        {pers ? `${pers.Nombre1} ${pers.Apellido1}` : "Sin nombre"}
                      </option>
                    );
                  })}
                </select>
              </div>

              <div className="text-center mt-3">
                <img
                  src="/Img/Foto_Perfil.webp"
                  alt="Foto de Perfil"
                  className="rounded-circle shadow"
                  style={{ width: "150px" }}
                />
              </div>
            </section>
          </div>

          <div className="col-md-12">
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
          </div>
        </div>

        <div className="row g-5 mt-4">
          <div className="col-md-12">
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
                  <span>{persona ? `${persona.Nombre1} ${persona.Nombre2 || ""}`.trim() : "-"}</span>
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
                  <span>{persona ? `${persona.Apellido1} ${persona.Apellido2}`.trim() : "-"}</span>
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
              {console.log("Persona completa:", persona)}
              {console.log("Claves de persona:", persona ? Object.keys(persona) : [])}
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

          <div className="col-md-12">
            <h3 className="text-center fw-semibold mb-1">⚽ Información Deportiva</h3>
            <ul className="list-group list-group-flush shadow-sm rounded-3">
              <li className="list-group-item d-flex justify-content-between align-items-center">
                <span className="text-danger fw-semibold">Años de Experiencia:</span>
                {modoEdicion ? (
                  <input
                    type="number"
                    name="anosExperiencia"
                    className="form-control form-control-sm"
                    style={{ maxWidth: "200px" }}
                    min="0"
                    max="50"
                    value={formData.anosExperiencia}
                    onChange={handleChange}
                  />
                ) : (
                  <span>{entrenadorSeleccionado?.AnosDeExperiencia || "-"}</span>
                )}
              </li>
              <li className="list-group-item d-flex justify-content-between align-items-center">
                <span className="text-danger fw-semibold">Cargo:</span>
                {modoEdicion ? (
                  <input
                    type="text"
                    name="cargo"
                    className="form-control form-control-sm"
                    style={{ maxWidth: "200px" }}
                    value={formData.cargo}
                    onChange={handleChange}
                  />
                ) : (
                  <span>{entrenadorSeleccionado?.Cargo || "-"}</span>
                )}
              </li>
              <li className="list-group-item d-flex justify-content-between align-items-center">
                <span className="text-danger fw-semibold">Categorías:</span>
                {modoEdicion ? (
                  <select
                    multiple
                    name="categoriasAsignadas"
                    className="form-select form-select-sm"
                    style={{ maxWidth: "200px", height: "100px" }}
                    value={formData.categoriasAsignadas}
                    onChange={handleCategoriaChange}
                  >
                    {categorias.map((cat) => (
                      <option key={cat.idCategorias} value={cat.idCategorias}>
                        {cat.Descripcion}
                      </option>
                    ))}
                  </select>
                ) : (
                  <span>
                    {categoriasEntrenador.length > 0
                      ? categoriasEntrenador.map((c) => c.Descripcion).join(", ")
                      : "-"}
                  </span>
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

export default PerfilEntrenadorAdmin;