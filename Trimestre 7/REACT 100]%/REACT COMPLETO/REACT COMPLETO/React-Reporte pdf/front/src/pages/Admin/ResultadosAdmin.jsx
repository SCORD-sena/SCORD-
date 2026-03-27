import React, { useState, useEffect, useCallback } from "react";
import NavbarAdmin from "../../componentes/NavbarAdmin";
import api from "../../config/axiosConfig";
import Swal from "sweetalert2";

const GestionResultados = () => {
  const [categorias,  setCategorias]  = useState([]);
  const [competencias,setCompetencias]= useState([]);
  const [partidos,    setPartidos]    = useState([]);
  const [resultados,  setResultados]  = useState([]);

  const [catSel,  setCatSel]  = useState("");
  const [compSel, setCompSel] = useState("");
  const [partSel, setPartSel] = useState("");

  const [modoEdicion,           setModoEdicion]           = useState(false);
  const [resultadoSeleccionado, setResultadoSeleccionado] = useState(null);
  const [loading,               setLoading]               = useState(false);

  const [formData, setFormData] = useState({
    Marcador: "",
    PuntosObtenidos: "",
    Observacion: "",
  });

  // ── Carga inicial ──────────────────────────────────────────────
  useEffect(() => {
    fetchCategorias();
  }, []);

  const fetchCategorias = async () => {
    try {
      const res = await api.get("/categorias");
      setCategorias(res.data.data || res.data);
    } catch (err) {
      console.error("Error al cargar categorías:", err);
    }
  };

  // ── Categoría → competencias filtradas ────────────────────────
  const handleCatChange = async (val) => {
    setCatSel(val);
    setCompSel(""); setPartSel("");
    setCompetencias([]); setPartidos([]); setResultados([]);
    setResultadoSeleccionado(null); setModoEdicion(false);
    if (!val) return;
    try {
      const res = await api.get(`/competencias/categoria/${val}`);
      setCompetencias(res.data.data || res.data);
    } catch (err) {
      console.error("Error al cargar competencias:", err);
    }
  };

  // ── Competencia → partidos filtrados ──────────────────────────
  const handleCompChange = async (val) => {
    setCompSel(val);
    setPartSel(""); setPartidos([]); setResultados([]);
    setResultadoSeleccionado(null); setModoEdicion(false);
    if (!val) return;
    try {
      const [resCron, resPart] = await Promise.all([
        api.get(`/cronogramas?idCompetencias=${val}&tipo=Partido`),
        api.get("/partidos"),
      ]);
      const cronList = resCron.data.data || resCron.data;
      const partList = resPart.data.data || resPart.data;
      const cronIds  = new Set(cronList.map((c) => c.idCronogramas));
      setPartidos(partList.filter((p) => cronIds.has(p.idCronogramas)));
    } catch (err) {
      console.error("Error al cargar partidos:", err);
    }
  };

  // ── Partido → resultados ───────────────────────────────────────
  const handlePartChange = async (val) => {
    setPartSel(val);
    setResultados([]); setResultadoSeleccionado(null); setModoEdicion(false);
    if (!val) return;
    await fetchResultados(val);
  };

  const fetchResultados = useCallback(async (idPartido) => {
    try {
      const res  = await api.get(`/resultados?idPartidos=${idPartido}`);
      const lista = res.data.data || res.data;
      setResultados(lista.filter((r) => String(r.idPartidos) === String(idPartido)));
    } catch (err) {
      console.error("Error al cargar resultados:", err);
    }
  }, []);

  // ── Formulario ─────────────────────────────────────────────────
  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const activarEdicion = () => {
    if (!resultadoSeleccionado) {
      Swal.fire({ icon: "warning", title: "Sin selección", text: "Selecciona un resultado de la tabla primero.", confirmButtonColor: "#e63946" });
      return;
    }
    setFormData({
      Marcador:        resultadoSeleccionado.Marcador        || "",
      PuntosObtenidos: resultadoSeleccionado.PuntosObtenidos || "",
      Observacion:     resultadoSeleccionado.Observacion     || "",
    });
    setModoEdicion(true);
  };

  const cancelarEdicion = () => {
    setModoEdicion(false);
    setFormData({ Marcador: "", PuntosObtenidos: "", Observacion: "" });
  };

  const validarFormulario = () => {
    if (!formData.Marcador.trim()) {
      Swal.fire({ icon: "warning", title: "Campo vacío", text: "El marcador es obligatorio.", confirmButtonColor: "#d33" });
      return false;
    }
    if (formData.Marcador.length > 10) {
      Swal.fire({ icon: "warning", title: "Campo inválido", text: "El marcador no puede superar 10 caracteres.", confirmButtonColor: "#d33" });
      return false;
    }
    if (formData.PuntosObtenidos === "" || isNaN(parseInt(formData.PuntosObtenidos))) {
      Swal.fire({ icon: "warning", title: "Campo vacío", text: "Los puntos obtenidos son obligatorios y deben ser un número.", confirmButtonColor: "#d33" });
      return false;
    }
    if (formData.Observacion && formData.Observacion.length > 100) {
      Swal.fire({ icon: "warning", title: "Campo inválido", text: "La observación no puede superar 100 caracteres.", confirmButtonColor: "#d33" });
      return false;
    }
    return true;
  };

  // ── Agregar ────────────────────────────────────────────────────
  const agregarResultado = async () => {
    if (!partSel) {
      Swal.fire({ icon: "warning", title: "Sin partido", text: "Selecciona un partido primero.", confirmButtonColor: "#e63946" });
      return;
    }
    if (!validarFormulario()) return;

    const confirm = await Swal.fire({
      title: "¿Agregar resultado?",
      html: `<b>Marcador:</b> ${formData.Marcador}<br/><b>Puntos:</b> ${formData.PuntosObtenidos}`,
      icon: "question",
      showCancelButton: true,
      confirmButtonText: "Sí, agregar",
      cancelButtonText: "Cancelar",
      confirmButtonColor: "#28a745",
      cancelButtonColor: "#d33",
    });
    if (!confirm.isConfirmed) return;

    setLoading(true);
    try {
      await api.post("/resultados", {
        Marcador:        formData.Marcador.trim(),
        PuntosObtenidos: parseInt(formData.PuntosObtenidos),
        Observacion:     formData.Observacion?.trim() || null,
        idPartidos:      parseInt(partSel),
      });
      await Swal.fire({ icon: "success", title: "Resultado agregado", confirmButtonColor: "#28a745" });
      setFormData({ Marcador: "", PuntosObtenidos: "", Observacion: "" });
      await fetchResultados(partSel);
    } catch (err) {
      console.error("Error al agregar resultado:", err);
      Swal.fire({ icon: "error", title: "Error", text: "No se pudo agregar el resultado.", confirmButtonColor: "#e63946" });
    } finally {
      setLoading(false);
    }
  };

  // ── Editar ─────────────────────────────────────────────────────
  const guardarCambios = async () => {
    if (!validarFormulario()) return;

    const confirm = await Swal.fire({
      title: "¿Guardar cambios?",
      html: `<b>Marcador:</b> ${formData.Marcador}<br/><b>Puntos:</b> ${formData.PuntosObtenidos}`,
      icon: "question",
      showCancelButton: true,
      confirmButtonText: "Sí, actualizar",
      cancelButtonText: "Cancelar",
      confirmButtonColor: "#28a745",
      cancelButtonColor: "#d33",
    });
    if (!confirm.isConfirmed) return;

    setLoading(true);
    try {
      await api.put(`/resultados/${resultadoSeleccionado.idResultados}`, {
        Marcador:        formData.Marcador.trim(),
        PuntosObtenidos: parseInt(formData.PuntosObtenidos),
        Observacion:     formData.Observacion?.trim() || null,
      });
      await Swal.fire({ icon: "success", title: "Resultado actualizado", confirmButtonColor: "#28a745" });
      setModoEdicion(false);
      await fetchResultados(partSel);
    } catch (err) {
      console.error("Error al actualizar resultado:", err);
      Swal.fire({ icon: "error", title: "Error", text: "No se pudo actualizar el resultado.", confirmButtonColor: "#e63946" });
    } finally {
      setLoading(false);
    }
  };

  // ── Eliminar ───────────────────────────────────────────────────
  const eliminarResultado = () => {
    if (!resultadoSeleccionado) {
      Swal.fire({ icon: "warning", title: "Sin selección", text: "Selecciona un resultado de la tabla primero.", confirmButtonColor: "#e63946" });
      return;
    }
    Swal.fire({
      title: "¿Eliminar resultado?",
      text: `Se eliminará el resultado "${resultadoSeleccionado.Marcador}".`,
      icon: "warning",
      showCancelButton: true,
      confirmButtonText: "Sí, eliminar",
      cancelButtonText: "Cancelar",
      confirmButtonColor: "#d33",
      cancelButtonColor: "#28a745",
    }).then(async (result) => {
      if (!result.isConfirmed) return;
      try {
        await api.delete(`/resultados/${resultadoSeleccionado.idResultados}`);
        setResultadoSeleccionado(null);
        await fetchResultados(partSel);
        Swal.fire({ icon: "success", title: "Resultado eliminado", confirmButtonColor: "#28a745" });
      } catch (err) {
        console.error("Error al eliminar resultado:", err);
        Swal.fire({ icon: "error", title: "Error", text: "No se pudo eliminar el resultado.", confirmButtonColor: "#e63946" });
      }
    });
  };

  const partidoInfo = partidos.find((p) => p.idPartidos === parseInt(partSel));

  return (
    <div>
      <meta charSet="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Resultados - SCORD</title>
      <link
        href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css"
        rel="stylesheet"
        integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65"
        crossOrigin="anonymous"
      />
      <link rel="stylesheet" href="/Css/InicioAdmin.css" />

      {/* ── HEADER ── */}
      <header className="header bg-white shadow-sm py-3">
        <nav className="navbar container d-flex align-items-center justify-content-between flex-wrap">
          <div className="d-flex align-items-center">
            <img src="/Img/SCORD.png" alt="Logo SCORD" className="me-2" style={{ height: "60px" }} />
            <h4 className="mb-0 text-danger fw-bold">SCORD</h4>
          </div>
          <label className="labe_hamburguesa d-md-none" htmlFor="menu_hamburguesa">
            <svg xmlns="http://www.w3.org/2000/svg" width={35} height={35} fill="#e63946" viewBox="0 0 16 16">
              <path fillRule="evenodd" d="M2.5 12a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5z" />
            </svg>
          </label>
          <input className="menu_hamburguesa d-none" type="checkbox" id="menu_hamburguesa" />
          <NavbarAdmin />
        </nav>
      </header>

      {/* ── MAIN ── */}
      <main className="container my-4">

        <h2 className="text-danger fw-bold text-center mb-4">Gestión de Resultados</h2>

        {/* Botones de acción */}
        <div className="d-flex justify-content-center mb-4 gap-2 flex-wrap">
          {!modoEdicion ? (
            <>
              <button className="btn btn-success fw-bold" onClick={agregarResultado} disabled={!partSel || loading}>
                Agregar Resultado
              </button>
              <button className="btn btn-warning fw-bold" onClick={activarEdicion} disabled={!resultadoSeleccionado}>
                Editar Resultado
              </button>
              <button className="btn btn-danger fw-bold" onClick={eliminarResultado} disabled={!resultadoSeleccionado}>
                Eliminar Resultado
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

        <div className="row g-4 align-items-start">

          {/* ── Izquierda: filtros + formulario ── */}
          <div className="col-md-4">
            <section className="card p-4 shadow-sm">

              <div className="mb-3">
                <label className="form-label fw-semibold text-danger">1. Seleccionar Categoría:</label>
                <select
                  className="form-select"
                  value={catSel}
                  onChange={(e) => handleCatChange(e.target.value)}
                  disabled={modoEdicion}
                >
                  <option value="">-- Selecciona una categoría --</option>
                  {categorias.map((c) => (
                    <option key={c.idCategorias} value={c.idCategorias}>{c.Descripcion}</option>
                  ))}
                </select>
              </div>

              <div className="mb-3">
                <label className="form-label fw-semibold text-danger">2. Seleccionar Competencia:</label>
                <select
                  className="form-select"
                  value={compSel}
                  onChange={(e) => handleCompChange(e.target.value)}
                  disabled={!catSel || modoEdicion}
                >
                  <option value="">-- Selecciona una competencia --</option>
                  {competencias.map((c) => (
                    <option key={c.idCompetencias} value={c.idCompetencias}>
                      {c.Nombre} ({c.Ano})
                    </option>
                  ))}
                </select>
                {catSel && competencias.length === 0 && (
                  <small className="text-warning">No hay competencias para esta categoría.</small>
                )}
              </div>

              <div className="mb-3">
                <label className="form-label fw-semibold text-danger">3. Seleccionar Partido:</label>
                <select
                  className="form-select"
                  value={partSel}
                  onChange={(e) => handlePartChange(e.target.value)}
                  disabled={!compSel || modoEdicion}
                >
                  <option value="">-- Selecciona un partido --</option>
                  {partidos.map((p) => (
                    <option key={p.idPartidos} value={p.idPartidos}>
                      vs {p.EquipoRival} — {p.Formacion}
                    </option>
                  ))}
                </select>
                {compSel && partidos.length === 0 && (
                  <small className="text-warning">No hay partidos para esta competencia.</small>
                )}
              </div>

              {/* Formulario agregar / editar */}
              {(partSel || modoEdicion) && (
                <div className="border-top pt-3 mt-2">
                  <h6 className="text-danger fw-bold mb-3">
                    {modoEdicion ? "Editar Resultado" : "Nuevo Resultado"}
                  </h6>

                  <div className="mb-2">
                    <label className="form-label fw-semibold text-danger">Marcador *</label>
                    <input
                      type="text"
                      name="Marcador"
                      className="form-control"
                      placeholder="Ej: 3-1"
                      maxLength={10}
                      value={formData.Marcador}
                      onChange={handleChange}
                    />
                  </div>

                  <div className="mb-2">
                    <label className="form-label fw-semibold text-danger">Puntos Obtenidos *</label>
                    <input
                      type="number"
                      name="PuntosObtenidos"
                      className="form-control"
                      placeholder="Ej: 3"
                      min={0}
                      value={formData.PuntosObtenidos}
                      onChange={handleChange}
                    />
                  </div>

                  <div className="mb-2">
                    <label className="form-label fw-semibold text-danger">
                      Observación <span className="text-muted fw-normal">(opcional)</span>
                    </label>
                    <textarea
                      name="Observacion"
                      className="form-control"
                      placeholder="Comentarios adicionales…"
                      maxLength={100}
                      rows={3}
                      value={formData.Observacion}
                      onChange={handleChange}
                    />
                    <small className="text-muted">{formData.Observacion.length}/100</small>
                  </div>
                </div>
              )}

            </section>
          </div>

          {/* ── Derecha: tabla de resultados ── */}
          <div className="col-md-8">
            <section className="card shadow-sm">
              <div className="card-header bg-white d-flex justify-content-between align-items-center">
                <h5 className="mb-0 text-danger fw-bold">
                  {partidoInfo ? `Resultados — vs ${partidoInfo.EquipoRival}` : "Resultados del partido"}
                </h5>
                {resultados.length > 0 && (
                  <span className="badge bg-danger">{resultados.length} registro{resultados.length !== 1 ? "s" : ""}</span>
                )}
              </div>
              <div className="card-body p-0">
                {!partSel ? (
                  <div className="text-center py-5 text-muted">
                    <p className="mb-1 fw-semibold">Selecciona un partido</p>
                    <small>Usa los filtros: categoría → competencia → partido</small>
                  </div>
                ) : resultados.length === 0 ? (
                  <div className="text-center py-5 text-muted">
                    <p className="mb-1 fw-semibold">No hay resultados registrados</p>
                    <small>Completa el formulario y presiona "Agregar Resultado"</small>
                  </div>
                ) : (
                  <div className="table-responsive">
                    <table className="table table-hover mb-0">
                      <thead className="table-danger">
                        <tr>
                          <th>Marcador</th>
                          <th className="text-center">Puntos</th>
                          <th>Observación</th>
                          <th className="text-center">Seleccionar</th>
                        </tr>
                      </thead>
                      <tbody>
                        {resultados.map((r) => (
                          <tr
                            key={r.idResultados}
                            className={resultadoSeleccionado?.idResultados === r.idResultados ? "table-warning" : ""}
                            style={{ cursor: "pointer" }}
                            onClick={() => { setResultadoSeleccionado(r); setModoEdicion(false); }}
                          >
                            <td className="fw-bold">{r.Marcador}</td>
                            <td className="text-center">{r.PuntosObtenidos}</td>
                            <td><span className="text-muted fst-italic">{r.Observacion || "—"}</span></td>
                            <td className="text-center">
                              <input
                                type="radio"
                                checked={resultadoSeleccionado?.idResultados === r.idResultados}
                                onChange={() => { setResultadoSeleccionado(r); setModoEdicion(false); }}
                              />
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </div>
            </section>
          </div>

        </div>
      </main>

      {/* ── FOOTER ── */}
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

export default GestionResultados;