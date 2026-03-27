import React from 'react';
import PropTypes from 'prop-types';

export default function ContadorResultados({ cantidad, texto = 'resultado(s)' }) {
  return (
    <div className="contador-resultados mb-3">
      <div className="d-flex align-items-center">
        <i className="bi bi-info-circle text-danger me-2"></i>
        <small className="text-dark fw-medium">
          {cantidad} {texto}
        </small>
      </div>
    </div>
  );
}

ContadorResultados.propTypes = {
  cantidad: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  texto: PropTypes.string
};