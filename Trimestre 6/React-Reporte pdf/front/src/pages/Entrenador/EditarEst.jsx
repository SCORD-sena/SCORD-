import React from "react";
import Swal from "sweetalert2";
import NavbarAdmin from "../../componentes/NavbarAdmin";
import NavbarEntrenador from "../../componentes/NavbarEntrenador";

const EditarEst = () => {
  const editarEstadistica = (e) => {
    e.preventDefault();
    const form = e.target;
    const data = new FormData(form);
    const values = Object.fromEntries(data.entries());

    // Etiquetas de campos
    const labels = {
      goles: "Goles",
      asistencias: "Asistencias",
      partidos: "Partidos",
      minutos: "Minutos",
      golesCabeza: "Goles de Cabeza",
      golesPartido: "Goles por Partido",
      tirosPuerta: "Tiros a Puerta",
      fuerasJuego: "Fueras de Juego",
      tarjetasAmarillas: "Tarjetas Amarillas",
      tarjetasRojas: "Tarjetas Rojas",
      arcoCero: "Arco en Cero",
      categoria: "Categoría",
    };

    // Validación: campos obligatorios
    for (const key in labels) {
      const val = (values[key] ?? "").toString().trim();
      if (!val) {
        Swal.fire({
          icon: "warning",
          title: "Campo vacío",
          text: `El campo "${labels[key]}" es obligatorio.`,
          confirmButtonColor: "#d33",
        });
        return;
      }
    }

    // Validación: no permitir negativos
    const numeros = [
      "goles",
      "asistencias",
      "partidos",
      "minutos",
      "golesCabeza",
      "golesPartido",
      "tirosPuerta",
      "fuerasJuego",
      "tarjetasAmarillas",
      "tarjetasRojas",
      "arcoCero",
    ];

    for (const num of numeros) {
      const valor = parseInt(values[num], 10);
      if (isNaN(valor) || valor < 0) {
        Swal.fire({
          icon: "error",
          title: "Valor inválido",
          text: `El campo "${labels[num]}" no puede ser negativo.`,
          confirmButtonColor: "#d33",
        });
        return;
      }
    }

    // Confirmación antes de guardar
    Swal.fire({
      title: "¿Guardar Estadística?",
      html: `
        <b>${labels.goles}:</b> ${values.goles}<br/>
        <b>${labels.asistencias}:</b> ${values.asistencias}<br/>
        <b>${labels.partidos}:</b> ${values.partidos}<br/>
        <b>${labels.minutos}:</b> ${values.minutos}<br/>
        <b>${labels.categoria}:</b> ${values.categoria}<br/>
      `,
      icon: "question",
      showCancelButton: true,
      confirmButtonText: "Sí, guardar",
      cancelButtonText: "Cancelar",
      confirmButtonColor: "#28a745",
      cancelButtonColor: "#d33",
    }).then((result) => {
      if (result.isConfirmed) {
        Swal.fire({
          icon: "success",
          title: "Estadística guardada",
          text: "Los datos se registraron correctamente.",
          confirmButtonColor: "#28a745",
        });
        form.reset();
      }
    });
  };

  return (
    <div>
        <meta charSet="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Inicio - SCORD</title>
        {/* Bootstrap 5.2.3 */}
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossOrigin="anonymous" />
        <link rel="stylesheet" href="/Css/InicioAdmin.css" />
      <header className="header bg-white shadow-sm py-3">
        <nav className="navbar container d-flex align-items-center justify-content-between flex-wrap">
          <div className="d-flex align-items-center">
            <img src="/Img/SCORD.png" alt="Logo SCORD" className="me-2" style={{ height: "60px" }} />
            <h4 className="mb-0 text-danger fw-bold">SCORD</h4>
          </div>
          <NavbarEntrenador/>
        </nav>
      </header>

      {/* Formulario */}
      <main className="container my-5">
        <div className="text-center mb-4">
          <h1 className="text-danger">Editar Registro Estadístico</h1>
        </div>

        <form onSubmit={editarEstadistica}>
          <div className="row">
            {/* Columna izquierda */}
            <div className="col-md-6">
              <div className="mb-3">
                <label className="form-label">⚽ Goles</label>
                <input type="number" name="goles" className="form-control" min="0" />
              </div>
              <div className="mb-3">
                <label className="form-label">🎯 Asistencias</label>
                <input type="number" name="asistencias" className="form-control" min="0" />
              </div>
              <div className="mb-3">
                <label className="form-label">📋 Partidos</label>
                <input type="number" name="partidos" className="form-control" min="0" />
              </div>
              <div className="mb-3">
                <label className="form-label">⏱️ Minutos</label>
                <input type="number" name="minutos" className="form-control" min="0" />
              </div>
              <div className="mb-3">
                <label className="form-label">⚽ Goles de Cabeza</label>
                <input type="number" name="golesCabeza" className="form-control" min="0" />
              </div>
              <div className="mb-3">
                <label className="form-label">📊 Goles por Partido</label>
                <input type="number" name="golesPartido" className="form-control" min="0" />
              </div>
            </div>

            {/* Columna derecha */}
            <div className="col-md-6">
              <div className="mb-3">
                <label className="form-label">🎯 Tiros a puerta</label>
                <input type="number" name="tirosPuerta" className="form-control" min="0" />
              </div>
              <div className="mb-3">
                <label className="form-label">🚩 Fueras de Juego</label>
                <input type="number" name="fuerasJuego" className="form-control" min="0" />
              </div>
              <div className="mb-3">
                <label className="form-label">🟨 Tarjetas Amarillas</label>
                <input type="number" name="tarjetasAmarillas" className="form-control" min="0" />
              </div>
              <div className="mb-3">
                <label className="form-label">🟥 Tarjetas Rojas</label>
                <input type="number" name="tarjetasRojas" className="form-control" min="0" />
              </div>
              <div className="mb-3">
                <label className="form-label">🧤 Arco en cero</label>
                <input type="number" name="arcoCero" className="form-control" min="0" />
              </div>
            </div>
          </div>

          {/* Botones */}
          <div className="mt-4 d-flex justify-content-center gap-3">
            <button type="submit" className="btn btn-success px-4">Guardar</button>
            <button type="button" className="btn btn-danger px-4" onClick={() => Swal.fire({
              icon: "info",
              title: "Cancelado",
              text: "No se guardaron los datos.",
              confirmButtonColor: "#d33",
            })}>Cancelar</button>
          </div>
        </form>
      </main>
    </div>
  );
};

export default EditarEst;