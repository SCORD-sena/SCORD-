import React, { useEffect, useState } from "react";
import axios from "axios";
import NavbarAdmin from "../../componentes/NavbarAdmin";

const ResultadosAdmin = () => {
  const [resultados, setResultados] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const [showModal, setShowModal] = useState(false);
  const [modalMode, setModalMode] = useState("crear"); // crear | editar | ver
  const [filtroMarcador, setFiltroMarcador] = useState("");
  const [filtroPuntos, setFiltroPuntos] = useState("");
  const [filtroPartido, setFiltroPartido] = useState("");

  const [selectedResultado, setSelectedResultado] = useState({
    idResultados: "",
    Marcador: "",
    PuntosObtenidos: "",
    Observacion: "",
    idPartidos: "",
  });

  /* =========================
     CARGAR RESULTADOS
  ========================= */
  useEffect(() => {
    cargarResultados();
  }, []);

  const cargarResultados = async () => {
  try {
    setLoading(true);
    const res = await axios.get("http://127.0.0.1:8000/api/resultados");

    // 🔥 ASEGURAMOS QUE SEA ARRAY
    setResultados(Array.isArray(res.data.data) ? res.data.data : []);
  } catch (err) {
    console.error(err);
    setError("Error al cargar los resultados");
    setResultados([]);
  } finally {
    setLoading(false);
  }
};

const eliminarResultado = async (id) => {
  if (!window.confirm("¿Estás seguro de eliminar este resultado?")) return;

  try {
    await axios.delete(`http://127.0.0.1:8000/api/resultados/${id}`);

    // Actualizar tabla sin volver a pedir todo
    setResultados(resultados.filter(r => r.idResultados !== id));

  } catch (error) {
    alert("Error al eliminar el resultado");
  }
};

  /* =========================
     MODAL
  ========================= */
  const abrirModal = (mode, resultado = null) => {
    setModalMode(mode);
    if (resultado) {
      setSelectedResultado(resultado);
    } else {
      setSelectedResultado({
        idResultados: "",
        Marcador: "",
        PuntosObtenidos: "",
        Observacion: "",
        idPartidos: "",
      });
    }
    setShowModal(true);
  };

  const cerrarModal = () => {
    setShowModal(false);
  };

  /* =========================
     FORMULARIO
  ========================= */
  const handleChange = (e) => {
    const { name, value } = e.target;
    setSelectedResultado((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    try {
      if (modalMode === "crear") {
        await axios.post("http://127.0.0.1:8000/api/resultados", selectedResultado);
      }

      if (modalMode === "editar") {
        await axios.put(
          `http://127.0.0.1:8000/api/resultados/${selectedResultado.idResultados}`,
          selectedResultado
        );
      }

      cerrarModal();
      cargarResultados();
    } catch (err) {
      alert("Error al guardar el resultado");
    }

  };

  

    const resultadosFiltrados = resultados.filter((res) => {
      return (
        (filtroMarcador === "" ||
          res.Marcador?.toLowerCase().includes(filtroMarcador.toLowerCase())) &&

        (filtroPuntos === "" ||
          res.PuntosObtenidos?.toString().includes(filtroPuntos)) &&

        (filtroPartido === "" ||
          res.idPartidos?.toString().includes(filtroPartido))
      );
    });

  /* =========================
     RENDER
  ========================= */
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
      {/* HEADER */}
      <div className="row mb-4">
        <div className="col-12">
          <h1 className="text-danger fw-bold">Gestión de Resultados</h1>
        </div>
      </div>

      <header className="header bg-white shadow-sm py-3">
        <nav className="navbar container d-flex align-items-center justify-content-between flex-wrap">
          <div className="d-flex align-items-center">
            <img
              src="/Img/SCORD.png"
              alt="Logo SCORD"
              className="me-2"
              style={{ height: "60px" }}
            />
            <h4 className="mb-0 text-danger fw-bold">SCORD</h4>
          </div>
          <NavbarAdmin/>
        </nav>
      </header>

      {/*Filtro*/}
      {/* =========================
    FILTROS DE BÚSQUEDA
========================= */}
<div className="card mb-4 shadow-sm">
  <div className="card-header bg-danger text-white fw-bold">
    Filtros de Búsqueda
  </div>

  <div className="card-body">
    <div className="row g-3 align-items-end">

      {/* Marcador */}
      <div className="col-md-3">
        <label className="form-label">Marcador</label>
        <input
          type="text"
          className="form-control"
          placeholder="Ej: 2-1"
          value={filtroMarcador}
          onChange={(e) => setFiltroMarcador(e.target.value)}
        />
      </div>

      {/* Puntos */}
      <div className="col-md-3">
        <label className="form-label">Puntos</label>
        <input
          type="number"
          className="form-control"
          placeholder="Ej: 3"
          value={filtroPuntos}
          onChange={(e) => setFiltroPuntos(e.target.value)}
        />
      </div>

      {/* Partido */}
      <div className="col-md-3">
        <label className="form-label">ID Partido</label>
        <input
          type="number"
          className="form-control"
          placeholder="Ej: 10"
          value={filtroPartido}
          onChange={(e) => setFiltroPartido(e.target.value)}
        />
      </div>

      {/* BOTÓN LIMPIAR */}
      <div className="col-md-3 d-grid">
        <button
          className="btn btn-secondary"
          onClick={() => {
            setFiltroMarcador("");
            setFiltroPuntos("");
            setFiltroPartido("");
          }}
        >
          Limpiar filtros
        </button>
      </div>

    </div>
  </div>
</div>



      {/* TABLA */}
      <div className="container mt-4">
        <div className="d-flex justify-content-between align-items-center mb-3">
          <h3>Historial de Resultados</h3>
              <button className="btn btn-danger" onClick={() => abrirModal("crear")}>
        + Agregar Resultado
      </button>

        </div>

        {loading && <p>Cargando...</p>}
        {error && <div className="alert alert-danger">{error}</div>}

        {!loading && !error && (
          <table className="table table-bordered table-hover">
            <thead className="table-dark">
              <tr>
                <th>ID</th>
                <th>Marcador</th>
                <th>Puntos</th>
                <th>Observación</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              {resultadosFiltrados.map((res) => (
                <tr key={res.idResultados}>
                  <td>{res.idResultados}</td>
                  <td>{res.Marcador}</td>
                  <td>{res.PuntosObtenidos}</td>
                  <td>{res.Observacion}</td>
                  <td className="text-center">
                    <button
                      className="btn btn-sm btn-outline-primary me-1"
                      onClick={() => abrirModal("ver", res)}
                    >
                      Ver
                    </button>

                    <button
                      className="btn btn-sm btn-outline-warning me-1"
                      onClick={() => abrirModal("editar", res)}
                    >
                      Editar
                    </button>

                    <button
                      className="btn btn-sm btn-outline-danger"
                      onClick={() => eliminarResultado(res.idResultados)}
                    >
                      Eliminar
                    </button>
                  </td>

                </tr>
              ))}
            </tbody>
                        {resultadosFiltrados.length === 0 && (
              <tr>
                <td colSpan="5" className="text-center text-muted py-3">
                  No se encontraron resultados
                </td>
              </tr>
            )}

          </table>
        )}
      </div>

      {/* MODAL */}
      {showModal && (
        <div className="modal fade show d-block" style={{ backgroundColor: "rgba(0,0,0,0.5)" }}>
          <div className="modal-dialog modal-lg">
            <div className="modal-content">
              <form onSubmit={handleSubmit}>
                <div className="modal-header">
                  <h5 className="modal-title">
                    {modalMode === "crear" && "Agregar Resultado"}
                    {modalMode === "editar" && "Editar Resultado"}
                    {modalMode === "ver" && "Detalle del Resultado"}
                  </h5>
                  <button type="button" className="btn-close" onClick={cerrarModal}></button>
                </div>

                <div className="modal-body">
                  <div className="mb-3">
                    <label className="form-label">Marcador</label>
                    <input
                      type="text"
                      className="form-control"
                      name="Marcador"
                      value={selectedResultado.Marcador}
                      onChange={handleChange}
                      disabled={modalMode === "ver"}
                      required
                    />
                  </div>

                  <div className="mb-3">
                    <label className="form-label">Puntos Obtenidos</label>
                    <input
                      type="number"
                      className="form-control"
                      name="PuntosObtenidos"
                      value={selectedResultado.PuntosObtenidos}
                      onChange={handleChange}
                      disabled={modalMode === "ver"}
                      required
                    />
                  </div>

                  <div className="mb-3">
                    <label className="form-label">Observación</label>
                    <textarea
                      className="form-control"
                      name="Observacion"
                      value={selectedResultado.Observacion}
                      onChange={handleChange}
                      disabled={modalMode === "ver"}
                    />
                  </div>
                </div>

                <div className="modal-footer">
                  <button type="button" className="btn btn-secondary" onClick={cerrarModal}>
                    Cerrar
                  </button>

                  {modalMode !== "ver" && (
                    <button type="submit" className="btn btn-success">
                      Guardar
                    </button>
                  )}
                </div>
              </form>
            </div>
          </div>
        </div>
      )}

    </div>
  );
};

export default ResultadosAdmin;
