import React from 'react';

export default function ItemEliminadoCard({ 
  titulo, 
  subtitulo1, 
  subtitulo2, 
  subtitulo3, 
  inicial, 
  onRestaurar, 
  onEliminarPermanente 
}) {
  return (
    <div className="card card-eliminado mb-3">
      <div className="card-body">
        {/* Header con avatar y título */}
        <div className="d-flex align-items-center mb-3">
          <div className="avatar-eliminado">
            {inicial.toUpperCase()}
          </div>
          <div className="ms-3 flex-grow-1">
            <h6 className="mb-0 fw-bold">{titulo}</h6>
          </div>
        </div>

        <hr className="my-3" />

        {/* Información detallada */}
        <div className="mb-3">
          <div className="d-flex align-items-start mb-2">
            <i className="bi bi-info-circle text-muted me-2" style={{ fontSize: '14px', marginTop: '2px' }}></i>
            <small className="text-muted">{subtitulo1}</small>
          </div>

          {subtitulo2 && (
            <div className="d-flex align-items-start mb-2">
              <i className="bi bi-telephone text-muted me-2" style={{ fontSize: '14px', marginTop: '2px' }}></i>
              <small className="text-muted">{subtitulo2}</small>
            </div>
          )}

          {subtitulo3 && (
            <div className="d-flex align-items-start mb-2">
              <i className="bi bi-tag text-muted me-2" style={{ fontSize: '14px', marginTop: '2px' }}></i>
              <small className="text-muted">{subtitulo3}</small>
            </div>
          )}
        </div>

        <hr className="my-3" />

        {/* Botones de acción */}
        <div className="d-flex gap-2">
          <button 
            className="btn btn-restaurar flex-fill"
            onClick={onRestaurar}
          >
            <i className="bi bi-arrow-counterclockwise me-1"></i> Restaurar
          </button>
          <button 
            className="btn btn-eliminar flex-fill"
            onClick={onEliminarPermanente}
          >
            <i className="bi bi-trash3 me-1"></i> Eliminar
          </button>
        </div>
      </div>
    </div>
  );
}