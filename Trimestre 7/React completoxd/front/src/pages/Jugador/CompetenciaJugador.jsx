import React, { useState, useEffect } from "react";
import NavbarJugador from "../../componentes/NavbarJugador";
 
// ✅ FIX: Función extraída fuera del componente para reducir Cognitive Complexity
export const buildParams = (currentPage, filtros) => {
  const params = new URLSearchParams();
  params.append('page', currentPage);
  if (filtros.nombre) params.append('nombre', filtros.nombre);
  if (filtros.tipo) params.append('tipo', filtros.tipo);
  if (filtros.ano) params.append('ano', filtros.ano);
  if (filtros.id_equipo) params.append('id_equipo', filtros.id_equipo);
  params.append('sort_by', filtros.sort_by);
  params.append('sort_order', filtros.sort_order);
  return params;
};
 
// ✅ FIX: Validación extraída fuera del componente para reducir Cognitive Complexity
const validarCampos = (selectedCompetencia) => {
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
  } else if (Number.isNaN(selectedCompetencia.Ano) || selectedCompetencia.Ano < 1900 || selectedCompetencia.Ano > 2100) {
    newErrors.Ano = "Ingrese un año válido";
  }
 
  if (!selectedCompetencia.idEquipos || selectedCompetencia.idEquipos === "") {
    newErrors.idEquipos = "Debe seleccionar un equipo";
  }
 
  return newErrors;
};
 
const COMPETENCIA_VACIA = {
  idCompetencias: "",
  Nombre: "",
  TipoCompetencia: "",
  Ano: "",
  idEquipos: ""
};
 
const CompetenciaJugador = () => {
 
  // ✅ FIX: Se eliminó `const navigate = useNavigate()` — variable inútil no usada
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
    id_equipo: "",
    sort_by: "idCompetencias",
    sort_order: "asc"
  });
 
  const [filterOptions, setFilterOptions] = useState({
    tipos_competencia: [],
    anos: [],
    equipos: []
  });
 
  const [showModal, setShowModal] = useState(false);
  const [modalMode, setModalMode] = useState("ver");
  const [selectedCompetencia, setSelectedCompetencia] = useState(COMPETENCIA_VACIA);
  const [errors, setErrors] = useState({});
 
  useEffect(() => {
    cargarOpcionesFiltros();
  }, []);
 
  useEffect(() => {
    cargarCompetencias();
  }, [filtros, currentPage]);
 
  const cargarOpcionesFiltros = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch('http://127.0.0.1:8000/api/competencias/filter-options', {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });
      if (response.ok) {
        const data = await response.json();
        setFilterOptions(data);
      }
    } catch (err) {
      console.error('Error al cargar opciones de filtros:', err);
    }
  };
 
  const cargarCompetencias = async () => {
    try {
      setLoading(true);
      const token = localStorage.getItem('token');
      const params = buildParams(currentPage, filtros);
 
      const response = await fetch(`http://127.0.0.1:8000/api/competencias?${params}`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });
 
      if (response.ok) {
        const data = await response.json();
        setCompetencias(data.data);
        setTotalPages(data.meta.last_page);
        setTotalItems(data.meta.total);
        setError(null);
      } else if (response.status === 404) {
        setCompetencias([]);
        setError('No se encontraron competencias con los filtros aplicados');
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
      id_equipo: "",
      sort_by: "idCompetencias",
      sort_order: "asc"
    });
    setCurrentPage(1);
  };
 
  const abrirModal = (mode, competencia = null) => {
    setModalMode(mode);
    setSelectedCompetencia(competencia ?? COMPETENCIA_VACIA);
    setErrors({});
    setShowModal(true);
  };
 
  const cerrarModal = () => {
    setShowModal(false);
    setSelectedCompetencia(COMPETENCIA_VACIA);
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
    const newErrors = validarCampos(selectedCompetencia);
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };
 
  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validarFormulario()) return;
 
    try {
      const token = localStorage.getItem('token');
      const url = modalMode === "crear"
        ? 'http://127.0.0.1:8000/api/competencias'
        : `http://127.0.0.1:8000/api/competencias/${selectedCompetencia.idCompetencias}`;
      const method = modalMode === "crear" ? 'POST' : 'PUT';
 
      const response = await fetch(url, {
        method,
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(selectedCompetencia)
      });
 
      if (response.ok) {
        cerrarModal();
        cargarCompetencias();
        alert(modalMode === "crear" ? 'Competencia creada exitosamente' : 'Competencia actualizada exitosamente');
      } else {
        const errorData = await response.json();
        if (errorData.errors) {
          setErrors(errorData.errors);
        } else {
          alert('Error al guardar la competencia');
        }
      }
    } catch (err) {
      console.error('Error:', err);
      alert('Error al guardar la competencia');
    }
  };
 
 
  // ✅ FIX SONARQUBE: Ternarios anidados extraídos a función independiente
  const renderContenido = () => {
    if (loading) {
      return (
        <div className="text-center py-5">
          <output className="spinner-border text-danger" >
            <span className="visually-hidden">Cargando...</span>
          </output>
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
                <th>Equipo</th>
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
                  <td>{competencia.NombreEquipo || 'Sin equipo'}</td>
                  <td className="text-center">
                    {/* ✅ FIX SONARQUBE: role="group" reemplazado por fieldset */}
                    <fieldset className="btn-group">
                      <button
                        className="btn btn-sm btn-info"
                        onClick={() => abrirModal("ver", competencia)}
                        title="Ver detalles"
                      >
                        <i className="bi bi-eye"></i>
                      </button>
                    </fieldset>
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
                >
                  Anterior
                </button>
              </li>
              {/* ✅ FIX SONARQUBE: Array() reemplazado por new Array() */}
              {new Array(totalPages).fill(null).map((_, index) => (
                <li
                  key={index + 1}
                  className={`page-item ${currentPage === index + 1 ? 'active' : ''}`}
                >
                  <button className="page-link" onClick={() => setCurrentPage(index + 1)}>
                    {index + 1}
                  </button>
                </li>
              ))}
              <li className={`page-item ${currentPage === totalPages ? 'disabled' : ''}`}>
                <button
                  className="page-link"
                  onClick={() => setCurrentPage(prev => Math.min(totalPages, prev + 1))}
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
 
  // ✅ FIX SONARQUBE: Título del modal extraído a función independiente
  const renderTituloModal = () => {
    if (modalMode === "crear") return "Nueva Competencia";
    if (modalMode === "editar") return "Editar Competencia";
    return "Detalles de Competencia";
  };
 
  return (
    <div className="container-fluid py-4">
      <meta charSet="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Competencia - SCORD</title>
      <link
        href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css"
        rel="stylesheet"
      />
      <link rel="stylesheet" href="Css/InicioAdmin.css" />
 
      <div className="row mb-4">
        <div className="col-12">
          <h1 className="text-danger fw-bold">Gestión de Competencias</h1>
        </div>
      </div>
 
      <header className="header bg-white shadow-sm py-3">
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
          <NavbarJugador />
        </nav>
      </header>
 
      {/* Filtros */}
      <div className="card shadow-sm mb-4">
        <div className="card-header bg-danger text-white">
          <h5 className="mb-0">Filtros de Búsqueda</h5>
        </div>
        <div className="card-body">
          <div className="row g-3">
            <div className="col-md-3">
              <label className="form-label">Nombre</label>
              <input
                type="text"
                className="form-control"
                name="nombre"
                value={filtros.nombre}
                onChange={handleFiltroChange}
                placeholder="Buscar por nombre..."
              />
            </div>
            <div className="col-md-3">
              <label className="form-label">Tipo de Competencia</label>
              <select className="form-select" name="tipo" value={filtros.tipo} onChange={handleFiltroChange}>
                <option value="">Todos los tipos</option>
                {filterOptions.tipos_competencia.map((tipo, index) => (
                  <option key={index} value={tipo}>{tipo}</option>
                ))}
              </select>
            </div>
            <div className="col-md-2">
              <label className="form-label">Año</label>
              <select className="form-select" name="ano" value={filtros.ano} onChange={handleFiltroChange}>
                <option value="">Todos los años</option>
                {filterOptions.anos.map((ano, index) => (
                  <option key={index} value={ano}>{ano}</option>
                ))}
              </select>
            </div>
            <div className="col-md-2">
              <label className="form-label">Equipo</label>
              <select className="form-select" name="id_equipo" value={filtros.id_equipo} onChange={handleFiltroChange}>
                <option value="">Todos los equipos</option>
                {filterOptions.equipos.map((equipo) => (
                  <option key={equipo.idEquipos} value={equipo.idEquipos}>
                    {equipo.nombre_equipo}
                  </option>
                ))}
              </select>
            </div>
            <div className="col-md-2 d-flex align-items-end">
              <button className="btn btn-secondary w-100" onClick={limpiarFiltros}>
                Limpiar Filtros
              </button>
            </div>
          </div>
        </div>
      </div>
 
      {/* Tabla */}
      <div className="card shadow-sm">
        <div className="card-body">
          {renderContenido()}
        </div>
      </div>
 
      {/* Modal */}
      {showModal && (
        <div className="modal show d-block" style={{ backgroundColor: 'rgba(0,0,0,0.5)' }}>
          <div className="modal-dialog modal-dialog-centered">
            <div className="modal-content">
              <div className="modal-header bg-danger text-white">
                <h5 className="modal-title">{renderTituloModal()}</h5>
                <button type="button" className="btn-close btn-close-white" onClick={cerrarModal}></button>
              </div>
              <div className="modal-body">
                <form onSubmit={handleSubmit}>
                  <div className="mb-3">
                    <label htmlFor="inputNombre" className="form-label">Nombre *</label>
                    <input
                      id= "inputNombre"
                      type="text"
                      className={`form-control ${errors.Nombre ? 'is-invalid' : ''}`}
                      name="Nombre"
                      value={selectedCompetencia.Nombre}
                      onChange={handleInputChange}
                      disabled={modalMode === "ver"}
                      maxLength={50}
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
                    />
                    {errors.Ano && <div className="invalid-feedback">{errors.Ano}</div>}
                  </div>
 
                  <div className="mb-3">
                    <label className="form-label">Equipo *</label>
                    <select
                      className={`form-select ${errors.idEquipos ? 'is-invalid' : ''}`}
                      name="idEquipos"
                      value={selectedCompetencia.idEquipos}
                      onChange={handleInputChange}
                      disabled={modalMode === "ver"}
                    >
                      <option value="">Seleccione un equipo</option>
                      {filterOptions.equipos.map((equipo) => (
                        <option key={equipo.idEquipos} value={equipo.idEquipos}>
                          {equipo.nombre_equipo}
                        </option>
                      ))}
                    </select>
                    {errors.idEquipos && <div className="invalid-feedback">{errors.idEquipos}</div>}
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
 
export default CompetenciaJugador;
 