import React, { useState } from "react";
import Swal from "sweetalert2";
import NavbarAdmin from "../../componentes/NavbarAdmin";

const Cronograma = () => {
  const [partidos, setPartidos] = useState([
    {
      id: 1,
      rival: "Atlético Suba",
      categoria: "Sub-15",
      fecha: "2025-10-15",
      hora: "09:00",
      ubicacion: "CONEJERA",
      cancha: "3"
    },
    {
      id: 2,
      rival: "Real Fontibón",
      categoria: "Sub-20",
      fecha: "2025-10-18",
      hora: "14:00",
      ubicacion: "XCOLI",
      cancha: "5"
    }
  ]);

  const [entrenamientos, setEntrenamientos] = useState([
    {
      id: 1,
      categoria: "Sub-15",
      fecha: "2025-10-10",
      hora: "08:00",
      sede: "TIMIZA"
    },
    {
      id: 2,
      categoria: "Sub-20",
      fecha: "2025-10-12",
      hora: "15:00",
      sede: "CAYETANO"
    }
  ]);

  // Eliminar partido
  const handleEliminarPartido = (id) => {
    Swal.fire({
      title: "¿Estás seguro?",
      text: "Se eliminará el partido",
      icon: "warning",
      showCancelButton: true,
      confirmButtonText: "Sí, eliminar",
      cancelButtonText: "Cancelar",
      confirmButtonColor: "#d33",
      cancelButtonColor: "#28a745"
    }).then((result) => {
      if (result.isConfirmed) {
        setPartidos(partidos.filter(p => p.id !== id));
        Swal.fire({
          icon: "success",
          title: "¡Eliminado!",
          text: "El partido se eliminó correctamente",
          confirmButtonColor: "#28a745"
        });
      }
    });
  };

  // Editar partido
  const handleEditarPartido = (partido) => {
    Swal.fire({
      title: "Editar Partido",
      html: `
        <input id="rival" class="swal2-input" placeholder="Rival" value="${partido.rival}">
        <input id="categoria" class="swal2-input" placeholder="Categoría" value="${partido.categoria}">
        <input id="fecha" type="date" class="swal2-input" value="${partido.fecha}">
        <input id="hora" type="time" class="swal2-input" value="${partido.hora}">
        <select id="ubicacion" class="swal2-input">
          <option value="CONEJERA" ${partido.ubicacion === "CONEJERA" ? "selected" : ""}>CONEJERA</option>
          <option value="XCOLI" ${partido.ubicacion === "XCOLI" ? "selected" : ""}>XCOLI</option>
          <option value="MORENA" ${partido.ubicacion === "MORENA" ? "selected" : ""}>MORENA</option>
          <option value="SIBERIA" ${partido.ubicacion === "SIBERIA" ? "selected" : ""}>SIBERIA</option>
        </select>
        <input id="cancha" type="number" class="swal2-input" placeholder="Cancha" value="${partido.cancha}" min="1" max="20">
      `,
      confirmButtonText: "Guardar",
      confirmButtonColor: "#28a745",
      showCancelButton: true,
      cancelButtonText: "Cancelar",
      preConfirm: () => {
        const rival = document.getElementById("rival").value;
        const categoria = document.getElementById("categoria").value;
        const fecha = document.getElementById("fecha").value;
        const hora = document.getElementById("hora").value;
        const ubicacion = document.getElementById("ubicacion").value;
        const cancha = document.getElementById("cancha").value;

        if (!rival || !categoria || !fecha || !hora || !ubicacion || !cancha) {
          Swal.showValidationMessage("Todos los campos son obligatorios");
          return false;
        }

        return { rival, categoria, fecha, hora, ubicacion, cancha };
      }
    }).then((result) => {
      if (result.isConfirmed) {
        setPartidos(partidos.map(p => 
          p.id === partido.id ? { ...p, ...result.value } : p
        ));
        Swal.fire("Actualizado", "Partido actualizado con éxito.", "success");
      }
    });
  };

  // Eliminar entrenamiento
  const handleEliminarEntrenamiento = (id) => {
    Swal.fire({
      title: "¿Estás seguro?",
      text: "Se eliminará el entrenamiento",
      icon: "warning",
      showCancelButton: true,
      confirmButtonText: "Sí, eliminar",
      cancelButtonText: "Cancelar",
      confirmButtonColor: "#d33",
      cancelButtonColor: "#28a745"
    }).then((result) => {
      if (result.isConfirmed) {
        setEntrenamientos(entrenamientos.filter(e => e.id !== id));
        Swal.fire({
          icon: "success",
          title: "¡Eliminado!",
          text: "El entrenamiento se eliminó correctamente",
          confirmButtonColor: "#28a745"
        });
      }
    });
  };

  // Editar entrenamiento
  const handleEditarEntrenamiento = (entrenamiento) => {
    Swal.fire({
      title: "Editar Entrenamiento",
      html: `
        <input id="categoria" class="swal2-input" placeholder="Categoría" value="${entrenamiento.categoria}">
        <input id="fecha" type="date" class="swal2-input" value="${entrenamiento.fecha}">
        <input id="hora" type="time" class="swal2-input" value="${entrenamiento.hora}">
        <select id="sede" class="swal2-input">
          <option value="TIMIZA" ${entrenamiento.sede === "TIMIZA" ? "selected" : ""}>TIMIZA</option>
          <option value="CAYETANO CAÑIZARES" ${entrenamiento.sede === "CAYETANO" ? "selected" : ""}>CAYETANO CAÑIZARES</option>
          <option value="FONTIBON" ${entrenamiento.sede === "FONTIBON" ? "selected" : ""}>FONTIBON</option>
        </select>
      `,
      confirmButtonText: "Guardar",
      confirmButtonColor: "#28a745",
      showCancelButton: true,
      cancelButtonText: "Cancelar",
      preConfirm: () => {
        const categoria = document.getElementById("categoria").value;
        const fecha = document.getElementById("fecha").value;
        const hora = document.getElementById("hora").value;
        const sede = document.getElementById("sede").value;

        if (!categoria || !fecha || !hora || !sede) {
          Swal.showValidationMessage("Todos los campos son obligatorios");
          return false;
        }

        return { categoria, fecha, hora, sede };
      }
    }).then((result) => {
      if (result.isConfirmed) {
        setEntrenamientos(entrenamientos.map(e => 
          e.id === entrenamiento.id ? { ...e, ...result.value } : e
        ));
        Swal.fire("Actualizado", "Entrenamiento actualizado con éxito.", "success");
      }
    });
  };

  const handleEntrenamiento = (e) => {
    e.preventDefault();
    const form = e.target;
    const data = new FormData(form);
    const values = Object.fromEntries(data.entries());
    
    if (!values.categoria || !values.fecha || !values.hora || !values.sede) {
      Swal.fire({
        icon: "warning",
        title: "Campos vacíos",
        text: "Todos los campos del entrenamiento son obligatorios.",
        confirmButtonColor: "#d33",
      });
      return;
    }

    Swal.fire({
      title: "¿Confirmar Entrenamiento?",
      html: `
        <b>Categoría:</b> ${values.categoria} <br/>
        <b>Fecha:</b> ${values.fecha} <br/>
        <b>Hora:</b> ${values.hora} <br/>
        <b>Sede:</b> ${values.sede}
      `,
      icon: "question",
      showCancelButton: true,
      confirmButtonText: "Sí, guardar",
      cancelButtonText: "Cancelar",
      confirmButtonColor: "#28a745",
      cancelButtonColor: "#d33",
    }).then((result) => {
      if (result.isConfirmed) {
        const nuevoEntrenamiento = {
          id: entrenamientos.length + 1,
          ...values
        };
        setEntrenamientos([...entrenamientos, nuevoEntrenamiento]);
        Swal.fire("Guardado", "Entrenamiento agregado con éxito.", "success");
        form.reset();
      }
    });
  };

  const handlePartido = (e) => {
    e.preventDefault();
    const form = e.target;
    const data = new FormData(form);
    const values = Object.fromEntries(data.entries());
    
    if (!values.rival || !values.categoria || !values.fecha || !values.hora || !values.ubicacion || !values.cancha) {
      Swal.fire({
        icon: "warning",
        title: "Campos vacíos",
        text: "Todos los campos del partido son obligatorios.",
        confirmButtonColor: "#d33",
      });
      return;
    }

    if (values.cancha < 1 || values.cancha > 20) {
      Swal.fire({
        icon: "error",
        title: "Cancha inválida",
        text: "La cancha debe estar entre 1 y 20.",
      });
      return;
    }

    Swal.fire({
      title: "¿Confirmar Partido?",
      html: `
        <b>Rival:</b> ${values.rival} <br/>
        <b>Categoría:</b> ${values.categoria} <br/>
        <b>Fecha:</b> ${values.fecha} <br/>
        <b>Hora:</b> ${values.hora} <br/>
        <b>Ubicación:</b> ${values.ubicacion} <br/>
        <b>Cancha:</b> ${values.cancha}
      `,
      icon: "question",
      showCancelButton: true,
      confirmButtonText: "Sí, guardar",
      cancelButtonText: "Cancelar",
      confirmButtonColor: "#28a745",
      cancelButtonColor: "#d33",
    }).then((result) => {
      if (result.isConfirmed) {
        const nuevoPartido = {
          id: partidos.length + 1,
          ...values
        };
        setPartidos([...partidos, nuevoPartido]);
        Swal.fire("Guardado", "Partido agregado con éxito.", "success");
        form.reset();
      }
    });
  };

  return (
    <div>
         <meta charSet="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Cronograma - SCORD</title>
        {/* Bootstrap 5.2.3 */}
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossOrigin="anonymous" />
        <link rel="stylesheet" href="Css/InicioAdmin.css" />

      <header className="header bg-white shadow-sm py-3">
        <nav className="navbar container d-flex align-items-center justify-content-between flex-wrap">
          <div className="d-flex align-items-center">
            <img
              src="/Img/SCORD.png"
              alt="Logo SCORD"
              className="me-2"
              style={{ height: "50px" }}
            />
            <h4 className="mb-0 text-danger fw-bold">SCORD</h4>
          </div>
          <NavbarAdmin />
        </nav>
      </header>

      <main className="container my-5">
        <h1 className="text-center text-danger mb-4">Calendario de Actividades</h1>

        {/* Entrenamientos */}
        <section className="mb-5">
          <h2>Entrenamientos Programados</h2>
          <div className="table-responsive">
            <table className="table table-bordered align-middle text-center">
              <thead className="table-danger">
                <tr>
                  <th>Categoría</th>
                  <th>Fecha</th>
                  <th>Hora</th>
                  <th>Sede</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                {entrenamientos.map((entrenamiento) => (
                  <tr key={entrenamiento.id}>
                    <td>{entrenamiento.categoria}</td>
                    <td>{entrenamiento.fecha}</td>
                    <td>{entrenamiento.hora}</td>
                    <td>{entrenamiento.sede}</td>
                    <td>
                      <button
                        className="btn btn-sm btn-warning me-2"
                        onClick={() => handleEditarEntrenamiento(entrenamiento)}
                      >
                        <i class="bi bi-pencil-fill"></i>
                      </button>
                      <button
                        className="btn btn-sm btn-danger"
                        onClick={() => handleEliminarEntrenamiento(entrenamiento.id)}
                      >
                        <i class="bi bi-trash3"></i>
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="mt-4">
            <h4 className="mb-3">Agregar Entrenamiento</h4>
            <form onSubmit={handleEntrenamiento} className="row g-3">
              <div className="col-md-6">
                <label className="form-label">Categoría</label>
                <input type="text" className="form-control" name="categoria" required />
              </div>
              <div className="col-md-6">
                <label className="form-label">Fecha</label>
                <input type="date" className="form-control" name="fecha" required />
              </div>
              <div className="col-md-6">
                <label className="form-label">Hora</label>
                <input type="time" className="form-control" name="hora" required />
              </div>
              <div className="col-md-6">
                <label className="form-label">Sede</label>
                <select className="form-select" name="sede" required>
                  <option value="">Seleccione una sede</option>
                  <option value="TIMIZA">TIMIZA</option>
                  <option value="CAYETANO CAÑIZARES">CAYETANO CAÑIZARES</option>
                  <option value="FONTIBON">FONTIBON</option>
                </select>
              </div>
              <div className="col-12">
                <button type="submit" className="btn btn-danger">Agregar Entrenamiento</button>
              </div>
            </form>
          </div>
        </section>

        {/* Partidos */}
        <section className="mb-5">
          <h2>Partidos Programados</h2>
          <div className="table-responsive">
            <table className="table table-bordered align-middle text-center">
              <thead className="table-danger">
                <tr>
                  <th>Rival</th>
                  <th>Categoría</th>
                  <th>Fecha</th>
                  <th>Hora</th>
                  <th>Ubicación</th>
                  <th>Cancha</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                {partidos.map((partido) => (
                  <tr key={partido.id}>
                    <td>{partido.rival}</td>
                    <td>{partido.categoria}</td>
                    <td>{partido.fecha}</td>
                    <td>{partido.hora}</td>
                    <td>{partido.ubicacion}</td>
                    <td>{partido.cancha}</td>
                    <td>
                      <button
                        className="btn btn-sm btn-warning me-2"
                        onClick={() => handleEditarPartido(partido)}
                      >
                        <i class="bi bi-pencil-fill"></i>
                      </button>
                      <button
                        className="btn btn-sm btn-danger"
                        onClick={() => handleEliminarPartido(partido.id)}
                      >
                        <i class="bi bi-trash3"></i>
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="mt-4">
            <h4 className="mb-3">Agregar Partido</h4>
            <form onSubmit={handlePartido} className="row g-3">
              <div className="col-md-6">
                <label className="form-label">Rival</label>
                <input type="text" className="form-control" name="rival" required />
              </div>
              <div className="col-md-6">
                <label className="form-label">Categoría</label>
                <input type="text" className="form-control" name="categoria" required />
              </div>
              <div className="col-md-6">
                <label className="form-label">Fecha</label>
                <input type="date" className="form-control" name="fecha" required />
              </div>
              <div className="col-md-6">
                <label className="form-label">Hora</label>
                <input type="time" className="form-control" name="hora" required />
              </div>
              <div className="col-md-6">
                <label className="form-label">Ubicación</label>
                <select className="form-select" name="ubicacion" required>
                  <option value="">Seleccione una ubicación</option>
                  <option value="CONEJERA">CONEJERA</option>
                  <option value="XCOLI">XCOLI</option>
                  <option value="MORENA">MORENA</option>
                  <option value="SIBERIA">SIBERIA</option>
                </select>
              </div>
              <div className="col-md-6">
                <label className="form-label">Cancha</label>
                <input
                  type="number"
                  className="form-control"
                  name="cancha"
                  min={1}
                  max={20}
                  required
                />
              </div>
              <div className="col-12">
                <button type="submit" className="btn btn-danger">Agregar Partido</button>
              </div>
            </form>
          </div>
        </section>
      </main>
    </div>
  );
};

export default Cronograma;