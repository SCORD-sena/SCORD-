import React, { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import NavbarAdmin from "../../componentes/NavbarAdmin";
import api from "../../config/axiosConfig";
import Swal from "sweetalert2";
import withReactContent from "sweetalert2-react-content";

const MySwal = withReactContent(Swal);

const EstadisticasJugador = () => {
  const [jugadores, setJugadores] = useState([]);
  const [categorias, setCategorias] = useState([]);
  const [categoriaSeleccionada, setCategoriaSeleccionada] = useState("");
  const [jugadorSeleccionado, setJugadorSeleccionado] = useState(null);
  const [jugadoresFiltrados, setJugadoresFiltrados] = useState([]);
  const [estadisticasTotales, setEstadisticasTotales] = useState(null);
  const [modoEdicion, setModoEdicion] = useState(false);
  const [loading, setLoading] = useState(false);

  // Estado para el formulario de edición
  const [formData, setFormData] = useState({
    goles: "",
    golesDeCabeza: "",
    minutosJugados: "",
    asistencias: "",
    tirosApuerta: "",
    tarjetasRojas: "",
    tarjetasAmarillas: "",
    fuerasDeLugar: "",
    arcoEnCero: ""
  });

  // Cargar datos iniciales
  useEffect(() => {
    fetchJugadores();
    fetchCategorias();
  }, []);

  // Filtrar jugadores cuando cambia la categoría
  useEffect(() => {
    if (categoriaSeleccionada) {
      const filtrados = jugadores.filter((jugador) => {
        return jugador.categoria && jugador.categoria.idCategorias === parseInt(categoriaSeleccionada);
      });
      
      setJugadoresFiltrados(filtrados);
      setJugadorSeleccionado(null);
      setEstadisticasTotales(null);
      setModoEdicion(false);
    } else {
      setJugadoresFiltrados([]);
      setJugadorSeleccionado(null);
      setEstadisticasTotales(null);
      setModoEdicion(false);
    }
  }, [categoriaSeleccionada, jugadores]);

  const fetchJugadores = async () => {
    try {
      const res = await api.get("/jugadores");
      setJugadores(res.data.data || res.data);
    } catch (err) {
      console.error("Error fetching jugadores:", err);
      Swal.fire({
        icon: "error",
        title: "Error",
        text: "No se pudieron cargar los jugadores",
        confirmButtonColor: "#e63946",
      });
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

  const fetchEstadisticasTotales = async (idJugador) => {
    setLoading(true);
    try {
      const res = await api.get(`/rendimientospartidos/jugador/${idJugador}/totales`);
      setEstadisticasTotales(res.data.data);
    } catch (err) {
      console.error("Error fetching estadísticas:", err);
      Swal.fire({
        icon: "error",
        title: "Error",
        text: "No se pudieron cargar las estadísticas",
        confirmButtonColor: "#e63946",
      });
    } finally {
      setLoading(false);
    }
  };

  // Función para activar modo edición
  const activarEdicion = () => {
    if (!jugadorSeleccionado) {
      Swal.fire({
        icon: "warning",
        title: "No hay jugador seleccionado",
        text: "Por favor selecciona un jugador primero",
        confirmButtonColor: "#e63946",
      });
      return;
    }

    // Cargar el último registro para editar
    cargarUltimoRegistroParaEditar();
  };

  const cargarUltimoRegistroParaEditar = async () => {
    try {
      console.log("Cargando último registro para jugador:", jugadorSeleccionado.idJugadores);
      
      // USAR LA NUEVA RUTA ESPECÍFICA
      const res = await api.get(`/rendimientospartidos/jugador/${jugadorSeleccionado.idJugadores}/ultimo-registro`);
      console.log("Respuesta de último registro:", res.data);
      
      if (res.data.success && res.data.data) {
        const ultimoRegistro = res.data.data;
        console.log("Último registro encontrado:", ultimoRegistro);

        setFormData({
          goles: ultimoRegistro.Goles || "",
          golesDeCabeza: ultimoRegistro.GolesDeCabeza || "",
          minutosJugados: ultimoRegistro.MinutosJugados || "",
          asistencias: ultimoRegistro.Asistencias || "",
          tirosApuerta: ultimoRegistro.TirosApuerta || "",
          tarjetasRojas: ultimoRegistro.TarjetasRojas || "",
          tarjetasAmarillas: ultimoRegistro.TarjetasAmarillas || "",
          fuerasDeLugar: ultimoRegistro.FuerasDeLugar || "",
          arcoEnCero: ultimoRegistro.ArcoEnCero || ""
        });

        setModoEdicion(true);
      } else {
        Swal.fire({
          icon: "warning",
          title: "Sin registros",
          text: res.data.message || "No hay estadísticas registradas para este jugador",
          confirmButtonColor: "#e63946"
        });
      }
    } catch (err) {
      console.error("Error completo cargando último registro:", err);
      console.error("Detalles del error:", err.response?.data);
      
      let errorMsg = "No se pudieron cargar los datos para editar";
      
      if (err.response?.data?.message) {
        errorMsg = err.response.data.message;
      } else if (err.response?.status === 404) {
        errorMsg = "No se encontraron registros para este jugador";
      }
      
      Swal.fire({
        icon: "error",
        title: "Error",
        text: errorMsg,
        confirmButtonColor: "#e63946"
      });
    }
  };

  const cancelarEdicion = () => {
    setModoEdicion(false);
    setFormData({
      goles: "",
      golesDeCabeza: "",
      minutosJugados: "",
      asistencias: "",
      tirosApuerta: "",
      tarjetasRojas: "",
      tarjetasAmarillas: "",
      fuerasDeLugar: "",
      arcoEnCero: ""
    });
  };

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const guardarCambios = async () => {
    if (!validarFormulario(formData)) return;

    const result = await Swal.fire({
      title: "¿Estás Seguro?",
      html: `
        <b>Goles:</b> ${formData.goles} <br/>
        <b>Asistencias:</b> ${formData.asistencias} <br/>
        <b>Minutos Jugados:</b> ${formData.minutosJugados}
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
      const res = await api.get(`/rendimientospartidos/jugador/${jugadorSeleccionado.idJugadores}/ultimo-registro`);
      
      console.log("📦 Respuesta de último registro para actualizar:", res.data);
      
      if (res.data.success && res.data.data) {
        const ultimoRegistro = res.data.data;
        
        console.log("🎯 ID del registro a actualizar:", ultimoRegistro.IdRendimientos);
        
        const estadisticasData = {
          Goles: parseInt(formData.goles) || 0,
          GolesDeCabeza: parseInt(formData.golesDeCabeza) || 0,
          MinutosJugados: parseInt(formData.minutosJugados) || 0,
          Asistencias: parseInt(formData.asistencias) || 0,
          TirosApuerta: parseInt(formData.tirosApuerta) || 0,
          TarjetasRojas: parseInt(formData.tarjetasRojas) || 0,
          TarjetasAmarillas: parseInt(formData.tarjetasAmarillas) || 0,
          FuerasDeLugar: parseInt(formData.fuerasDeLugar) || 0,
          ArcoEnCero: parseInt(formData.arcoEnCero) || 0,
          idPartidos: ultimoRegistro.idPartidos,
          idJugadores: jugadorSeleccionado.idJugadores
        };

        console.log("📤 Datos a enviar:", estadisticasData);

        const updateRes = await api.put(`/rendimientospartidos/${ultimoRegistro.IdRendimientos}`, estadisticasData);
        
        console.log("✅ Respuesta de actualización:", updateRes.data);

        // Recargar todo antes de salir del modo edición
        await fetchEstadisticasTotales(jugadorSeleccionado.idJugadores);
        
        setModoEdicion(false);

        await Swal.fire({
          icon: "success",
          title: "Estadísticas actualizadas",
          text: "Los datos se actualizaron correctamente.",
          confirmButtonColor: "#28a745",
        });

      } else {
        throw new Error("No se encontró el registro a actualizar");
      }
    } catch (err) {
      console.error("❌ Error actualizando estadísticas:", err);
      console.error("📋 Detalles del error:", err.response?.data);

      let errorMsg = "No se pudo actualizar las estadísticas";

      if (err.response?.data?.errors) {
        const errors = err.response.data.errors;
        errorMsg = Object.values(errors).flat().join("\n");
      } else if (err.response?.data?.message) {
        errorMsg = err.response.data.message;
      } else if (err.message) {
        errorMsg = err.message;
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
    const camposNumericos = [
      { key: "goles", label: "Goles" },
      { key: "golesDeCabeza", label: "Goles de Cabeza" },
      { key: "minutosJugados", label: "Minutos Jugados" },
      { key: "asistencias", label: "Asistencias" },
      { key: "tirosApuerta", label: "Tiros a Puerta" },
      { key: "tarjetasRojas", label: "Tarjetas Rojas" },
      { key: "tarjetasAmarillas", label: "Tarjetas Amarillas" },
      { key: "arcoEnCero", label: "Arco en Cero" }
    ];

    for (const campo of camposNumericos) {
      const valor = values[campo.key];
      if (valor && (isNaN(valor) || parseInt(valor) < 0)) {
        Swal.fire({
          icon: "warning",
          title: "Valor inválido",
          text: `El campo "${campo.label}" debe ser un número positivo.`,
          confirmButtonColor: "#d33",
        });
        return false;
      }
    }

    // Validar minutos jugados (máximo 120 minutos por partido)
    if (values.minutosJugados && parseInt(values.minutosJugados) > 120) {
      Swal.fire({
        icon: "error",
        title: "Minutos inválidos",
        text: "Los minutos jugados no pueden ser mayores a 120 por partido.",
        confirmButtonColor: "#d33",
      });
      return false;
    }

    return true;
  };

  const eliminarEstadistica = async () => {
    if (!jugadorSeleccionado) {
      Swal.fire({
        icon: "warning",
        title: "No hay jugador seleccionado",
        text: "Por favor selecciona un jugador primero",
        confirmButtonColor: "#e63946",
      });
      return;
    }

    const result = await Swal.fire({
      title: "¿Estás seguro?",
      text: "Se eliminará el último registro de estadísticas",
      icon: "warning",
      showCancelButton: true,
      confirmButtonText: "Sí, eliminar",
      cancelButtonText: "Cancelar",
      confirmButtonColor: "#d33",
      cancelButtonColor: "#28a745"
    });

    if (result.isConfirmed) {
      try {
        let ultimoRegistro = null;
        
        // Intenta con la ruta de último registro
        try {
          const resUltimoRegistro = await api.get(`/rendimientospartidos/jugador/${jugadorSeleccionado.idJugadores}/ultimo-registro`);
          if (resUltimoRegistro.data.success && resUltimoRegistro.data.data) {
            ultimoRegistro = resUltimoRegistro.data.data;
          }
        } catch (error) {
          console.log("No se pudo obtener último registro con ruta específica.");
        }

        if (ultimoRegistro && ultimoRegistro.IdRendimientos) {
          console.log("Eliminando registro con ID:", ultimoRegistro.IdRendimientos);
          
          await api.delete(`/rendimientospartidos/${ultimoRegistro.IdRendimientos}`);
          
          Swal.fire({
            icon: "success",
            title: "¡Estadística eliminada!",
            text: "El último registro se eliminó correctamente",
            confirmButtonColor: "#28a745"
          });
          
          // Recargar estadísticas
          fetchEstadisticasTotales(jugadorSeleccionado.idJugadores);
          setModoEdicion(false);
        } else {
          Swal.fire({
            icon: "warning",
            title: "Sin registros",
            text: "No hay estadísticas para eliminar para este jugador",
            confirmButtonColor: "#e63946"
          });
        }
      } catch (err) {
        console.error("Error completo eliminando estadística:", err);
        console.error("Respuesta del error:", err.response?.data);
        
        let errorMsg = "No se pudo eliminar la estadística";
        
        if (err.response?.data?.message) {
          errorMsg = err.response.data.message;
        } else if (err.response?.status === 404) {
          errorMsg = "El registro no fue encontrado";
        } else if (err.response?.status === 401) {
          errorMsg = "No tienes permisos para eliminar";
        } else if (err.message) {
          errorMsg = err.message;
        }
        
        Swal.fire({
          icon: "error",
          title: "Error",
          text: errorMsg,
          confirmButtonColor: "#e63946"
        });
      }
    }
  };

  const handleCategoriaChange = (e) => {
    setCategoriaSeleccionada(e.target.value);
  };

  const handleJugadorChange = (e) => {
    const jugadorId = parseInt(e.target.value);
    const jugador = jugadores.find(j => j.idJugadores === jugadorId);
    setJugadorSeleccionado(jugador);
    setModoEdicion(false);
    
    if (jugadorId) {
      fetchEstadisticasTotales(jugadorId);
    } else {
      setEstadisticasTotales(null);
    }
  };

  // Calcular edad
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

  // ===========================================
  // === LÓGICA DE REPORTE INDIVIDUAL (MODIFICADA) ==
  // ===========================================

  // La función ahora solo recibe el idJugador
  const generarReporte = async (idJugador) => { 
    Swal.fire({
      title: 'Generando Reporte...',
      allowOutsideClick: false,
      didOpen: () => {
        Swal.showLoading();
      }
    });

    try {
      // LLAMADA AL BACKEND DE LARAVEL (MODIFICADA para coincidir con /reportes/jugador/{idJugador}/pdf)
      const res = await api.get(`/reportes/jugador/${idJugador}/pdf`, { 
        responseType: 'blob', // Importante para manejar archivos binarios (PDF)
      });

      Swal.close(); // Cierra el loading

      // Manejo de la descarga del archivo
      const file = new Blob([res.data], { type: 'application/pdf' });
      const fileURL = URL.createObjectURL(file);
      
      const link = document.createElement('a');
      link.href = fileURL;
      link.setAttribute('download', `reporte_jugador_${idJugador}.pdf`); // Nombre del archivo por defecto
      document.body.appendChild(link);
      link.click();
      link.remove();
      URL.revokeObjectURL(fileURL); // Limpiar la URL temporal

      Swal.fire({
        icon: "success",
        title: "Reporte Generado",
        text: "La descarga del reporte ha iniciado.",
        confirmButtonColor: "#28a745",
      });
    } catch (err) {
      console.error("Error generando reporte:", err);
      // El mensaje de error es más genérico ya que el 404 ya no debería ocurrir si la ruta es correcta.
      Swal.fire({
        icon: "error",
        title: "Error",
        text: "No se pudo generar el reporte. Verifique que el jugador tenga registros o revise el backend.",
        confirmButtonColor: "#e63946",
      });
    }
  };

  const handleGenerarReporte = async () => {
    // Transforma la lista de jugadores para facilitar el filtrado en el modal
    const jugadoresReporte = jugadores.map(j => ({
      id: j.idJugadores,
      nombre: `${j.persona?.Nombre1 || ''} ${j.persona?.Apellido1 || ''}`.trim(),
      idCategoria: j.categoria?.idCategorias,
    }));

    let categoriaSelect = "";
    let jugadorSelect = "";

    // Construye el HTML con los selects
    const htmlContent = `
      <div class="mb-3 text-start">
        <label for="swal-categoria" class="form-label fw-semibold">Categoría:</label>
        <select id="swal-categoria" class="form-select">
          <option value="">-- Seleccionar Categoría --</option>
          ${categorias.map(cat => 
            `<option value="${cat.idCategorias}">${cat.Descripcion}</option>`
          ).join('')}
        </select>
      </div>
      <div class="mb-3 text-start">
        <label for="swal-jugador" class="form-label fw-semibold">Jugador:</label>
        <select id="swal-jugador" class="form-select" disabled>
          <option value="">-- Seleccionar Jugador --</option>
        </select>
      </div>
    `;

    await MySwal.fire({
      title: <strong>Generar Reporte Individual</strong>,
      html: htmlContent,
      icon: "question",
      showCancelButton: true,
      confirmButtonText: "Generar",
      cancelButtonText: "Cancelar",
      confirmButtonColor: "#17a2b8", // Color para el reporte
      cancelButtonColor: "#d33",
      focusConfirm: false,
      didOpen: () => {
        const categoriaEl = document.getElementById('swal-categoria');
        const jugadorEl = document.getElementById('swal-jugador');

        // Lógica para actualizar el select de jugadores al cambiar la categoría (en el DOM de SweetAlert)
        categoriaEl.addEventListener('change', (e) => {
          categoriaSelect = e.target.value;
          jugadorEl.innerHTML = '<option value="">-- Seleccionar Jugador --</option>'; // Limpiar

          if (categoriaSelect) {
            const filteredPlayers = jugadoresReporte.filter(j => 
              j.idCategoria === parseInt(categoriaSelect)
            );
            
            filteredPlayers.forEach(jug => {
              const option = document.createElement('option');
              option.value = jug.id;
              option.textContent = jug.nombre;
              jugadorEl.appendChild(option);
            });
            jugadorEl.disabled = false;
          } else {
            jugadorEl.disabled = true;
            jugadorSelect = "";
          }
        });
        
        jugadorEl.addEventListener('change', (e) => {
          jugadorSelect = e.target.value;
        });
      },
      preConfirm: () => {
        // Se valida que ambos existan, pero solo se pasa el idJugador a la función generarReporte
        const catId = document.getElementById('swal-categoria').value; 
        const jugId = document.getElementById('swal-jugador').value;

        if (!catId || !jugId) {
          Swal.showValidationMessage('Debes seleccionar una categoría y un jugador');
          return false;
        }

        // Solo se devuelve el idJugador
        return { idJugador: jugId };
      }
    }).then((result) => {
      if (result.isConfirmed && result.value) {
        // Llama a generarReporte solo con el ID del Jugador
        generarReporte(result.value.idJugador); 
      }
    });
  };
  // ===========================================
  // ===========================================


  const persona = jugadorSeleccionado?.persona || null;
  const categoriaJugador = jugadorSeleccionado?.categoria || {};


  return (
    <div>
      <meta charSet="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Inicio - SCORD</title>
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossOrigin="anonymous" />
      <link rel="stylesheet" href="/Css/InicioAdmin.css" />
      
      <header className="header bg-white shadow-sm py-3">
        <nav className="navbar container d-flex align-items-center justify-content-between flex-wrap">
          <div className="d-flex align-items-center">
            <img src="/Img/SCORD.png" alt="Logo SCORD" className="me-2" style={{height: '60px'}} />
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

      {/* BOTONES DE ACCIÓN */}
      <div className="d-flex justify-content-center my-5 gap-2 flex-wrap">
        <Link to="/AgregarEstadisticas" className="btn btn-success fw-bold">Agregar Estadísticas</Link>
        
        {/* BOTÓN DE REPORTE */}
        <button className="btn btn-info fw-bold text-white" onClick={handleGenerarReporte} disabled={modoEdicion}>
          Generar Reporte 📝
        </button>

        {!modoEdicion ? (
          <>
            <button className="btn btn-warning fw-bold" onClick={activarEdicion}>
              Editar Estadísticas
            </button>
            <button className="btn btn-danger fw-bold" onClick={eliminarEstadistica}>
              Eliminar Estadísticas
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


      <main className="container my-5">
        <div className="row g-5 align-items-start">
          {/* Columna izquierda - Información del Jugador */}
          <div className="col-md-6">
            <div className="card shadow-sm rounded-3 h-100">
              <div className="card-body text-center">
                {/* Selección */}
                <div className="mb-3">
                  <label htmlFor="categoriaSelect" className="form-label fw-semibold text-danger">Seleccionar Categoría:</label>
                  <select 
                    className="form-select mx-auto" 
                    id="categoriaSelect" 
                    style={{ maxWidth: "300px" }}
                    value={categoriaSeleccionada}
                    onChange={handleCategoriaChange}
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
                  <label htmlFor="jugadorSelect" className="form-label fw-semibold text-danger">Seleccionar Jugador:</label>
                  <select 
                    className="form-select mx-auto" 
                    id="jugadorSelect" 
                    style={{ maxWidth: "300px" }}
                    value={jugadorSeleccionado?.idJugadores || ""}
                    onChange={handleJugadorChange}
                    disabled={!categoriaSeleccionada || modoEdicion}
                  >
                    <option value="">-- Selecciona un jugador --</option>
                    {jugadoresFiltrados.map((jugador) => {
                      const pers = jugador.persona;
                      return (
                        <option key={jugador.idJugadores} value={jugador.idJugadores}>
                          {pers ? `${pers.Nombre1} ${pers.Apellido1}` : "Sin nombre"}
                        </option>
                      );
                    })}
                  </select>
                </div>

                {/* Foto y datos */}
                <img src="/Img/Foto_Perfil.webp" alt="Foto de Perfil"
                  className="rounded-circle shadow mb-4"
                  style={{ width: "150px" }} />
                
                <h5 className="fw-bold mb-3 text-danger">Información Personal</h5>
                <ul className="list-group list-group-flush text-start">
                  <li className="list-group-item d-flex justify-content-between">
                    <strong>Nombre:</strong> 
                    <span>
                      {persona ? `${persona.Nombre1} ${persona.Nombre2 || ''} ${persona.Apellido1} ${persona.Apellido2 || ''}`.trim() : "-"}
                    </span>
                  </li>
                  <li className="list-group-item d-flex justify-content-between">
                    <strong>Edad:</strong> 
                    <span>{persona ? calcularEdad(persona.FechaDeNacimiento) : "-"}</span>
                  </li>
                  <li className="list-group-item d-flex justify-content-between">
                    <strong>Documento:</strong> 
                    <span>{persona?.NumeroDeDocumento || "-"}</span>
                  </li>
                  <li className="list-group-item d-flex justify-content-between">
                    <strong>Contacto:</strong> 
                    <span>{persona?.Telefono || "-"}</span>
                  </li>
                </ul>

                <h5 className="fw-bold mt-4 mb-3 text-danger">Información Deportiva</h5>
                <ul className="list-group list-group-flush text-start">
                  <li className="list-group-item d-flex justify-content-between">
                    <strong>Categoría:</strong> 
                    <span>{categoriaJugador.Descripcion || "-"}</span>
                  </li>
                  <li className="list-group-item d-flex justify-content-between">
                    <strong>Dorsal:</strong> 
                    <span>{jugadorSeleccionado?.Dorsal || "-"}</span>
                  </li>
                  <li className="list-group-item d-flex justify-content-between">
                    <strong>Posición:</strong> 
                    <span>{jugadorSeleccionado?.Posicion || "-"}</span>
                  </li>
                </ul>
              </div>
            </div>
          </div>

          {/* Columna derecha - Estadísticas */}
          <div className="col-md-6">
            <div className="card shadow-sm rounded-3 h-100">
              <div className="card-body">
                {/* NUEVO HEADER CON LOGO */}
                <div className="text-center mb-4">
                  <div className="d-flex align-items-center justify-content-center mb-2">
                    <img 
                      src="/Img/SCORD.png" 
                      alt="Logo SCORD" 
                      style={{ height: '40px', marginRight: '10px' }} 
                    />
                    <h3 className="fw-semibold mb-0" style={{ color: '#e63946' }}>Estadísticas</h3>
                  </div>
                </div>
                
                {loading ? (
                  <div className="text-center">
                    <div className="spinner-border text-danger" role="status">
                      <span className="visually-hidden">Cargando...</span>
                    </div>
                    <p className="mt-2">Cargando estadísticas...</p>
                  </div>
                ) : estadisticasTotales ? (
                  <>
                    {/* Estadísticas Básicas - MODO EDICIÓN */}
                    <h4 className="text-center fw-semibold mb-4">
                      {modoEdicion ? "Editar Último Partido" : "Estadísticas Básicas"}
                    </h4>
                    
                    <ul className="list-group list-group-flush mb-4">
                      <li className="list-group-item d-flex justify-content-between align-items-center">
                        <span className="fw-semibold text-danger">⚽ Goles:</span>
                        {modoEdicion ? (
                          <input
                            type="number"
                            name="goles"
                            className="form-control form-control-sm"
                            style={{ maxWidth: "100px" }}
                            value={formData.goles}
                            onChange={handleChange}
                            min="0"
                          />
                        ) : (
                          <span>{estadisticasTotales.totales?.total_goles || 0}</span>
                        )}
                      </li>
                      <li className="list-group-item d-flex justify-content-between align-items-center">
                        <span className="fw-semibold text-danger">🎯 Asistencias:</span>
                        {modoEdicion ? (
                          <input
                            type="number"
                            name="asistencias"
                            className="form-control form-control-sm"
                            style={{ maxWidth: "100px" }}
                            value={formData.asistencias}
                            onChange={handleChange}
                            min="0"
                          />
                        ) : (
                          <span>{estadisticasTotales.totales?.total_asistencias || 0}</span>
                        )}
                      </li>
                      <li className="list-group-item d-flex justify-content-between align-items-center">
                        <span className="fw-semibold text-danger">📋 Partidos:</span>
                        <span>{estadisticasTotales.totales?.total_partidos_jugados || 0}</span>
                      </li>
                      <li className="list-group-item d-flex justify-content-between align-items-center">
                        <span className="fw-semibold text-danger">⏱️ Minutos:</span>
                        {modoEdicion ? (
                          <input
                            type="number"
                            name="minutosJugados"
                            className="form-control form-control-sm"
                            style={{ maxWidth: "100px" }}
                            value={formData.minutosJugados}
                            onChange={handleChange}
                            min="0"
                            max="120"
                          />
                        ) : (
                          <span>{estadisticasTotales.totales?.total_minutos_jugados || 0}</span>
                        )}
                      </li>
                    </ul>

                    {/* Estadísticas Detalladas - MODO EDICIÓN */}
                    <h4 className="text-center fw-semibold mb-4">Estadísticas Detalladas</h4>
                    <ul className="list-group list-group-flush">
                      <li className="list-group-item d-flex justify-content-between align-items-center">
                        <span className="text-danger">⚽ Goles de Cabeza</span>
                        {modoEdicion ? (
                          <input
                            type="number"
                            name="golesDeCabeza"
                            className="form-control form-control-sm"
                            style={{ maxWidth: "100px" }}
                            value={formData.golesDeCabeza}
                            onChange={handleChange}
                            min="0"
                          />
                        ) : (
                          <span>{estadisticasTotales.totales?.total_goles_cabeza || 0}</span>
                        )}
                      </li>
                      <li className="list-group-item d-flex justify-content-between align-items-center">
                        <span className="text-danger">📊 Goles por Partido</span>
                        <span>{estadisticasTotales.promedios?.goles_por_partido || 0}</span>
                      </li>
                      <li className="list-group-item d-flex justify-content-between align-items-center">
                        <span className="text-danger">🎯 Tiros a puerta</span>
                        {modoEdicion ? (
                          <input
                            type="number"
                            name="tirosApuerta"
                            className="form-control form-control-sm"
                            style={{ maxWidth: "100px" }}
                            value={formData.tirosApuerta}
                            onChange={handleChange}
                            min="0"
                          />
                        ) : (
                          <span>{estadisticasTotales.totales?.total_tiros_apuerta || 0}</span>
                        )}
                      </li>
                      <li className="list-group-item d-flex justify-content-between align-items-center">
                        <span className="text-danger">🚩 Fueras de Juego</span>
                          {modoEdicion ? (
                                 <input
                            type="number"
                            name="fuerasDeLugar"
                            className="form-control form-control-sm"
                            style={{ maxWidth: "100px" }}
                            value={formData.fuerasDeLugar}
                            onChange={handleChange}
                            min="0"
                          />
                          ) : (
                          <span>{estadisticasTotales.totales?.total_fueras_de_lugar || 0}</span>
                          )}
                      </li>
                      <li className="list-group-item d-flex justify-content-between align-items-center">
                        <span className="text-danger">🟨 Tarjetas Amarillas</span>
                        {modoEdicion ? (
                          <input
                            type="number"
                            name="tarjetasAmarillas"
                            className="form-control form-control-sm"
                            style={{ maxWidth: "100px" }}
                            value={formData.tarjetasAmarillas}
                            onChange={handleChange}
                            min="0"
                          />
                        ) : (
                          <span>{estadisticasTotales.totales?.total_tarjetas_amarillas || 0}</span>
                        )}
                      </li>
                      <li className="list-group-item d-flex justify-content-between align-items-center">
                        <span className="text-danger">🟥 Tarjetas Rojas</span>
                        {modoEdicion ? (
                          <input
                            type="number"
                            name="tarjetasRojas"
                            className="form-control form-control-sm"
                            style={{ maxWidth: "100px" }}
                            value={formData.tarjetasRojas}
                            onChange={handleChange}
                            min="0"
                          />
                        ) : (
                          <span>{estadisticasTotales.totales?.total_tarjetas_rojas || 0}</span>
                        )}
                      </li>
                      <li className="list-group-item d-flex justify-content-between align-items-center">
                        <span className="text-danger">🧤 Arco en cero</span>
                        {modoEdicion ? (
                          <input
                            type="number"
                            name="arcoEnCero"
                            className="form-control form-control-sm"
                            style={{ maxWidth: "100px" }}
                            value={formData.arcoEnCero}
                            onChange={handleChange}
                            min="0"
                          />
                        ) : (
                          <span>{estadisticasTotales.totales?.total_arco_en_cero || 0}</span>
                        )}
                      </li>
                    </ul>
                  </>
                ) : (
                  <div className="text-center text-muted">
                    <p>Selecciona un jugador para ver sus estadísticas totales o editar su último registro.</p>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
};

export default EstadisticasJugador;