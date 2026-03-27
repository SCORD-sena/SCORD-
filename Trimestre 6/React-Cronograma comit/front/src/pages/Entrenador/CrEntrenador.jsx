import React, { useState, useEffect, useMemo } from "react"; // Añadir useMemo
import axios from "axios";
import Swal from "sweetalert2";
import NavbarEntrenador from "../../componentes/NavbarEntrenador";

const api = axios.create({
  baseURL: "http://127.0.0.1:8000/api",
});

api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem("token");
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

const CrEntrenador = () => {
  // ============================================================
  // CONSTANTES
  // ============================================================
  const ITEMS_PER_PAGE = 5; // Cantidad de registros por página

  // ============================================================
  // ESTADOS GENERALES
  // ============================================================
  const [cronogramas, setCronogramas] = useState([]);
  const [entrenamientos, setEntrenamientos] = useState([]);
  const [partidos, setPartidos] = useState([]);
  const [partidosAPI, setPartidosAPI] = useState([]);
  const [categoriasAPI, setCategoriasAPI] = useState([]);
  const [misCategoriasIds, setMisCategoriasIds] = useState([]);
  const [loadingCategorias, setLoadingCategorias] = useState(true);

  // ============================================================
  // ESTADOS PARA BÚSQUEDA Y PAGINACIÓN DE ENTRENAMIENTOS
  // ============================================================
  const [searchTermEntrenamiento, setSearchTermEntrenamiento] = useState("");
  const [currentPageEntrenamiento, setCurrentPageEntrenamiento] = useState(1);

  // ============================================================
  // ESTADOS PARA BÚSQUEDA Y PAGINACIÓN DE PARTIDOS
  // ============================================================
  const [searchTermPartido, setSearchTermPartido] = useState("");
  const [currentPagePartido, setCurrentPagePartido] = useState(1);

  // ============================================================
  // ESTADOS PARA FORMULARIOS
  // ============================================================
  const [formEntrenamiento, setFormEntrenamiento] = useState({
    TipoDeEventos: "Entrenamiento",
    FechaDeEventos: "",
    CanchaPartido: "",
    Ubicacion: "",
    SedeEntrenamiento: "",
    Descripcion: "",
    idCategorias: "",
  });

  const [formPartidoAPI, setFormPartidoAPI] = useState({
    Formacion: "",
    FechaDeEventos: "",
    Ubicacion: "",
    CanchaPartido: "",
    idCategorias: "",
    EquipoRival: "",
  });

  const [editingId, setEditingId] = useState(null);
  const [editingType, setEditingType] = useState(null);

  // ============================================================
  // EFECTOS
  // ============================================================
  useEffect(() => {
    fetchMisCategorias();
  }, []);

  useEffect(() => {
    if (misCategoriasIds.length > 0) {
      fetchCronogramas();
      fetchPartidosAPI();
      fetchCategoriasAPI();
    }
  }, [misCategoriasIds]);

  // ============================================================
  // FUNCIONES PARA OBTENER DATOS DE LA API
  // ============================================================
  const fetchMisCategorias = async () => {
    try {
      const res = await api.get("/entrenadores/misCategorias");
      const categoriasIds = res.data.data.map(cat => cat.idCategorias);
      setMisCategoriasIds(categoriasIds);
      setLoadingCategorias(false);
    } catch (err) {
      console.error("Error obteniendo categorías del entrenador:", err);
      Swal.fire({
        icon: "error",
        title: "Error",
        text: "No se pudieron cargar tus categorías. Contacta al administrador.",
        confirmButtonColor: "#e63946"
      });
      setLoadingCategorias(false);
    }
  };

  const fetchCronogramas = async () => {
    try {
      const res = await api.get("/cronogramas");
      const misCronogramas = res.data.filter(c => 
        misCategoriasIds.includes(c.idCategorias)
      );
      
      setCronogramas(misCronogramas);
      setEntrenamientos(misCronogramas.filter((c) => c.TipoDeEventos === "Entrenamiento"));
      setPartidos(misCronogramas.filter((c) => c.TipoDeEventos === "Partido"));
    } catch (err) {
      console.error("Error fetching cronogramas:", err);
      Swal.fire({
        icon: "error",
        title: "Error",
        text: "No se pudieron cargar los cronogramas",
        confirmButtonColor: "#e63946"
      });
    }
  };

  const fetchPartidosAPI = async () => {
    try {
      const res = await api.get("/partidos");
      setPartidosAPI(res.data);
    } catch (err) {
      console.error("Error fetching partidos:", err);
    }
  };

  const fetchCategoriasAPI = async () => {
    try {
      setLoadingCategorias(true);
      const res = await api.get("/categorias");
      const misCategorias = res.data.filter(cat => 
        misCategoriasIds.includes(cat.idCategorias)
      );
      setCategoriasAPI(misCategorias);
    } catch (err) {
      console.error("Error fetching categorias:", err);
      Swal.fire({
        icon: "error",
        title: "Error al cargar categorías",
        text: "No se pudieron cargar las categorías disponibles",
        confirmButtonColor: "#e63946"
      });
    } finally {
      setLoadingCategorias(false);
    }
  };

  // ============================================================
  // FUNCIONES CRUD (se mantienen igual)
  // ============================================================
  const handleAgregarEntrenamiento = async (e) => {
    e.preventDefault();
    
    if (!formEntrenamiento.idCategorias) {
      Swal.fire({
        icon: "warning",
        title: "Categoría requerida",
        text: "Por favor seleccione una categoría",
        confirmButtonColor: "#e63946"
      });
      return;
    }

    if (!misCategoriasIds.includes(parseInt(formEntrenamiento.idCategorias))) {
      Swal.fire({
        icon: "error",
        title: "Acceso denegado",
        text: "No puedes agregar entrenamientos a esta categoría",
        confirmButtonColor: "#e63946"
      });
      return;
    }

    try {
      const dataToSend = {
        ...formEntrenamiento,
        idCategorias: parseInt(formEntrenamiento.idCategorias),
      };

      await api.post("/cronogramas", dataToSend);
      await fetchCronogramas();
      limpiarFormularioEntrenamiento();
      
      Swal.fire({
        icon: "success",
        title: "¡Éxito!",
        text: "Entrenamiento agregado exitosamente",
        confirmButtonColor: "#e63946",
        timer: 2000
      });
    } catch (err) {
      console.error("Error agregando entrenamiento:", err);
      Swal.fire({
        icon: "error",
        title: "Error",
        text: err.response?.data?.message || "Error al agregar entrenamiento",
        confirmButtonColor: "#e63946"
      });
    }
  };

  const handleAgregarPartidoAPI = async (e) => {
    e.preventDefault();

    if (!formPartidoAPI.idCategorias) {
      Swal.fire({
        icon: "warning",
        title: "Categoría requerida",
        text: "Por favor seleccione una categoría",
        confirmButtonColor: "#e63946"
      });
      return;
    }

    if (!misCategoriasIds.includes(parseInt(formPartidoAPI.idCategorias))) {
      Swal.fire({
        icon: "error",
        title: "Acceso denegado",
        text: "No puedes agregar partidos a esta categoría",
        confirmButtonColor: "#e63946"
      });
      return;
    }

    try {
      const cronogramaData = {
        TipoDeEventos: "Partido",
        FechaDeEventos: formPartidoAPI.FechaDeEventos,
        Ubicacion: formPartidoAPI.Ubicacion,
        CanchaPartido: formPartidoAPI.CanchaPartido,
        SedeEntrenamiento: "",
        Descripcion: `Partido vs ${formPartidoAPI.EquipoRival}`,
        idCategorias: parseInt(formPartidoAPI.idCategorias),
      };

      const resCronograma = await api.post("/cronogramas", cronogramaData);
      const idCronograma = resCronograma.data.data?.idCronogramas;
      
      if (!idCronograma) throw new Error("No se pudo obtener el id del cronograma creado.");

      const partidoData = {
        Formacion: formPartidoAPI.Formacion,
        EquipoRival: formPartidoAPI.EquipoRival,
        idCronogramas: idCronograma,
      };

      await api.post("/partidos", partidoData);
      await fetchPartidosAPI();
      await fetchCronogramas();
      limpiarFormularioPartidoAPI();
      
      Swal.fire({
        icon: "success",
        title: "¡Éxito!",
        text: "Partido agregado exitosamente",
        confirmButtonColor: "#e63946",
        timer: 2000
      });
    } catch (err) {
      console.error("Error al agregar partido:", err);
      Swal.fire({
        icon: "error",
        title: "Error",
        text: "Error al agregar partido. Revisa los campos e intenta nuevamente",
        confirmButtonColor: "#e63946"
      });
    }
  };

  const handleGuardar = async (e) => {
    e.preventDefault();
    if (!editingId) return;

    try {
      if (editingType === "PartidoAPI") {
        const partidoActual = partidosAPI.find((p) => p.idPartidos === editingId);
        if (!partidoActual) {
          Swal.fire({
            icon: "error",
            title: "Error",
            text: "Partido no encontrado para edición",
            confirmButtonColor: "#e63946"
          });
          return;
        }

        const cronogramaData = {
          TipoDeEventos: "Partido",
          FechaDeEventos: formPartidoAPI.FechaDeEventos,
          Ubicacion: formPartidoAPI.Ubicacion,
          CanchaPartido: formPartidoAPI.CanchaPartido,
          SedeEntrenamiento: "",
          Descripcion: `Partido vs ${formPartidoAPI.EquipoRival}`,
          idCategorias: parseInt(formPartidoAPI.idCategorias),
        };

        await api.put(`/cronogramas/${partidoActual.idCronogramas}`, cronogramaData);

        const partidoData = {
          Formacion: formPartidoAPI.Formacion,
          EquipoRival: formPartidoAPI.EquipoRival,
          idCronograma: partidoActual.idCronogramas,
        };

        await api.put(`/partidos/${editingId}`, partidoData);

        Swal.fire({
          icon: "success",
          title: "¡Actualizado!",
          text: "Partido actualizado exitosamente",
          confirmButtonColor: "#e63946",
          timer: 2000
        });
      } else {
        const dataToSend = {
          ...formEntrenamiento,
          idCategorias: parseInt(formEntrenamiento.idCategorias),
        };
        await api.put(`/cronogramas/${editingId}`, dataToSend);
        
        Swal.fire({
          icon: "success",
          title: "¡Actualizado!",
          text: "Entrenamiento actualizado exitosamente",
          confirmButtonColor: "#e63946",
          timer: 2000
        });
      }

      await fetchPartidosAPI();
      await fetchCronogramas();
      limpiarFormularios();
      setEditingId(null);
      setEditingType(null);
    } catch (err) {
      console.error("Error actualizando:", err);
      Swal.fire({
        icon: "error",
        title: "Error",
        text: "Error al guardar cambios. Intenta nuevamente",
        confirmButtonColor: "#e63946"
      });
    }
  };

  const handleBorrar = async (id) => {
    const result = await Swal.fire({
      title: "¿Estás seguro?",
      text: "Esta acción no se puede deshacer",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#e63946",
      cancelButtonColor: "#6c757d",
      confirmButtonText: "Sí, eliminar",
      cancelButtonText: "Cancelar"
    });

    if (result.isConfirmed) {
      try {
        await api.delete(`/cronogramas/${id}`);
        await fetchCronogramas();
        
        Swal.fire({
          icon: "success",
          title: "¡Eliminado!",
          text: "Registro eliminado exitosamente",
          confirmButtonColor: "#e63946",
          timer: 2000
        });
      } catch (err) {
        console.error("Error eliminando cronograma:", err);
        Swal.fire({
          icon: "error",
          title: "Error",
          text: "Error al eliminar registro",
          confirmButtonColor: "#e63946"
        });
      }
    }
  };

  const handleBorrarPartidoAPI = async (id) => {
    const result = await Swal.fire({
      title: "¿Estás seguro?",
      text: "Esta acción no se puede deshacer",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#e63946",
      cancelButtonColor: "#6c757d",
      confirmButtonText: "Sí, eliminar",
      cancelButtonText: "Cancelar"
    });

    if (result.isConfirmed) {
      try {
        await api.delete(`/partidos/${id}`);
        await fetchPartidosAPI();
        
        Swal.fire({
          icon: "success",
          title: "¡Eliminado!",
          text: "Partido eliminado exitosamente",
          confirmButtonColor: "#e63946",
          timer: 2000
        });
      } catch (err) {
        console.error("Error eliminando partido:", err);
        Swal.fire({
          icon: "error",
          title: "Error",
          text: "Error al eliminar partido",
          confirmButtonColor: "#e63946"
        });
      }
    }
  };

  const handleEditarClick = (cronograma) => {
    setEditingId(cronograma.idCronogramas);
    setEditingType("Entrenamiento");
    setFormEntrenamiento({
      TipoDeEventos: cronograma.TipoDeEventos,
      FechaDeEventos: cronograma.FechaDeEventos,
      CanchaPartido: cronograma.CanchaPartido || "",
      Ubicacion: cronograma.Ubicacion,
      SedeEntrenamiento: cronograma.SedeEntrenamiento || "",
      Descripcion: cronograma.Descripcion || "",
      idCategorias: cronograma.idCategorias || "",
    });
  };

  const handleEditarPartidoAPI = (partido) => {
    setEditingId(partido.idPartidos);
    setEditingType("PartidoAPI");
    const cronograma = cronogramas.find((c) => c.idCronogramas === partido.idCronogramas);
    setFormPartidoAPI({
      Formacion: partido.Formacion || "",
      FechaDeEventos: cronograma?.FechaDeEventos || "",
      Ubicacion: cronograma?.Ubicacion || "",
      CanchaPartido: cronograma?.CanchaPartido || "",
      idCategorias: cronograma?.idCategorias || "",
      EquipoRival: partido.EquipoRival || "",
    });
  };

  const handleCancelarEdicion = () => {
    limpiarFormularios();
    setEditingId(null);
    setEditingType(null);
  };

  const limpiarFormularioEntrenamiento = () =>
    setFormEntrenamiento({
      TipoDeEventos: "Entrenamiento",
      FechaDeEventos: "",
      CanchaPartido: "",
      Ubicacion: "",
      SedeEntrenamiento: "",
      Descripcion: "",
      idCategorias: "",
    });

  const limpiarFormularioPartidoAPI = () =>
    setFormPartidoAPI({
      Formacion: "",
      FechaDeEventos: "",
      Ubicacion: "",
      CanchaPartido: "",
      idCategorias: "",
      EquipoRival: "",
    });

  const limpiarFormularios = () => {
    limpiarFormularioEntrenamiento();
    limpiarFormularioPartidoAPI();
  };

  // ============================================================
  // LÓGICA DE FILTRADO Y PAGINACIÓN PARA ENTRENAMIENTOS
  // ============================================================
  const filteredEntrenamientos = useMemo(() => {
    if (!searchTermEntrenamiento) return entrenamientos;
    const lowerCaseSearch = searchTermEntrenamiento.toLowerCase();

    return entrenamientos.filter((c) => {
      const categoria = categoriasAPI.find((cat) => cat.idCategorias === c.idCategorias);
      const categoriaDescripcion = categoria?.Descripcion.toLowerCase() || "";

      return (
        c.FechaDeEventos.toLowerCase().includes(lowerCaseSearch) ||
        c.Ubicacion.toLowerCase().includes(lowerCaseSearch) ||
        c.SedeEntrenamiento?.toLowerCase().includes(lowerCaseSearch) ||
        c.Descripcion?.toLowerCase().includes(lowerCaseSearch) ||
        categoriaDescripcion.includes(lowerCaseSearch)
      );
    });
  }, [entrenamientos, searchTermEntrenamiento, categoriasAPI]);

  const totalPagesEntrenamiento = Math.ceil(filteredEntrenamientos.length / ITEMS_PER_PAGE);
  
  const currentEntrenamientos = useMemo(() => {
    const startIndex = (currentPageEntrenamiento - 1) * ITEMS_PER_PAGE;
    return filteredEntrenamientos.slice(startIndex, startIndex + ITEMS_PER_PAGE);
  }, [filteredEntrenamientos, currentPageEntrenamiento]);
  
  const handlePageChangeEntrenamiento = (page) => {
    if (page >= 1 && page <= totalPagesEntrenamiento) {
      setCurrentPageEntrenamiento(page);
    }
  };

  // ============================================================
  // LÓGICA DE FILTRADO Y PAGINACIÓN PARA PARTIDOS
  // ============================================================
  const filteredPartidos = useMemo(() => {
    if (!searchTermPartido) {
      // Filtrar solo los partidos del entrenador
      return partidosAPI.filter(p => {
        const cronograma = cronogramas.find(c => c.idCronogramas === p.idCronogramas);
        return cronograma && misCategoriasIds.includes(cronograma.idCategorias);
      });
    }
    
    const lowerCaseSearch = searchTermPartido.toLowerCase();

    return partidosAPI.filter((p) => {
      const cronograma = cronogramas.find((c) => c.idCronogramas === p.idCronogramas);
      // Solo mostrar partidos de las categorías del entrenador
      if (!cronograma || !misCategoriasIds.includes(cronograma.idCategorias)) {
        return false;
      }
      
      const categoria = categoriasAPI.find((cat) => cat.idCategorias === cronograma?.idCategorias);
      const categoriaDescripcion = categoria?.Descripcion.toLowerCase() || "";

      return (
        p.Formacion.toLowerCase().includes(lowerCaseSearch) ||
        p.EquipoRival.toLowerCase().includes(lowerCaseSearch) ||
        cronograma?.FechaDeEventos.toLowerCase().includes(lowerCaseSearch) ||
        cronograma?.Ubicacion.toLowerCase().includes(lowerCaseSearch) ||
        cronograma?.CanchaPartido.toString().includes(lowerCaseSearch) ||
        categoriaDescripcion.includes(lowerCaseSearch)
      );
    });
  }, [partidosAPI, searchTermPartido, cronogramas, categoriasAPI, misCategoriasIds]);

  const totalPagesPartido = Math.ceil(filteredPartidos.length / ITEMS_PER_PAGE);
  
  const currentPartidos = useMemo(() => {
    const startIndex = (currentPagePartido - 1) * ITEMS_PER_PAGE;
    return filteredPartidos.slice(startIndex, startIndex + ITEMS_PER_PAGE);
  }, [filteredPartidos, currentPagePartido]);

  const handlePageChangePartido = (page) => {
    if (page >= 1 && page <= totalPagesPartido) {
      setCurrentPagePartido(page);
    }
  };

  // ============================================================
  // COMPONENTE DE PAGINACIÓN REUTILIZABLE (EXACTO AL ADMIN)
  // ============================================================
  const Pagination = ({ currentPage, totalPages, onPageChange }) => {
    if (totalPages <= 1) return null;

    const pages = [...Array(totalPages).keys()].map(i => i + 1);

    return (
      <nav aria-label="Page navigation" className="d-flex justify-content-center mt-3">
        <ul className="pagination">
          <li className={`page-item ${currentPage === 1 ? 'disabled' : ''}`}>
            <button className="page-link" onClick={() => onPageChange(currentPage - 1)} aria-label="Previous">
              <span aria-hidden="true">&laquo;</span>
            </button>
          </li>
          
          {pages.map(page => (
            <li key={page} className={`page-item ${currentPage === page ? 'active' : ''}`}>
              <button className="page-link" onClick={() => onPageChange(page)}>
                {page}
              </button>
            </li>
          ))}
          
          <li className={`page-item ${currentPage === totalPages ? 'disabled' : ''}`}>
            <button className="page-link" onClick={() => onPageChange(currentPage + 1)} aria-label="Next">
              <span aria-hidden="true">&raquo;</span>
            </button>
          </li>
        </ul>
      </nav>
    );
  };

  // ============================================================
  // RENDER DEL COMPONENTE
  // ============================================================
  return (
    <div>
      <meta charSet="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Cronograma - SCORD</title>
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" />
      <link rel="stylesheet" href="/Css/InicioEntrenador.css" />
      
      <header className="header bg-white shadow-sm py-3">
        <nav className="navbar container d-flex align-items-center justify-content-between flex-wrap">
          <div className="d-flex align-items-center">
            <img src="/Img/SCORD.png" alt="Logo SCORD" className="me-2" style={{ height: "50px" }} />
            <h4 className="mb-0 text-danger fw-bold">SCORD</h4>
          </div>
          <NavbarEntrenador />
        </nav>
      </header>

      <main className="container my-5">
        <h1 className="text-center text-danger mb-4">Calendario de Actividades</h1>

        {misCategoriasIds.length === 0 && !loadingCategorias && (
          <div className="alert alert-warning text-center">
            No tienes categorías asignadas. Contacta al administrador.
          </div>
        )}

        {/* ============================================================ */}
        {/* SECCIÓN DE ENTRENAMIENTOS CON BÚSQUEDA Y PAGINACIÓN */}
        {/* ============================================================ */}
        <section className="mb-5">
          <h2>Entrenamientos Programados</h2>
          
          {/* Campo de búsqueda para entrenamientos */}
          <div className="mb-3">
            <input
              type="text"
              className="form-control"
              placeholder="Buscar entrenamiento por fecha, ubicación, sede o categoría..."
              value={searchTermEntrenamiento}
              onChange={(e) => {
                setSearchTermEntrenamiento(e.target.value);
                setCurrentPageEntrenamiento(1);
              }}
            />
          </div>
          
          <div className="table-responsive">
            <table className="table table-striped table-bordered">
              <thead className="table-danger">
                <tr>
                  <th>Fecha</th>
                  <th>Tipo de Evento</th>
                  <th>Ubicación</th>
                  <th>Sede</th>
                  <th>Categoría</th>
                  <th>Descripción</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                {currentEntrenamientos.length > 0 ? (
                  currentEntrenamientos.map((c) => {
                    const categoria = categoriasAPI.find((cat) => cat.idCategorias === c.idCategorias);
                    return (
                      <tr key={c.idCronogramas}>
                        <td>{c.FechaDeEventos}</td>
                        <td>{c.TipoDeEventos}</td>
                        <td>{c.Ubicacion}</td>
                        <td>{c.SedeEntrenamiento || "-"}</td>
                        <td>{categoria?.Descripcion || "Categoría no encontrada"}</td>
                        <td>{c.Descripcion}</td>
                        <td>
                          <div className="d-flex gap-2">
                            <button className="btn btn-sm btn-warning" onClick={() => handleEditarClick(c)}>
                              Actualizar
                            </button>
                            <button className="btn btn-sm btn-danger" onClick={() => handleBorrar(c.idCronogramas)}>
                              Borrar
                            </button>
                          </div>
                        </td>
                      </tr>
                    );
                  })
                ) : (
                  <tr>
                    <td colSpan="7" className="text-center">
                      {searchTermEntrenamiento ? "No se encontraron entrenamientos." : "No hay entrenamientos programados"}
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>

          {/* Paginación de entrenamientos */}
          <Pagination
            currentPage={currentPageEntrenamiento}
            totalPages={totalPagesEntrenamiento}
            onPageChange={handlePageChangeEntrenamiento}
          />

          <div className="mt-4">
            <h4 className="mb-3">
              {editingId && editingType === "Entrenamiento" ? "Editar Entrenamiento" : "Agregar Entrenamiento"}
            </h4>
            
            {loadingCategorias ? (
              <div className="alert alert-info">Cargando Entrenamientos...</div>
            ) : (
              <form
                className="row g-3"
                onSubmit={editingId && editingType === "Entrenamiento" ? handleGuardar : handleAgregarEntrenamiento}
              >
                <div className="col-md-6">
                  <label className="form-label">Fecha</label>
                  <input
                    type="date"
                    className="form-control"
                    value={formEntrenamiento.FechaDeEventos}
                    onChange={(e) => setFormEntrenamiento({ ...formEntrenamiento, FechaDeEventos: e.target.value })}
                    required
                  />
                </div>

                <div className="col-md-6">
                  <label className="form-label">Ubicación</label>
                  <input
                    type="text"
                    className="form-control"
                    value={formEntrenamiento.Ubicacion}
                    onChange={(e) => setFormEntrenamiento({ ...formEntrenamiento, Ubicacion: e.target.value })}
                    required
                  />
                </div>

                <div className="col-md-6">
                  <label className="form-label">Sede</label>
                  <select
                    className="form-select"
                    value={formEntrenamiento.SedeEntrenamiento}
                    onChange={(e) => setFormEntrenamiento({ ...formEntrenamiento, SedeEntrenamiento: e.target.value })}
                  >
                    <option value="">Seleccione una sede</option>
                    <option value="TIMIZA">TIMIZA</option>
                    <option value="CAYETANO CAÑIZARES">CAYETANO CAÑIZARES</option>
                    <option value="FONTIBON">FONTIBON</option>
                  </select>
                </div>

                <div className="col-md-6">
                  <label className="form-label">Categoría</label>
                  <select
                    className="form-select"
                    value={formEntrenamiento.idCategorias}
                    onChange={(e) => setFormEntrenamiento({ ...formEntrenamiento, idCategorias: e.target.value })}
                    required
                  >
                    <option value="">Seleccione una categoría</option>
                    {categoriasAPI.length > 0 ? (
                      categoriasAPI.map((categoria) => (
                        <option key={categoria.idCategorias} value={categoria.idCategorias}>
                          {categoria.Descripcion || `Categoría ${categoria.idCategorias}`}
                        </option>
                      ))
                    ) : (
                      <option value="" disabled>No hay categorías disponibles</option>
                    )}
                  </select>
                </div>

                <div className="col-12">
                  <label className="form-label">Descripción</label>
                  <input
                    type="text"
                    className="form-control"
                    value={formEntrenamiento.Descripcion}
                    onChange={(e) => setFormEntrenamiento({ ...formEntrenamiento, Descripcion: e.target.value })}
                    placeholder="Descripción del entrenamiento"
                  />
                </div>

                <div className="col-12 d-flex gap-2">
                  <button type="submit" className="btn btn-danger">
                    {editingId && editingType === "Entrenamiento" ? "Guardar Cambios" : "Agregar Entrenamiento"}
                  </button>

                  {editingId && editingType === "Entrenamiento" && (
                    <button type="button" className="btn btn-secondary" onClick={handleCancelarEdicion}>
                      Cancelar
                    </button>
                  )}
                </div>
              </form>
            )}
          </div>
        </section>

        {/* ============================================================ */}
        {/* SECCIÓN DE PARTIDOS CON BÚSQUEDA Y PAGINACIÓN */}
        {/* ============================================================ */}
        <section className="mb-5">
          <h2>Partidos Programados</h2>

          {/* Campo de búsqueda para partidos */}
          <div className="mb-3">
            <input
              type="text"
              className="form-control"
              placeholder="Buscar partido por formación, rival, fecha, ubicación o categoría..."
              value={searchTermPartido}
              onChange={(e) => {
                setSearchTermPartido(e.target.value);
                setCurrentPagePartido(1);
              }}
            />
          </div>

          <div className="table-responsive">
            <table className="table table-striped table-bordered">
              <thead className="table-danger">
                <tr>
                  <th>Fecha</th>
                  <th>Cancha</th>
                  <th>Ubicación</th>
                  <th>Formación</th>
                  <th>Equipo Rival</th>
                  <th>Categoría</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                {currentPartidos.length > 0 ? (
                  currentPartidos.map((p) => {
                    const cronograma = cronogramas.find((c) => c.idCronogramas === p.idCronogramas);
                    const categoria = categoriasAPI.find((cat) => cat.idCategorias === cronograma?.idCategorias);
                    return (
                      <tr key={p.idPartidos}>
                        <td>{cronograma?.FechaDeEventos || "-"}</td>
                        <td>{cronograma?.CanchaPartido || "-"}</td>
                        <td>{cronograma?.Ubicacion || "-"}</td>
                        <td>{p.Formacion}</td>
                        <td>{p.EquipoRival}</td>
                        <td>{categoria?.Descripcion || "Categoría no encontrada"}</td>
                        <td>
                          <div className="d-flex gap-2">
                            <button className="btn btn-sm btn-warning" onClick={() => handleEditarPartidoAPI(p)}>
                              Actualizar
                            </button>
                            <button className="btn btn-sm btn-danger" onClick={() => handleBorrarPartidoAPI(p.idPartidos)}>
                              Borrar
                            </button>
                          </div>
                        </td>
                      </tr>
                    );
                  })
                ) : (
                  <tr>
                    <td colSpan="7" className="text-center">
                      {searchTermPartido ? "No se encontraron partidos." : "No hay partidos programados"}
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>

          {/* Paginación de partidos */}
          <Pagination
            currentPage={currentPagePartido}
            totalPages={totalPagesPartido}
            onPageChange={handlePageChangePartido}
          />

          <div className="mt-4">
            <h4 className="mb-3">{editingId && editingType === "PartidoAPI" ? "Editar Partido" : "Agregar Partido"}</h4>

            {loadingCategorias ? (
              <div className="alert alert-info">Cargando Partidos...</div>
            ) : (
              <form
                className="row g-3"
                onSubmit={editingId && editingType === "PartidoAPI" ? handleGuardar : handleAgregarPartidoAPI}
              >
                <div className="col-md-6">
                  <label className="form-label">Equipo Rival</label>
                  <input
                    type="text"
                    className="form-control"
                    value={formPartidoAPI.EquipoRival}
                    onChange={(e) => setFormPartidoAPI({ ...formPartidoAPI, EquipoRival: e.target.value })}
                    required
                    placeholder="Ingrese el nombre del equipo rival"
                  />
                </div>

                <div className="col-md-6">
                  <label className="form-label">Categoría</label>
                  <select
                    className="form-select"
                    value={formPartidoAPI.idCategorias}
                    onChange={(e) => setFormPartidoAPI({ ...formPartidoAPI, idCategorias: e.target.value })}
                    required
                  >
                    <option value="">Seleccione una categoría</option>
                    {categoriasAPI.length > 0 ? (
                      categoriasAPI.map((categoria) => (
                        <option key={categoria.idCategorias} value={categoria.idCategorias}>
                          {categoria.Descripcion || `Categoría ${categoria.idCategorias}`}
                        </option>
                      ))
                    ) : (
                      <option value="" disabled>No hay categorías disponibles</option>
                    )}
                  </select>
                </div>

                <div className="col-md-6">
                  <label className="form-label">Fecha</label>
                  <input
                    type="date"
                    className="form-control"
                    value={formPartidoAPI.FechaDeEventos}
                    onChange={(e) => setFormPartidoAPI({ ...formPartidoAPI, FechaDeEventos: e.target.value })}
                    required
                  />
                </div>

                <div className="col-md-6">
                  <label className="form-label">Ubicación</label>
                  <select
                    className="form-select"
                    value={formPartidoAPI.Ubicacion}
                    onChange={(e) => setFormPartidoAPI({ ...formPartidoAPI, Ubicacion: e.target.value })}
                    required
                  >
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
                    min={1}
                    max={20}
                    value={formPartidoAPI.CanchaPartido}
                    onChange={(e) => setFormPartidoAPI({ ...formPartidoAPI, CanchaPartido: e.target.value })}
                    required
                    placeholder="Número de cancha (1-20)"
                  />
                </div>

                <div className="col-md-6">
                  <label className="form-label">Formación</label>
                  <select
                    className="form-select"
                    value={formPartidoAPI.Formacion}
                    onChange={(e) => setFormPartidoAPI({ ...formPartidoAPI, Formacion: e.target.value })}
                    required
                  >
                    <option value="">Seleccione una formación</option>
                    <option value="4-4-2">4-4-2</option>
                    <option value="4-3-3">4-3-3</option>
                    <option value="3-5-2">3-5-2</option>
                    <option value="4-5-1">4-5-1</option>
                    <option value="5-3-2">5-3-2</option>
                  </select>
                </div>

                <div className="col-12 d-flex gap-2">
                  <button type="submit" className="btn btn-danger">
                    {editingId && editingType === "PartidoAPI" ? "Guardar Cambios" : "Agregar Partido"}
                  </button>

                  {editingId && editingType === "PartidoAPI" && (
                    <button type="button" className="btn btn-secondary" onClick={handleCancelarEdicion}>
                      Cancelar
                    </button>
                  )}
                </div>
              </form>
            )}
          </div>
        </section>
      </main>

      <footer className="bg-darktext-white text-center py-3">
        <p className="mb-0">&copy; 2024 SCORD. Todos los derechos reservados.</p>
      </footer>
      <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
    </div>
  );
};

export default CrEntrenador;