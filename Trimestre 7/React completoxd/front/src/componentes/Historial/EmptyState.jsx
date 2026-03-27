import React from 'react';
import PropTypes from 'prop-types';

export default function EmptyState({ mensaje = 'No hay elementos', icono = 'inbox' }) {
  return (
    <div className="text-center py-5">
      <i 
        className={`bi bi-${icono} text-muted`} 
        style={{ fontSize: '80px' }}
      ></i>
      <p className="text-muted mt-3 fw-medium">{mensaje}</p>
    </div>
  );
}

EmptyState.propTypes = {
  mensaje: PropTypes.string,
  icono: PropTypes.string
};