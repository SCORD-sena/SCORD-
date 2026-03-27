import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import NavbarAdmin from "../../componentes/NavbarAdmin";

const CompetenciasAdmin = () => {
  const navigate = useNavigate();
  const [categorias, setCategorias] = useState([]);
  const [competencias, setCompetencias] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalItems, setTotalItems] = useState(0);

  const [filtros, setFiltros] = useState({
    nombre: "",
    tipo: "",
    ano: "",
    idCategorias: "",
    sort_by: "idCompetencias",
    sort_order: "asc"
  });

  const [showModal, setShowModal] = useState(false);
  const [modalMode, setModalMode] = useState("crear");
  const [selectedCompetencia, setSelectedCompetencia] = useState({
    idCompetencias: "",
    Nombre: "",
    TipoCompetencia: "",
    Ano: "",
    idCategorias: ""
  });
  const [errors, setErrors] = useState({});

  useEffect(() => {
    cargarCategorias();
  }, []);

  useEffect(() => {
    cargarCompetencias();
  }, [filtros, currentPage]);

  const cargarCategorias = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch('http://127.0.0.1:8000/api/categorias', {
        headers: { Authorization: `Bearer ${token}` }
      });
      if (response.ok) {
        const data = await response.json();
        setCategorias(data.data ?? data);
      }
    } catch (err) {
      console.error('Error al cargar categorías:', err);
    }
  };

  const cargarCompetencias = async () => {
    try {
      setLoading(true);
      const token = localStorage.getItem('token');
      const params = new URLSearchParams();
      params.append('page', currentPage);
      if (filtros.nombre) params.append('nombre', filtros.nombre);
      if (filtros.tipo) params.append('tipo', filtros.tipo);
      if (filtros.ano) params.append('ano', filtros.ano);
      if (filtros.idCategorias) params.append('idCategorias', filtros.idCategorias);
      params.append('sort_by', filtros.sort_by);
      params.append('sort_order', filtros.sort_order);

      const response = await fetch(`http://127.0.0.1:8000/api/competencias?${params}`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (response.ok) {
        const data = await response.json();
        setCompetencias(data.data || []);
        setTotalPages(data.meta?.last_page || 1);
        setTotalItems(data.meta?.total || 0);
        setError(null);
      } else if (response.status === 404) {
        setCompetencias([]);
        setTotalPages(1);
        setTotalItems(0);
        setError('No se encontraron competencias');
      } else {
        throw new Error('Error al cargar competencias');
      }
    } catch (err) {
      setError(err.message);
      setCompetencias([]);
    } finally {
      setLoading(false);
    }
  };

  const handleFiltroChange = (e) => {
    const { name, value } = e.target;
    setFiltros(prev => ({ ...prev, [name]: value }));
    setCurrentPage(1);
  };

  const limpiarFiltros = () => {
    setFiltros({
      nombre: "",
      tipo: "",
      ano: "",
      idCategorias: "",
      sort_by: "idCompetencias",
      sort_order: "asc"
    });
    setCurrentPage(1);
  };

  const abrirModal = (mode, competencia = null) => {
    setModalMode(mode);
    if (competencia) {
      setSelectedCompetencia({
        idCompetencias: competencia.idCompetencias,
        Nombre: competencia.Nombre,
        TipoCompetencia: competencia.TipoCompetencia,
        Ano: competencia.Ano,
        idCategorias: competencia.idCategorias || competencia.categoria?.idCategorias || ""
      });
    } else {
      setSelectedCompetencia({
        idCompetencias: "",
        Nombre: "",
        TipoCompetencia: "",
        Ano: "",
        idCategorias: ""
      });
    }
    setErrors({});
    setShowModal(true);
  };

  const cerrarModal = () => {
    setShowModal(false);
    setSelectedCompetencia({
      idCompetencias: "",
      Nombre: "",
      TipoCompetencia: "",
      Ano: "",
      idCategorias: ""
    });
    setErrors({});
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setSelectedCompetencia(prev => ({ ...prev, [name]: value }));
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: "" }));
    }
  };

  const validarFormulario = () => {
    const newErrors = {};

    if (!selectedCompetencia.Nombre || selectedCompetencia.Nombre.trim() === "") {
      newErrors.Nombre = "El nombre es requerido";
    } else if (selectedCompetencia.Nombre.length > 50) {
      newErrors.Nombre = "El nombre no puede exceder 50 caracteres";
    }

    if (!selectedCompetencia.TipoCompetencia || selectedCompetencia.TipoCompetencia.trim() === "") {
      newErrors.TipoCompetencia = "El tipo de competencia es requerido";
    } else if (selectedCompetencia.TipoCompetencia.length > 30) {
      newErrors.TipoCompetencia = "El tipo no puede exceder 30 caracteres";
    }

    if (!selectedCompetencia.Ano || selectedCompetencia.Ano === "") {
      newErrors.Ano = "El año es requerido";
    } else {
      const ano = parseInt(selectedCompetencia.Ano);
      if (isNaN(ano) || ano < 1900 || ano > 2100) {
        newErrors.Ano = "Ingrese un año válido (1900-2100)";
      }
    }

    if (!selectedCompetencia.idCategorias || selectedCompetencia.idCategorias === "" || selectedCompetencia.idCategorias === "0") {
      newErrors.idCategorias = "Debe seleccionar una categoría";
    } else {
      const catId = parseInt(selectedCompetencia.idCategorias);
      if (isNaN(catId) || catId <= 0) {
        newErrors.idCategorias = "Debe seleccionar una categoría válida";
      }
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!validarFormulario()) {
      console.log("Validación fallida:", errors);
      alert("❌ Por favor complete todos los campos requeridos");
      return;
    }

    try {
      const token = localStorage.getItem('token');
      const url = modalMode === "crear"
        ? 'http://127.0.0.1:8000/api/competencias'
        : `http://127.0.0.1:8000/api/competencias/${selectedCompetencia.idCompetencias}`;
      const method = modalMode === "crear" ? 'POST' : 'PUT';
      const idCategorias = Number.parseInt(selectedCompetencia.idCategorias);
      const ano = Number.parseInt(selectedCompetencia.Ano);

      if (isNaN(idCategorias) || idCategorias <= 0) {
        alert("❌ Error: Debe seleccionar una categoría válida");
        return;
      }

      if (isNaN(ano) || ano < 1900 || ano > 2100) {
        alert("❌ Error: Debe ingresar un año válido");
        return;
      }

      const datosEnviar = {
        Nombre: selectedCompetencia.Nombre.trim(),
        TipoCompetencia: selectedCompetencia.TipoCompetencia.trim(),
        Ano: ano,
        idCategorias: idCategorias
      };

      const response = await fetch(url, {
        method: method,
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify(datosEnviar)
      });

      const contentType = response.headers.get('content-type');

      if (contentType?.includes('application/json')) {
        const data = await response.json();

        if (response.ok) {
          cerrarModal();
          cargarCompetencias();
          alert(modalMode === "crear" ? '✅ Competencia creada exitosamente' : '✅ Competencia actualizada exitosamente');
        } else if (data.errors) {
          const formattedErrors = {};
          Object.keys(data.errors).forEach(key => {
            formattedErrors[key] = Array.isArray(data.errors[key])
              ? data.errors[key][0]
              : data.errors[key];
          });
          setErrors(formattedErrors);
          alert('❌ Errores de validación. Revisa los campos.');
        } else {
          alert('❌ Error: ' + (data.message || 'Error desconocido'));
        }
      } else {
        const htmlText = await response.text();
        console.error("=== ERROR DEL SERVIDOR ===");
        console.error(htmlText);
        alert('❌ Error 500 del servidor. Revisa la consola para más detalles.');
      }
    } catch (err) {
      console.error('Error completo:', err);
      alert('❌ Error de conexión: ' + err.message);
    }
  };

  const handleEliminar = async (id) => {
    if (!window.confirm('⚠️ ¿Está seguro de eliminar esta competencia?')) return;
    try {
      const token = localStorage.getItem('token');
      const response = await fetch(`http://127.0.0.1:8000/api/competencias/${id}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });
      if (response.ok) {
        cargarCompetencias();
        alert('✅ Competencia eliminada exitosamente');
      } else {
        alert('❌ Error al eliminar la competencia');
      }
    } catch (err) {
      console.error('Error:', err);
      alert('❌ Error al eliminar la competencia');
    }
  };

  // ✅ FIX SONARQUBE: Ternarios anidados extraídos a función independiente
  const renderContenido = () => {
    if (loading) {
      return (
        <div className="text-center py-5">
          <div className="spinner-border text-danger" role="status">
            <span className="visually-hidden">Cargando...</span>
          </div>
        </div>
      );
    }

    if (error) {
      return <div className="alert alert-warning text-center">{error}</div>;
    }

    if (competencias.length === 0) {
      return <div className="alert alert-info text-center">No hay competencias registradas</div>;
    }

    return (
      <>
        <div className="table-responsive">
          <table className="table table-hover">
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
              {competencias.map((competencia) => (
                <tr key={competencia.idCompetencias}>
                  <td>{competencia.idCompetencias}</td>
                  <td>{competencia.Nombre}</td>
                  <td>{competencia.TipoCompetencia}</td>
                  <td>{competencia.Ano}</td>
                  <td>{competencia.categoria?.Descripcion || 'Sin categoría'}</td>
                  <td className="text-center">
                    <div className="btn-group">
                      <button className="btn btn-sm btn-info" onClick={() => abrirModal("ver", competencia)} title="Ver detalles">
                        <i className="bi bi-eye"></i>
                      </button>
                      <button className="btn btn-sm btn-warning" onClick={() => abrirModal("editar", competencia)} title="Editar">
                        <i className="bi bi-pencil"></i>
                      </button>
                      <button className="btn btn-sm btn-danger" onClick={() => handleEliminar(competencia.idCompetencias)} title="Eliminar">
                        <i className="bi bi-trash"></i>
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <div className="d-flex justify-content-between align-items-center mt-3">
          <div>Mostrando {competencias.length} de {totalItems} competencias</div>
          <nav>
            <ul className="pagination mb-0">
              <li className={`page-item ${currentPage === 1 ? 'disabled' : ''}`}>
                <button
                  className="page-link"
                  onClick={() => setCurrentPage(prev => Math.max(1, prev - 1))}
                  disabled={currentPage === 1}
                >
                  Anterior
                </button>
              </li>
              {Array.from({ length: totalPages }, (_, index) => (
                <li key={index + 1} className={`page-item ${currentPage === index + 1 ? 'active' : ''}`}>
                  <button className="page-link" onClick={() => setCurrentPage(index + 1)}>
                    {index + 1}
                  </button>
                </li>
              ))}
              <li className={`page-item ${currentPage === totalPages ? 'disabled' : ''}`}>
                <button
                  className="page-link"
                  onClick={() => setCurrentPage(prev => Math.min(totalPages, prev + 1))}
                  disabled={currentPage === totalPages}
                >
                  Siguiente
                </button>
              </li>
            </ul>
          </nav>
        </div>
      </>
    );
  };

  const renderTituloModal = () => {
    if (modalMode === "crear") return "Nueva Competencia";
    if (modalMode === "editar") return "Editar Competencia";
    return "Detalles de Competencia";
  };

  return (
    <div className="container-fluid py-4">
      <meta charSet="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Competencias - SCORD</title>
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" />
      <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet" />

      <header className="header bg-white shadow-sm py-3 mb-4">
        <nav className="navbar container d-flex align-items-center justify-content-between flex-wrap">
          <div className="d-flex align-items-center">
            <img src="/Img/SCORD.png" alt="Logo SCORD" className="me-2" style={{ height: '60px' }} />
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

      <div className="row mb-4">
        <div className="col-12">
          <h1 className="text-danger fw-bold">Gestión de Competencias</h1>
        </div>
      </div>

      <div className="card shadow-sm mb-4">
        <div className="card-header bg-danger text-white">
          <h5 className="mb-0">Filtros de Búsqueda</h5>
        </div>
        <div className="card-body">
          <div className="row g-3">
            <div className="col-md-3">
              <label className="form-label">Nombre</label>
              <input type="text" className="form-control" name="nombre" value={filtros.nombre} onChange={handleFiltroChange} placeholder="Buscar por nombre..." />
            </div>
            <div className="col-md-3">
              <label className="form-label">Tipo de Competencia</label>
              <input type="text" className="form-control" name="tipo" value={filtros.tipo} onChange={handleFiltroChange} placeholder="Ej: Liga Regional" />
            </div>
            <div className="col-md-2">
              <label className="form-label">Año</label>
              <input type="number" className="form-control" name="ano" value={filtros.ano} onChange={handleFiltroChange} placeholder="2024" />
            </div>
            <div className="col-md-2">
              <label className="form-label">Categoría</label>
              <select className="form-select" name="idCategorias" value={filtros.idCategorias} onChange={handleFiltroChange}>
                <option value="">Todas</option>
                {categorias.map((cat) => (
                  <option key={cat.idCategorias} value={cat.idCategorias}>{cat.Descripcion}</option>
                ))}
              </select>
            </div>
            <div className="col-md-2 d-flex align-items-end">
              <button className="btn btn-secondary w-100" onClick={limpiarFiltros}>Limpiar Filtros</button>
            </div>
          </div>
        </div>
      </div>

      <div className="row mb-3">
        <div className="col-12">
          <button className="btn btn-danger" onClick={() => abrirModal("crear")}>
            <i className="bi bi-plus-circle me-2"></i>Nueva Competencia
          </button>
        </div>
      </div>

      <div className="card shadow-sm">
        <div className="card-body">
          {/* ✅ FIX: Se reemplazaron los ternarios anidados por llamada a función */}
          {renderContenido()}
        </div>
      </div>

      {showModal && (
        <div className="modal show d-block" style={{ backgroundColor: 'rgba(0,0,0,0.5)' }}>
          <div className="modal-dialog modal-dialog-centered">
            <div className="modal-content">
              <div className="modal-header bg-danger text-white">
                {/* ✅ FIX: Ternarios encadenados del título extraídos a función */}
                <h5 className="modal-title">{renderTituloModal()}</h5>
                <button type="button" className="btn-close btn-close-white" onClick={cerrarModal}></button>
              </div>
              <div className="modal-body">
                <form onSubmit={handleSubmit}>
                  <div className="mb-3">
                    <label className="form-label">Nombre *</label>
                    <input
                      type="text"
                      className={`form-control ${errors.Nombre ? 'is-invalid' : ''}`}
                      name="Nombre"
                      value={selectedCompetencia.Nombre}
                      onChange={handleInputChange}
                      disabled={modalMode === "ver"}
                      maxLength={50}
                      placeholder="Ej: Campeonato Regional 2025"
                    />
                    {errors.Nombre && <div className="invalid-feedback">{errors.Nombre}</div>}
                  </div>
                  <div className="mb-3">
                    <label className="form-label">Tipo de Competencia *</label>
                    <input
                      type="text"
                      className={`form-control ${errors.TipoCompetencia ? 'is-invalid' : ''}`}
                      name="TipoCompetencia"
                      value={selectedCompetencia.TipoCompetencia}
                      onChange={handleInputChange}
                      disabled={modalMode === "ver"}
                      maxLength={30}
                      placeholder="Ej: Liga Regional"
                    />
                    {errors.TipoCompetencia && <div className="invalid-feedback">{errors.TipoCompetencia}</div>}
                  </div>
                  <div className="mb-3">
                    <label className="form-label">Año *</label>
                    <input
                      type="number"
                      className={`form-control ${errors.Ano ? 'is-invalid' : ''}`}
                      name="Ano"
                      value={selectedCompetencia.Ano}
                      onChange={handleInputChange}
                      disabled={modalMode === "ver"}
                      min={1900}
                      max={2100}
                      placeholder="2025"
                    />
                    {errors.Ano && <div className="invalid-feedback">{errors.Ano}</div>}
                  </div>
                  <div className="mb-3">
                    <label className="form-label">Categoría *</label>
                    <select
                      className={`form-select ${errors.idCategorias ? 'is-invalid' : ''}`}
                      name="idCategorias"
                      value={selectedCompetencia.idCategorias}
                      onChange={handleInputChange}
                      disabled={modalMode === "ver"}
                    >
                      <option value="">-- Seleccione una categoría --</option>
                      {categorias.map((cat) => (
                        <option key={cat.idCategorias} value={cat.idCategorias}>
                          {cat.Descripcion}
                        </option>
                      ))}
                    </select>
                    {errors.idCategorias && <div className="invalid-feedback">{errors.idCategorias}</div>}
                  </div>
                  {modalMode !== "ver" && (
                    <div className="d-flex justify-content-end gap-2">
                      <button type="button" className="btn btn-secondary" onClick={cerrarModal}>Cancelar</button>
                      <button type="submit" className="btn btn-danger">
                        {modalMode === "crear" ? "Crear" : "Guardar Cambios"}
                      </button>
                    </div>
                  )}
                  {modalMode === "ver" && (
                    <div className="d-flex justify-content-end">
                      <button type="button" className="btn btn-secondary" onClick={cerrarModal}>Cerrar</button>
                    </div>
                  )}
                </form>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default CompetenciasAdmin;