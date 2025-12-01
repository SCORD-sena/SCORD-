import React from "react";
import Swal from "sweetalert2";
import NavbarAdmin from "../../componentes/NavbarAdmin";

const AgregarEntrenador = () => {
  const crearEntrenador = (e) => {
    e.preventDefault();
    const form = e.target;
    const data = new FormData(form);
    const values = Object.fromEntries(data.entries());

    const labels = {
      numeroDocumento: "Número de Documento",
      tipoDocumento: "Tipo de Documento",
      primerNombre: "Primer Nombre",
      segundoNombre: "Segundo Nombre",
      primerApellido: "Primer Apellido",
      segundoApellido: "Segundo Apellido",
      genero: "Género",
      telefono: "Teléfono",
      direccion: "Dirección",
      fechaNacimiento: "Fecha de Nacimiento",
      edad: "Edad",
      correo: "Correo electrónico",
      contrasena: "Contraseña",
      tipoRol: "Tipo de Rol",
      nombreTutor: "Nombre del Tutor",
      telefonoTutor: "Teléfono del Tutor",
      dorsal: "Dorsal",
      posicion: "Posición",
      estaturaCm: "Estatura (cm)",
      upz: "UPZ",
      categoria: "Categoría",
      aniosExperiencia: "Años de Experiencia",
      cargo: "Cargo",
    };

    const requiredFields = [
      "numeroDocumento",
      "tipoDocumento",
      "primerNombre",
      "primerApellido",
      "genero",
      "telefono",
      "direccion",
      "fechaNacimiento",
      "edad",
      "correo",
      "contrasena",
      "tipoRol",
      "nombreTutor",
      "telefonoTutor",
      "dorsal",
      "posicion",
      "estaturaCm",
      "upz",
      "categoria",
    ];

    // Validación campos vacíos
    for (const field of requiredFields) {
      const val = (values[field] ?? "").toString().trim();
      if (!val) {
        Swal.fire({
          icon: "warning",
          title: "Campo vacío",
          text: `El campo "${labels[field]}" es obligatorio.`,
          confirmButtonColor: "#d33",
        });
        return;
      }
    }

    // Validar nombres y apellidos (solo letras y espacios)
    const nameRegex = /^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/;
    ["primerNombre", "segundoNombre", "primerApellido", "segundoApellido", "nombreTutor"].forEach((campo) => {
      if (values[campo] && !nameRegex.test(values[campo])) {
        Swal.fire({
          icon: "error",
          title: "Nombre inválido",
          text: `El campo "${labels[campo]}" solo debe contener letras.`,
        });
        throw new Error("Validación de nombre fallida");
      }
    });

    // Teléfonos
    const telRegex = /^3\d{9}$/;
    if (!telRegex.test(values.telefono)) {
      Swal.fire({
        icon: "error",
        title: "Teléfono inválido",
        text: "El teléfono debe iniciar con 3 y tener 10 dígitos.",
      });
      return;
    }
    if (!telRegex.test(values.telefonoTutor)) {
      Swal.fire({
        icon: "error",
        title: "Teléfono del tutor inválido",
        text: "El teléfono del tutor debe iniciar con 3 y tener 10 dígitos.",
      });
      return;
    }

    // Correo
    const correoRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!correoRegex.test(values.correo)) {
      Swal.fire({
        icon: "error",
        title: "Correo inválido",
        text: "Ingresa un correo válido (ejemplo@correo.com).",
      });
      return;
    }

    // Contraseña (8 a 12 caracteres, alfanumérica)
    const passRegex = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,12}$/;
    if (!passRegex.test(values.contrasena)) {
      Swal.fire({
        icon: "error",
        title: "Contraseña inválida",
        text: "La contraseña debe tener entre 8 y 12 caracteres y ser alfanumérica.",
      });
      return;
    }

    // Edad
    const edadNum = parseInt(values.edad, 10);
    if (isNaN(edadNum) || edadNum < 6 || edadNum > 40) {
      Swal.fire({
        icon: "error",
        title: "Edad inválida",
        text: "La edad debe estar entre 6 y 40 años.",
      });
      return;
    }

    // Dorsal
    const dorsalNum = parseInt(values.dorsal, 10);
    if (isNaN(dorsalNum) || dorsalNum < 1 || dorsalNum > 99) {
      Swal.fire({
        icon: "error",
        title: "Dorsal inválido",
        text: "El dorsal debe estar entre 1 y 99.",
      });
      return;
    }

    // Estatura
    const estCm = parseInt(values.estaturaCm, 10);
    if (isNaN(estCm) || estCm < 120 || estCm > 220) {
      Swal.fire({
        icon: "error",
        title: "Estatura inválida",
        text: "La estatura debe estar entre 120 y 220 cm.",
      });
      return;
    }

    // Confirmación
    Swal.fire({
      title: "¿Estás seguro?",
      html: `
        <b>${labels.numeroDocumento}:</b> ${values.numeroDocumento} <br/>
        <b>${labels.primerNombre}:</b> ${values.primerNombre} ${values.segundoNombre ?? ""} ${values.primerApellido} <br/>
        <b>${labels.edad}:</b> ${values.edad} años <br/>
        <b>${labels.telefono}:</b> ${values.telefono} <br/>
        <b>${labels.correo}:</b> ${values.correo} <br/>
        <b>${labels.nombreTutor}:</b> ${values.nombreTutor} <br/>
        <b>${labels.dorsal}:</b> ${values.dorsal} — <b>Posición:</b> ${values.posicion} <br/>
        <b>${labels.estaturaCm}:</b> ${values.estaturaCm} cm <br/>
        <b>${labels.categoria}:</b> ${values.categoria}
      `,
      icon: "question",
      showCancelButton: true,
      confirmButtonText: "Sí, actualizar",
      cancelButtonText: "Cancelar",
      confirmButtonColor: "#28a745",
      cancelButtonColor: "#d33",
    }).then((result) => {
      if (result.isConfirmed) {
        Swal.fire({
          icon: "success",
          title: "Datos actualizados",
          text: "Los datos se guardaron correctamente.",
        });
        form.reset();
      }
    });
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

      {/* Header */}
      <header className="header bg-white shadow-sm py-3">
        <nav className="navbar container d-flex align-items-center justify-content-between flex-wrap">
          <div className="d-flex align-items-center">
            <img src="/Img/SCORD.png" alt="Logo SCORD" className="me-2" style={{ height: "60px" }} />
            <h4 className="mb-0 text-danger fw-bold">SCORD</h4>
          </div>
          <NavbarAdmin />
        </nav>
      </header>

      {/* Formulario */}
      <main className="container my-5">
        <div className="text-center mb-4">
          <h1 className="text-danger">Agregar Entrenador</h1>
        </div>

        <form onSubmit={crearEntrenador}>
          <div className="row">
            {/* Columna izquierda */}
            <div className="col-md-6">
              <div className="mb-3">
                <label className="form-label">Primer Nombre</label>
                <input type="text" name="primerNombre" className="form-control" />
              </div>
              <div className="mb-3">
                <label className="form-label">Segundo Nombre</label>
                <input type="text" name="segundoNombre" className="form-control" />
              </div>
              <div className="mb-3">
                <label className="form-label">Primer Apellido</label>
                <input type="text" name="primerApellido" className="form-control" />
              </div>
              <div className="mb-3">
                <label className="form-label">Segundo Apellido</label>
                <input type="text" name="segundoApellido" className="form-control" />
              </div>
              <div className="mb-3">
                <label className="form-label">Género</label>
                <select name="genero" className="form-select">
                  <option value="">Seleccionar</option>
                  <option value="M">Masculino</option>
                  <option value="F">Femenino</option>
                </select>
              </div>
              <div className="mb-3">
                <label className="form-label">Edad</label>
                <input type="number" name="edad" className="form-control" />
              </div>
            </div>

            {/* Columna derecha */}
            <div className="col-md-6">
              <div className="mb-3">
                <label className="form-label">Fecha de Nacimiento</label>
                <input type="date" name="fechaNacimiento" className="form-control" />
              </div>
              <div className="mb-3">
                <label className="form-label">Correo Electrónico</label>
                <input type="email" name="correo" className="form-control" placeholder="ejemplo@correo.com" />
              </div>
              <div className="mb-3">
                <label className="form-label">Contraseña</label>
                <input type="password" name="contrasena" className="form-control" />
                <small className="form-text text-muted">8–12 caracteres alfanuméricos</small>
              </div>
            </div>
          </div>

          {/* Info deportiva */}
          <hr />
          <h5>Información Deportiva</h5>
          <div className="row">
            <div className="col-md-6">
              <div className="mb-3">
                <label className="form-label">Años de Experiencia</label>
                <input type="number" name="aniosExperiencia" className="form-control" min="0" max="99" />
              </div>
              <div className="mb-3">
                <label className="form-label">Cargo</label>
                <input type="text" name="cargo" className="form-control" />
              </div>
            </div>
            <div className="col-md-6">
              <div className="mb-3">
                <label className="form-label">Categoría</label>
                <select name="categoria" className="form-select">
                  <option value="">Seleccionar</option>
                  <option value="Sub20">Sub20</option>
                  <option value="2005">2005</option>
                  <option value="2006">2006</option>
                  <option value="2007">2007</option>
                  <option value="2008">2008</option>
                  <option value="2009">2009</option>
                  <option value="2010">2010</option>
                </select>
              </div>
            </div>
          </div>

          {/* Botones */}
          <div className="mt-4 d-flex justify-content-end gap-2">
            <button type="submit" className="btn btn-success">Guardar</button>
            <button type="button" className="btn btn-danger">Cancelar</button>
          </div>
        </form>
      </main>
    </div>
  );
};

export default AgregarEntrenador;