import React, { useState } from 'react';
import useHistorial from '../../../hooks/useHistorial';
import ItemEliminadoCard from '../../../componentes/Historial/ItemEliminadoCard';
import SearchBar from '../../../componentes/Historial/SearchBar';
import ContadorResultados from '../../../componentes/Historial/ContadorResultados';
import EmptyState from '../../../componentes/Historial/EmptyState';
import NavbarAdmin from '../../../componentes/NavbarAdmin';



export default function HistorialPage() {
  const [activeTab, setActiveTab] = useState('jugadores');

  return (
    <div>
      <meta charSet="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Historial - SCORD</title>
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" />
      <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" />
      <link rel="stylesheet" href="/Css/Historial.css" />
      <link rel="stylesheet" href="/Css/InicioAdmin.css" />
      
      {/* HEADER */}
      <header className="header bg-white shadow-sm py-3">
        <nav className="navbar container d-flex align-items-center justify-content-between flex-wrap">
          <div className="d-flex align-items-center">
            <img src="/Img/logo.jpg" alt="Logo SCORD" className="me-2" style={{ height: "50px" }} />
            <h4 className="mb-0 text-danger fw-bold">SCORD</h4>
          </div>
          <label className="labe_hamburguesa d-md-none" htmlFor="menu_hamburguesa">
            <svg xmlns="http://www.w3.org/2000/svg" width={35} height={35} fill="#e63946" viewBox="0 0 16 16">
              <path fillRule="evenodd" d="M2.5 12a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5z" />
            </svg>
          </label>
          <input className="menu_hamburguesa d-none" type="checkbox" id="menu_hamburguesa" />
          <NavbarAdmin />
        </nav>
      </header>

      {/* MAIN CONTENT */}
      <main className="container my-5">
        <h1 className="text-center text-danger mb-4">
          <i className="bi bi-clock-history me-2"></i> Historial de Elementos Eliminados
        </h1>

        {/* Tabs de navegación */}
        <ul className="nav nav-tabs mb-4">
          <li className="nav-item">
            <button 
              className={`nav-link ${activeTab === 'jugadores' ? 'active' : ''}`}
              onClick={() => setActiveTab('jugadores')}
            >
              <i className="bi bi-person-fill me-1"></i> Jugadores
            </button>
          </li>
          <li className="nav-item">
            <button 
              className={`nav-link ${activeTab === 'entrenadores' ? 'active' : ''}`}
              onClick={() => setActiveTab('entrenadores')}
            >
              <i className="bi bi-person-badge me-1"></i> Entrenadores
            </button>
          </li>
          <li className="nav-item">
            <button 
              className={`nav-link ${activeTab === 'categorias' ? 'active' : ''}`}
              onClick={() => setActiveTab('categorias')}
            >
              <i className="bi bi-tags me-1"></i> Categorías
            </button>
          </li>
          <li className="nav-item">
            <button 
              className={`nav-link ${activeTab === 'entrenamientos' ? 'active' : ''}`}
              onClick={() => setActiveTab('entrenamientos')}
            >
              <i className="bi bi-calendar-event me-1"></i> Entrenamientos
            </button>
          </li>
          <li className="nav-item">
            <button 
              className={`nav-link ${activeTab === 'partidos' ? 'active' : ''}`}
              onClick={() => setActiveTab('partidos')}
            >
              <i className="bi bi-trophy me-1"></i> Partidos
            </button>
          </li>
          <li className="nav-item">
            <button 
              className={`nav-link ${activeTab === 'rendimientos' ? 'active' : ''}`}
              onClick={() => setActiveTab('rendimientos')}
            >
              <i className="bi bi-graph-up me-1"></i> Rendimientos
            </button>
          </li>
        </ul>

        {/* Contenido de cada tab */}
        <div className="tab-content">
          {activeTab === 'jugadores' && <TabJugadores />}
          {activeTab === 'entrenadores' && <TabEntrenadores />}
          {activeTab === 'categorias' && <TabCategorias />}
          {activeTab === 'entrenamientos' && <TabEntrenamientos />}
          {activeTab === 'partidos' && <TabPartidos />}
          {activeTab === 'rendimientos' && <TabRendimientos />}
        </div>
      </main>
    </div>
  );
}

// ========================================
// COMPONENTE TAB: JUGADORES
// ========================================
function TabJugadores() {
  const { filteredItems, loading, searchItems, restore, deletePermanently } = useHistorial('jugadores');

  const handleRestaurar = async (jugador) => {
    const nombreCompleto = jugador.persona?.Nombre1 
      ? `${jugador.persona.Nombre1} ${jugador.persona.Apellido1}`
      : 'este jugador';

    const confirmar = window.confirm(
      `¿Desea restaurar a ${nombreCompleto}?\n\n` +
      `Dorsal: ${jugador.Dorsal} • Posición: ${jugador.Posicion}\n\n` +
      `Este jugador volverá a estar activo en el sistema.`
    );

    if (!confirmar) return;

    const result = await restore(jugador.idJugadores);
    if (result.success) {
      alert('✅ Jugador restaurado correctamente');
    } else {
      alert(`❌ Error: ${result.error}`);
    }
  };

  const handleEliminar = async (jugador) => {
    const nombreCompleto = jugador.persona?.Nombre1 
      ? `${jugador.persona.Nombre1} ${jugador.persona.Apellido1}`
      : 'este jugador';

    const confirmar = window.confirm(
      `⚠️ ELIMINAR PERMANENTEMENTE\n\n` +
      `¿Está COMPLETAMENTE SEGURO de eliminar a ${nombreCompleto}?\n\n` +
      `Dorsal: ${jugador.Dorsal} • Posición: ${jugador.Posicion}\n\n` +
      `⚠️ ESTA ACCIÓN NO SE PUEDE DESHACER.\n` +
      `Se perderán TODOS los datos relacionados.`
    );

    if (!confirmar) return;

    const result = await deletePermanently(jugador.idJugadores);
    if (result.success) {
      alert('✅ Jugador eliminado permanentemente');
    } else {
      alert(`❌ Error: ${result.error}`);
    }
  };

  if (loading) {
    return (
      <div className="text-center py-5">
        <output className="spinner-border text-danger" >
          <span className="visually-hidden">Cargando...</span>
        </output>
      </div>
    );
  }

  return (
    <div>
      <SearchBar 
        value=""
        onChange={searchItems}
        placeholder="Buscar por nombre, documento, dorsal o posición..."
      />
      <ContadorResultados cantidad={filteredItems.length} texto="jugador(es) eliminado(s)" />
      
      {filteredItems.length === 0 ? (
        <EmptyState mensaje="No hay jugadores eliminados" icono="person-x" />
      ) : (
        <div className="row">
          {filteredItems.map((jugador) => {
            const nombreCompleto = jugador.persona?.Nombre1 
              ? `${jugador.persona.Nombre1} ${jugador.persona.Apellido1}`
              : 'Sin nombre';
            
            const inicial = jugador.persona?.Nombre1?.[0] || 'J';

            return (
              <div key={jugador.idJugadores} className="col-md-6 col-lg-4">
                <ItemEliminadoCard
                  titulo={nombreCompleto}
                  subtitulo1={`Dorsal: ${jugador.Dorsal} • Posición: ${jugador.Posicion}`}
                  subtitulo2={jugador.persona?.NumeroDeDocumento ? `Doc: ${jugador.persona.NumeroDeDocumento}` : null}
                  subtitulo3={jugador.categoria?.Descripcion ? `Categoría: ${jugador.categoria.Descripcion}` : null}
                  inicial={inicial}
                  onRestaurar={() => handleRestaurar(jugador)}
                  onEliminarPermanente={() => handleEliminar(jugador)}
                />
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

// ========================================
// COMPONENTE TAB: ENTRENADORES
// ========================================
function TabEntrenadores() {
  const { filteredItems, loading, searchItems, restore, deletePermanently } = useHistorial('entrenadores');

  const handleRestaurar = async (entrenador) => {
    const nombreCompleto = entrenador.persona?.Nombre1 
      ? `${entrenador.persona.Nombre1} ${entrenador.persona.Apellido1}`
      : 'este entrenador';

    const confirmar = window.confirm(
      `¿Desea restaurar a ${nombreCompleto}?\n\n` +
      `Cargo: ${entrenador.Cargo}\n\n` +
      `Este entrenador volverá a estar activo en el sistema.`
    );

    if (!confirmar) return;

    const result = await restore(entrenador.idEntrenadores);
    if (result.success) {
      alert('✅ Entrenador restaurado correctamente');
    } else {
      alert(`❌ Error: ${result.error}`);
    }
  };

  const handleEliminar = async (entrenador) => {
    const nombreCompleto = entrenador.persona?.Nombre1 
      ? `${entrenador.persona.Nombre1} ${entrenador.persona.Apellido1}`
      : 'este entrenador';

    const confirmar = window.confirm(
      `⚠️ ELIMINAR PERMANENTEMENTE\n\n` +
      `¿Está COMPLETAMENTE SEGURO de eliminar a ${nombreCompleto}?\n\n` +
      `Cargo: ${entrenador.Cargo}\n\n` +
      `⚠️ ESTA ACCIÓN NO SE PUEDE DESHACER.`
    );

    if (!confirmar) return;

    const result = await deletePermanently(entrenador.idEntrenadores);
    if (result.success) {
      alert('✅ Entrenador eliminado permanentemente');
    } else {
      alert(`❌ Error: ${result.error}`);
    }
  };

  if (loading) {
    return (
      <div className="text-center py-5">
        <output className="spinner-border text-danger" >
          <span className="visually-hidden">Cargando...</span>
        </output>
      </div>
    );
  }

  return (
    <div>
      <SearchBar 
        value=""
        onChange={searchItems}
        placeholder="Buscar por nombre, documento o cargo..."
      />
      <ContadorResultados cantidad={filteredItems.length} texto="entrenador(es) eliminado(s)" />
      
      {filteredItems.length === 0 ? (
        <EmptyState mensaje="No hay entrenadores eliminados" icono="person-badge-fill" />
      ) : (
        <div className="row">
          {filteredItems.map((entrenador) => {
            const nombreCompleto = entrenador.persona?.Nombre1 
              ? `${entrenador.persona.Nombre1} ${entrenador.persona.Apellido1}`
              : 'Sin nombre';
            
            const inicial = entrenador.persona?.Nombre1?.[0] || 'E';

            const categoriasTexto = entrenador.categorias && entrenador.categorias.length > 0
              ? entrenador.categorias.map(c => c.Descripcion || c.descripcion).join(', ')
              : 'Sin categorías';

            return (
              <div key={entrenador.idEntrenadores} className="col-md-6 col-lg-4">
                <ItemEliminadoCard
                  titulo={nombreCompleto}
                  subtitulo1={`Cargo: ${entrenador.Cargo} • ${entrenador.AnosDeExperiencia} años exp.`}
                  subtitulo2={entrenador.persona?.NumeroDeDocumento ? `Doc: ${entrenador.persona.NumeroDeDocumento}` : null}
                  subtitulo3={categoriasTexto}
                  inicial={inicial}
                  onRestaurar={() => handleRestaurar(entrenador)}
                  onEliminarPermanente={() => handleEliminar(entrenador)}
                />
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

// ========================================
// COMPONENTE TAB: CATEGORÍAS
// ========================================
function TabCategorias() {
  const { filteredItems, loading, searchItems, restore, deletePermanently } = useHistorial('categorias');

  const handleRestaurar = async (categoria) => {
    const confirmar = window.confirm(
      `¿Desea restaurar la categoría "${categoria.Descripcion}"?\n\n` +
      `Tipo: ${categoria.TiposCategoria}\n\n` +
      `Esta categoría volverá a estar activa en el sistema.`
    );

    if (!confirmar) return;

    const result = await restore(categoria.idCategorias);
    if (result.success) {
      alert('✅ Categoría restaurada correctamente');
    } else {
      alert(`❌ Error: ${result.error}`);
    }
  };

  const handleEliminar = async (categoria) => {
    const confirmar = window.confirm(
      `⚠️ ELIMINAR PERMANENTEMENTE\n\n` +
      `¿Está COMPLETAMENTE SEGURO de eliminar la categoría "${categoria.Descripcion}"?\n\n` +
      `Tipo: ${categoria.TiposCategoria}\n\n` +
      `⚠️ ESTA ACCIÓN NO SE PUEDE DESHACER.`
    );

    if (!confirmar) return;

    const result = await deletePermanently(categoria.idCategorias);
    if (result.success) {
      alert('✅ Categoría eliminada permanentemente');
    } else {
      alert(`❌ Error: ${result.error}`);
    }
  };

  if (loading) {
    return (
      <div className="text-center py-5">
        <output className="spinner-border text-danger" >
          <span className="visually-hidden">Cargando...</span>
        </output>
      </div>
    );
  }

  return (
    <div>
      <SearchBar 
        value=""
        onChange={searchItems}
        placeholder="Buscar por descripción o tipo..."
      />
      <ContadorResultados cantidad={filteredItems.length} texto="categoría(s) eliminada(s)" />
      
      {filteredItems.length === 0 ? (
        <EmptyState mensaje="No hay categorías eliminadas" icono="tags-fill" />
      ) : (
        <div className="row">
          {filteredItems.map((categoria) => (
            <div key={categoria.idCategorias} className="col-md-6 col-lg-4">
              <ItemEliminadoCard
                titulo={categoria.Descripcion}
                subtitulo1={`Tipo: ${categoria.TiposCategoria}`}
                subtitulo2={null}
                subtitulo3={null}
                inicial={categoria.Descripcion[0]}
                onRestaurar={() => handleRestaurar(categoria)}
                onEliminarPermanente={() => handleEliminar(categoria)}
              />
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

// ========================================
// COMPONENTE TAB: ENTRENAMIENTOS
// ========================================
function TabEntrenamientos() {
  const { filteredItems, loading, searchItems, restore, deletePermanently } = useHistorial('entrenamientos');

  const handleRestaurar = async (entrenamiento) => {
    const confirmar = window.confirm(
      `¿Desea restaurar este entrenamiento?\n\n` +
      `Fecha: ${entrenamiento.FechaDeEventos}\n` +
      `Ubicación: ${entrenamiento.Ubicacion}\n\n` +
      `Este entrenamiento volverá a estar activo en el sistema.`
    );

    if (!confirmar) return;

    const result = await restore(entrenamiento.idCronogramas);
    if (result.success) {
      alert('✅ Entrenamiento restaurado correctamente');
    } else {
      alert(`❌ Error: ${result.error}`);
    }
  };

  const handleEliminar = async (entrenamiento) => {
    const confirmar = window.confirm(
      `⚠️ ELIMINAR PERMANENTEMENTE\n\n` +
      `¿Está COMPLETAMENTE SEGURO de eliminar este entrenamiento?\n\n` +
      `Fecha: ${entrenamiento.FechaDeEventos}\n` +
      `Ubicación: ${entrenamiento.Ubicacion}\n\n` +
      `⚠️ ESTA ACCIÓN NO SE PUEDE DESHACER.`
    );

    if (!confirmar) return;

    const result = await deletePermanently(entrenamiento.idCronogramas);
    if (result.success) {
      alert('✅ Entrenamiento eliminado permanentemente');
    } else {
      alert(`❌ Error: ${result.error}`);
    }
  };

  if (loading) {
    return (
      <div className="text-center py-5">
        <output className="spinner-border text-danger">
          <span className="visually-hidden">Cargando...</span>
        </output>
      </div>
    );
  }

  return (
    <div>
      <SearchBar 
        value=""
        onChange={searchItems}
        placeholder="Buscar por fecha, ubicación o sede..."
      />
      <ContadorResultados cantidad={filteredItems.length} texto="entrenamiento(s) eliminado(s)" />
      
      {filteredItems.length === 0 ? (
        <EmptyState mensaje="No hay entrenamientos eliminados" icono="calendar-event" />
      ) : (
        <div className="row">
          {filteredItems.map((entrenamiento) => (
            <div key={entrenamiento.idCronogramas} className="col-md-6 col-lg-4">
              <ItemEliminadoCard
                titulo={`Entrenamiento - ${entrenamiento.FechaDeEventos}`}
                subtitulo1={`Ubicación: ${entrenamiento.Ubicacion}`}
                subtitulo2={entrenamiento.SedeEntrenamiento ? `Sede: ${entrenamiento.SedeEntrenamiento}` : null}
                subtitulo3={entrenamiento.Descripcion ? `Desc: ${entrenamiento.Descripcion}` : null}
                inicial="E"
                onRestaurar={() => handleRestaurar(entrenamiento)}
                onEliminarPermanente={() => handleEliminar(entrenamiento)}
              />
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

// ========================================
// COMPONENTE TAB: PARTIDOS
// ========================================
function TabPartidos() {
  const { filteredItems, loading, searchItems, restore, deletePermanently } = useHistorial('partidos');

  const handleRestaurar = async (partido) => {
    const confirmar = window.confirm(
      `¿Desea restaurar este partido?\n\n` +
      `Formación: ${partido.Formacion}\n` +
      `Equipo Rival: ${partido.EquipoRival}\n\n` +
      `Este partido volverá a estar activo en el sistema.`
    );

    if (!confirmar) return;

    const result = await restore(partido.idPartidos);
    if (result.success) {
      alert('✅ Partido restaurado correctamente');
    } else {
      alert(`❌ Error: ${result.error}`);
    }
  };

  const handleEliminar = async (partido) => {
    const confirmar = window.confirm(
      `⚠️ ELIMINAR PERMANENTEMENTE\n\n` +
      `¿Está COMPLETAMENTE SEGURO de eliminar este partido?\n\n` +
      `Formación: ${partido.Formacion}\n` +
      `Equipo Rival: ${partido.EquipoRival}\n\n` +
      `⚠️ ESTA ACCIÓN NO SE PUEDE DESHACER.`
    );

    if (!confirmar) return;

    const result = await deletePermanently(partido.idPartidos);
    if (result.success) {
      alert('✅ Partido eliminado permanentemente');
    } else {
      alert(`❌ Error: ${result.error}`);
    }
  };

  if (loading) {
    return (
      <div className="text-center py-5">
        <output className="spinner-border text-danger" >
          <span className="visually-hidden">Cargando...</span>
        </output>
      </div>
    );
  }

  return (
    <div>
      <SearchBar 
        value=""
        onChange={searchItems}
        placeholder="Buscar por formación o equipo rival..."
      />
      <ContadorResultados cantidad={filteredItems.length} texto="partido(s) eliminado(s)" />
      
      {filteredItems.length === 0 ? (
        <EmptyState mensaje="No hay partidos eliminados" icono="trophy" />
      ) : (
        <div className="row">
          {filteredItems.map((partido) => {
            const fechaTexto = partido.cronograma?.FechaDeEventos || partido.FechaDeEventos || 'Fecha no disponible';
            
            return (
              <div key={partido.idPartidos} className="col-md-6 col-lg-4">
                <ItemEliminadoCard
                  titulo={`vs ${partido.EquipoRival}`}
                  subtitulo1={`Formación: ${partido.Formacion}`}
                  subtitulo2={`Fecha: ${fechaTexto}`}
                  subtitulo3={partido.cronograma?.Ubicacion ? `Ubicación: ${partido.cronograma.Ubicacion}` : null}
                  inicial="P"
                  onRestaurar={() => handleRestaurar(partido)}
                  onEliminarPermanente={() => handleEliminar(partido)}
                />
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

// ========================================
// COMPONENTE TAB: RENDIMIENTOS
// ========================================
function TabRendimientos() {
  const { filteredItems, loading, searchItems, restore, deletePermanently } = useHistorial('rendimientos');

  const handleRestaurar = async (rendimiento) => {
    const confirmar = window.confirm(
      `¿Desea restaurar este rendimiento?\n\n` +
      `Jugador ID: ${rendimiento.idJugadores}\n` +
      `Partido ID: ${rendimiento.idPartidos}\n\n` +
      `Este rendimiento volverá a estar activo en el sistema.`
    );

    if (!confirmar) return;

    const result = await restore(rendimiento.idRendimientosPartidos);
    if (result.success) {
      alert('✅ Rendimiento restaurado correctamente');
    } else {
      alert(`❌ Error: ${result.error}`);
    }
  };

  const handleEliminar = async (rendimiento) => {
    const confirmar = window.confirm(
      `⚠️ ELIMINAR PERMANENTEMENTE\n\n` +
      `¿Está COMPLETAMENTE SEGURO de eliminar este rendimiento?\n\n` +
      `Jugador ID: ${rendimiento.idJugadores}\n` +
      `Partido ID: ${rendimiento.idPartidos}\n\n` +
      `⚠️ ESTA ACCIÓN NO SE PUEDE DESHACER.`
    );

    if (!confirmar) return;

    const result = await deletePermanently(rendimiento.idRendimientosPartidos);
    if (result.success) {
      alert('✅ Rendimiento eliminado permanentemente');
    } else {
      alert(`❌ Error: ${result.error}`);
    }
  };

  if (loading) {
    return (
      <div className="text-center py-5">
        <output className="spinner-border text-danger" >
          <span className="visually-hidden">Cargando...</span>
        </output>
      </div>
    );
  }

  return (
    <div>
      <SearchBar 
        value=""
        onChange={searchItems}
        placeholder="Buscar rendimientos..."
      />
      <ContadorResultados cantidad={filteredItems.length} texto="rendimiento(s) eliminado(s)" />
      
      {filteredItems.length === 0 ? (
        <EmptyState mensaje="No hay rendimientos eliminados" icono="graph-up" />
      ) : (
        <div className="row">
          {filteredItems.map((rendimiento) => {
            const stats = [];
            if (rendimiento.Goles) stats.push(`${rendimiento.Goles} goles`);
            if (rendimiento.Asistencias) stats.push(`${rendimiento.Asistencias} asist.`);
            if (rendimiento.TarjetasAmarillas) stats.push(`${rendimiento.TarjetasAmarillas} TA`);
            if (rendimiento.TarjetasRojas) stats.push(`${rendimiento.TarjetasRojas} TR`);
            
            const statsTexto = stats.length > 0 ? stats.join(', ') : 'Sin estadísticas';
            
            return (
              <div key={rendimiento.idRendimientosPartidos} className="col-md-6 col-lg-4">
                <ItemEliminadoCard
                  titulo={`Rendimiento - Partido #${rendimiento.idPartidos}`}
                  subtitulo1={`Jugador ID: ${rendimiento.idJugadores}`}
                  subtitulo2={statsTexto}
                  subtitulo3={rendimiento.MinutosJugados ? `${rendimiento.MinutosJugados} minutos` : null}
                  inicial="R"
                  onRestaurar={() => handleRestaurar(rendimiento)}
                  onEliminarPermanente={() => handleEliminar(rendimiento)}
                />
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}