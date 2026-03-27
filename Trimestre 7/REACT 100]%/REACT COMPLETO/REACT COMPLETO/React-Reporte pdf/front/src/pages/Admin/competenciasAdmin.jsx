import React, { useState, useEffect, useCallback } from "react";
import NavbarAdmin from "../../componentes/NavbarAdmin";
import api from "../../config/axiosConfig";
import Swal from "sweetalert2";

// ─── Utilidad: obtener categorías únicas de una competencia ───────────────────
const getCategorias = (comp) => {
  if (!comp.cronogramas || comp.cronogramas.length === 0) return [];
  return comp.cronogramas
    .filter((c) => c.categoria)
    .map((c) => c.categoria)
    .filter((cat, i, arr) => arr.findIndex((x) => x.idCategorias === cat.idCategorias) === i);
};

const EMPTY = { Nombre: "", TipoCompetencia: "", Ano: "" };

const CompetenciasAdmin = () => {
  const [competencias, setCompetencias] = useState([]);
  const [categorias,   setCategorias]   = useState([]);
  const [loading,      setLoading]      = useState(true);
  const [currentPage,  setCurrentPage]  = useState(1);
  const [totalPages,   setTotalPages]   = useState(1);
  const [totalItems,   setTotalItems]   = useState(0);

  // filtros de inputs (no aplicados aún)
  const [inputNombre, setInputNombre] = useState("");
  const [inputTipo,   setInputTipo]   = useState("");
  const [inputAno,    setInputAno]    = useState("");
  // filtros aplicados
  const [busqueda, setBusqueda] = useState({ nombre: "", tipo: "", ano: "", idCategorias: "" });

  // modal inline
  const [modoModal,    setModoModal]    = useState(null); // "crear" | "editar" | "ver"
  const [formData,     setFormData]     = useState({ ...EMPTY });
  const [compEditando, setCompEditando] = useState(null);
  const [loading2,     setLoading2]     = useState(false);

  // ── Carga categorías ──────────────────────────────────────────
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

  // ── Carga competencias ────────────────────────────────────────
  const cargarCompetencias = useCallback(async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams({ page: currentPage, sort_by: "idCompetencias", sort_order: "asc" });
      if (busqueda.nombre)       params.append("nombre",       busqueda.nombre);
      if (busqueda.tipo)         params.append("tipo",         busqueda.tipo);
      if (busqueda.ano)          params.append("ano",          busqueda.ano);
      if (busqueda.idCategorias) params.append("idCategorias", busqueda.idCategorias);

      const res = await api.get(`/competencias?${params}`);
      const data = res.data;
      setCompetencias(data.data ?? data);
      setTotalPages(data.meta?.last_page ?? 1);
      setTotalItems(data.meta?.total ?? (data.data ?? data).length);
    } catch (err) {
      console.error("Error al cargar competencias:", err);
      setCompetencias([]);
    } finally {
      setLoading(false);
    }
  }, [busqueda, currentPage]);

  useEffect(() => {
    cargarCompetencias();
  }, [cargarCompetencias]);

  // ── Filtros ───────────────────────────────────────────────────
  const aplicarBusqueda = () => {
    setBusqueda((p) => ({ ...p, nombre: inputNombre, tipo: inputTipo, ano: inputAno }));
    setCurrentPage(1);
  };

  const handleKeyDown = (e) => {
    if (e.key === "Enter") aplicarBusqueda();
  };

  const handleCategoria = (e) => {
    setBusqueda((p) => ({ ...p, idCategorias: e.target.value, nombre: inputNombre, tipo: inputTipo, ano: inputAno }));
    setCurrentPage(1);
  };

  const limpiarFiltros = () => {
    setInputNombre(""); setInputTipo(""); setInputAno("");
    setBusqueda({ nombre: "", tipo: "", ano: "", idCategorias: "" });
    setCurrentPage(1);
  };

  const hayFiltros = busqueda.nombre || busqueda.tipo || busqueda.ano || busqueda.idCategorias;

  // ── Modal helpers ─────────────────────────────────────────────
  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const abrirCrear = () => {
    setFormData({ ...EMPTY });
    setCompEditando(null);
    setModoModal("crear");
  };

  const abrirEditar = (comp) => {
    setFormData({ Nombre: comp.Nombre, TipoCompetencia: comp.TipoCompetencia, Ano: comp.Ano });
    setCompEditando(comp);
    setModoModal("editar");
  };

  const abrirVer = (comp) => {
    setCompEditando(comp);
    setModoModal("ver");
  };

  const cerrarModal = () => {
    setModoModal(null);
    setCompEditando(null);
    setFormData({ ...EMPTY });
  };

  const validarFormulario = () => {
    if (!formData.Nombre?.trim()) {
      Swal.fire({ icon: "warning", title: "Campo vacío", text: "El nombre es obligatorio.", confirmButtonColor: "#d33" });
      return false;
    }
    if (formData.Nombre.length > 50) {
      Swal.fire({ icon: "warning", title: "Campo inválido", text: "El nombre no puede superar 50 caracteres.", confirmButtonColor: "#d33" });
      return false;
    }
    if (!formData.TipoCompetencia?.trim()) {
      Swal.fire({ icon: "warning", title: "Campo vacío", text: "El tipo de competencia es obligatorio.", confirmButtonColor: "#d33" });
      return false;
    }
    if (formData.TipoCompetencia.length > 30) {
      Swal.fire({ icon: "warning", title: "Campo inválido", text: "El tipo no puede superar 30 caracteres.", confirmButtonColor: "#d33" });
      return false;
    }
    const ano = parseInt(formData.Ano);
    if (!formData.Ano || isNaN(ano) || ano < 1900 || ano > 2100) {
      Swal.fire({ icon: "warning", title: "Campo inválido", text: "Ingresa un año válido (1900–2100).", confirmButtonColor: "#d33" });
      return false;
    }
    return true;
  };

  // ── Crear ─────────────────────────────────────────────────────
  const crearCompetencia = async () => {
    if (!validarFormulario()) return;

    const confirm = await Swal.fire({
      title: "¿Crear competencia?",
      html: `<b>Nombre:</b> ${formData.Nombre}<br/><b>Tipo:</b> ${formData.TipoCompetencia}<br/><b>Año:</b> ${formData.Ano}`,
      icon: "question",
      showCancelButton: true,
      confirmButtonText: "Sí, crear",
      cancelButtonText: "Cancelar",
      confirmButtonColor: "#28a745",
      cancelButtonColor: "#d33",
    });
    if (!confirm.isConfirmed) return;

    setLoading2(true);
    try {
      await api.post("/competencias", {
        Nombre:          formData.Nombre.trim(),
        TipoCompetencia: formData.TipoCompetencia.trim(),
        Ano:             parseInt(formData.Ano),
      });
      cerrarModal();
      await Swal.fire({ icon: "success", title: "Competencia creada", confirmButtonColor: "#28a745" });
      cargarCompetencias();
    } catch (err) {
      console.error("Error al crear competencia:", err);
      Swal.fire({ icon: "error", title: "Error", text: "No se pudo crear la competencia.", confirmButtonColor: "#e63946" });
    } finally {
      setLoading2(false);
    }
  };

  // ── Editar ────────────────────────────────────────────────────
  const guardarCambios = async () => {
    if (!validarFormulario()) return;

    const confirm = await Swal.fire({
      title: "¿Guardar cambios?",
      html: `<b>Nombre:</b> ${formData.Nombre}<br/><b>Tipo:</b> ${formData.TipoCompetencia}<br/><b>Año:</b> ${formData.Ano}`,
      icon: "question",
      showCancelButton: true,
      confirmButtonText: "Sí, actualizar",
      cancelButtonText: "Cancelar",
      confirmButtonColor: "#28a745",
      cancelButtonColor: "#d33",
    });
    if (!confirm.isConfirmed) return;

    setLoading2(true);
    try {
      await api.put(`/competencias/${compEditando.idCompetencias}`, {
        Nombre:          formData.Nombre.trim(),
        TipoCompetencia: formData.TipoCompetencia.trim(),
        Ano:             parseInt(formData.Ano),
      });
      cerrarModal();
      await Swal.fire({ icon: "success", title: "Competencia actualizada", confirmButtonColor: "#28a745" });
      cargarCompetencias();
    } catch (err) {
      console.error("Error al actualizar competencia:", err);
      Swal.fire({ icon: "error", title: "Error", text: "No se pudo actualizar la competencia.", confirmButtonColor: "#e63946" });
    } finally {
      setLoading2(false);
    }
  };

  // ── Eliminar ──────────────────────────────────────────────────
  const eliminarCompetencia = (comp) => {
    Swal.fire({
      title: "¿Eliminar competencia?",
      text: `Se eliminará "${comp.Nombre}".`,
      icon: "warning",
      showCancelButton: true,
      confirmButtonText: "Sí, eliminar",
      cancelButtonText: "Cancelar",
      confirmButtonColor: "#d33",
      cancelButtonColor: "#28a745",
    }).then(async (result) => {
      if (!result.isConfirmed) return;
      try {
        await api.delete(`/competencias/${comp.idCompetencias}`);
        cargarCompetencias();
        Swal.fire({ icon: "success", title: "Competencia eliminada", confirmButtonColor: "#28a745" });
      } catch (err) {
        console.error("Error al eliminar competencia:", err);
        Swal.fire({ icon: "error", title: "Error", text: "No se pudo eliminar la competencia.", confirmButtonColor: "#e63946" });
      }
    });
  };

  // ── Paginación ────────────────────────────────────────────────
  const pageNumbers = [...Array(totalPages)].map((_, i) => i + 1);

  return (
    <div>
      <meta charSet="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Competencias - SCORD</title>
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

        <h2 className="text-danger fw-bold text-center mb-4">Gestión de Competencias</h2>

        {/* ── Filtros ── */}
        <div className="card shadow-sm mb-4">
          <div className="card-header bg-white d-flex justify-content-between align-items-center">
            <h6 className="mb-0 fw-bold text-secondary">Filtros de búsqueda</h6>
            {hayFiltros && (
              <button className="btn btn-outline-secondary btn-sm" onClick={limpiarFiltros}>
                ✕ Limpiar filtros
              </button>
            )}
          </div>
          <div className="card-body">
            <div className="row g-3 mb-3">
              <div className="col-md-3">
                <label className="form-label fw-semibold text-danger">Nombre</label>
                <input
                  type="text"
                  className="form-control"
                  placeholder="Buscar por nombre…"
                  value={inputNombre}
                  onChange={(e) => setInputNombre(e.target.value)}
                  onKeyDown={handleKeyDown}
                />
              </div>
              <div className="col-md-3">
                <label className="form-label fw-semibold text-danger">Tipo</label>
                <input
                  type="text"
                  className="form-control"
                  placeholder="Ej: Liga Regional"
                  value={inputTipo}
                  onChange={(e) => setInputTipo(e.target.value)}
                  onKeyDown={handleKeyDown}
                />
              </div>
              <div className="col-md-3">
                <label className="form-label fw-semibold text-danger">Año</label>
                <input
                  type="number"
                  className="form-control"
                  placeholder="2025"
                  value={inputAno}
                  onChange={(e) => setInputAno(e.target.value)}
                  onKeyDown={handleKeyDown}
                />
              </div>
              <div className="col-md-3">
                <label className="form-label fw-semibold text-danger">Categoría</label>
                <select
                  className="form-select"
                  value={busqueda.idCategorias}
                  onChange={handleCategoria}
                >
                  <option value="">Todas las categorías</option>
                  {categorias.map((c) => (
                    <option key={c.idCategorias} value={c.idCategorias}>{c.Descripcion}</option>
                  ))}
                </select>
              </div>
            </div>
            <div className="d-flex justify-content-between align-items-center flex-wrap gap-2">
              <small className="text-muted">
                Presiona <strong>Enter</strong> o el botón para buscar · La categoría aplica al instante
              </small>
              <button className="btn btn-danger fw-bold" onClick={aplicarBusqueda}>
                🔍 Buscar
              </button>
            </div>
          </div>
        </div>

        {/* ── Tabla ── */}
        <div className="card shadow-sm">
          <div className="card-header bg-white d-flex justify-content-between align-items-center">
            <h6 className="mb-0 fw-bold text-secondary">
              Historial de competencias
              {!loading && <span className="text-muted fw-normal ms-1">({totalItems})</span>}
            </h6>
            <button className="btn btn-success fw-bold" onClick={abrirCrear}>
              + Agregar
            </button>
          </div>
          <div className="card-body p-0">
            {loading ? (
              <div className="text-center py-5">
                <div className="spinner-border text-danger mb-2" role="status" />
                <p className="text-muted">Cargando…</p>
              </div>
            ) : competencias.length === 0 ? (
              <div className="text-center py-5 text-muted">
                <p className="fw-semibold mb-1">No hay competencias registradas</p>
                <small>{hayFiltros ? "Intenta con otros filtros." : "Presiona '+ Agregar' para crear la primera."}</small>
              </div>
            ) : (
              <div className="table-responsive">
                <table className="table table-hover mb-0">
                  <thead className="table-danger">
                    <tr>
                      <th>ID</th>
                      <th>Nombre</th>
                      <th>Tipo</th>
                      <th>Año</th>
                      <th>Categoría</th>
                      <th className="text-center">Acciones</th>
                    </tr>
                  </thead>
                  <tbody>
                    {competencias.map((c) => {
                      const cats = getCategorias(c);
                      return (
                        <tr key={c.idCompetencias}>
                          <td className="text-muted">#{c.idCompetencias}</td>
                          <td className="fw-bold">{c.Nombre}</td>
                          <td><span className="badge bg-secondary">{c.TipoCompetencia}</span></td>
                          <td>{c.Ano}</td>
                          <td>
                            {cats.length > 0
                              ? cats.map((cat) => (
                                  <span key={cat.idCategorias} className="badge bg-danger me-1">
                                    {cat.Descripcion}
                                  </span>
                                ))
                              : <span className="text-muted">—</span>
                            }
                          </td>
                          <td className="text-center">
                            <div className="d-flex gap-1 justify-content-center">
                              <button
                                className="btn btn-sm btn-outline-primary"
                                title="Ver detalle"
                                onClick={() => abrirVer(c)}
                              >
                                👁
                              </button>
                              <button
                                className="btn btn-sm btn-outline-warning"
                                title="Editar"
                                onClick={() => abrirEditar(c)}
                              >
                                ✏️
                              </button>
                              <button
                                className="btn btn-sm btn-outline-danger"
                                title="Eliminar"
                                onClick={() => eliminarCompetencia(c)}
                              >
                                🗑
                              </button>
                            </div>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            )}
          </div>

          {/* Paginación */}
          {!loading && competencias.length > 0 && (
            <div className="card-footer bg-white d-flex justify-content-between align-items-center flex-wrap gap-2">
              <small className="text-muted">Mostrando {competencias.length} de {totalItems}</small>
              <nav>
                <ul className="pagination pagination-sm mb-0">
                  <li className={`page-item${currentPage === 1 ? " disabled" : ""}`}>
                    <button className="page-link" onClick={() => setCurrentPage((p) => p - 1)}>‹</button>
                  </li>
                  {pageNumbers.map((n) => (
                    <li key={n} className={`page-item${currentPage === n ? " active" : ""}`}>
                      <button className="page-link" onClick={() => setCurrentPage(n)}>{n}</button>
                    </li>
                  ))}
                  <li className={`page-item${currentPage === totalPages ? " disabled" : ""}`}>
                    <button className="page-link" onClick={() => setCurrentPage((p) => p + 1)}>›</button>
                  </li>
                </ul>
              </nav>
            </div>
          )}
        </div>

        {/* ── Modal: Crear / Editar ── */}
        {(modoModal === "crear" || modoModal === "editar") && (
          <div className="modal show d-block" tabIndex="-1" style={{ background: "rgba(0,0,0,.45)" }}>
            <div className="modal-dialog modal-dialog-centered">
              <div className="modal-content">
                <div className="modal-header">
                  <h5 className="modal-title text-danger fw-bold">
                    {modoModal === "crear" ? "Nueva Competencia" : "Editar Competencia"}
                  </h5>
                  <button type="button" className="btn-close" onClick={cerrarModal} />
                </div>
                <div className="modal-body">
                  <div className="mb-3">
                    <label className="form-label fw-semibold text-danger">Nombre *</label>
                    <input
                      type="text"
                      name="Nombre"
                      className="form-control"
                      placeholder="Nombre de la competencia"
                      maxLength={50}
                      value={formData.Nombre}
                      onChange={handleChange}
                    />
                  </div>
                  <div className="mb-3">
                    <label className="form-label fw-semibold text-danger">Tipo de Competencia *</label>
                    <input
                      type="text"
                      name="TipoCompetencia"
                      className="form-control"
                      placeholder="Ej: Liga Regional"
                      maxLength={30}
                      value={formData.TipoCompetencia}
                      onChange={handleChange}
                    />
                  </div>
                  <div className="mb-3">
                    <label className="form-label fw-semibold text-danger">Año *</label>
                    <input
                      type="number"
                      name="Ano"
                      className="form-control"
                      placeholder="2025"
                      min={1900}
                      max={2100}
                      value={formData.Ano}
                      onChange={handleChange}
                    />
                  </div>
                </div>
                <div className="modal-footer">
                  <button className="btn btn-secondary fw-bold" onClick={cerrarModal} disabled={loading2}>
                    Cancelar
                  </button>
                  <button
                    className="btn btn-success fw-bold"
                    onClick={modoModal === "crear" ? crearCompetencia : guardarCambios}
                    disabled={loading2}
                  >
                    {loading2 ? "Guardando..." : modoModal === "crear" ? "Crear Competencia" : "Guardar Cambios"}
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* ── Modal: Ver detalle ── */}
        {modoModal === "ver" && compEditando && (
          <div className="modal show d-block" tabIndex="-1" style={{ background: "rgba(0,0,0,.45)" }}>
            <div className="modal-dialog modal-dialog-centered">
              <div className="modal-content">
                <div className="modal-header">
                  <h5 className="modal-title text-danger fw-bold">Detalle de Competencia</h5>
                  <button type="button" className="btn-close" onClick={cerrarModal} />
                </div>
                <div className="modal-body">
                  <ul className="list-group list-group-flush">
                    <li className="list-group-item d-flex justify-content-between align-items-center">
                      <span className="text-danger fw-semibold">Nombre:</span>
                      <span>{compEditando.Nombre}</span>
                    </li>
                    <li className="list-group-item d-flex justify-content-between align-items-center">
                      <span className="text-danger fw-semibold">Tipo:</span>
                      <span>{compEditando.TipoCompetencia}</span>
                    </li>
                    <li className="list-group-item d-flex justify-content-between align-items-center">
                      <span className="text-danger fw-semibold">Año:</span>
                      <span>{compEditando.Ano}</span>
                    </li>
                    <li className="list-group-item d-flex justify-content-between align-items-start">
                      <span className="text-danger fw-semibold">Categorías:</span>
                      <div className="d-flex flex-wrap gap-1 justify-content-end">
                        {getCategorias(compEditando).length > 0
                          ? getCategorias(compEditando).map((cat) => (
                              <span key={cat.idCategorias} className="badge bg-danger">
                                {cat.Descripcion}
                              </span>
                            ))
                          : <span className="text-muted">Sin categoría asignada</span>
                        }
                      </div>
                    </li>
                  </ul>
                </div>
                <div className="modal-footer">
                  <button className="btn btn-secondary fw-bold" onClick={cerrarModal}>Cerrar</button>
                </div>
              </div>
            </div>
          </div>
        )}

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

export default CompetenciasAdmin;