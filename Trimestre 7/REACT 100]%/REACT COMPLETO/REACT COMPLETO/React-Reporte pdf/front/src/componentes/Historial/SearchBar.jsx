// src/componentes/Historial/SearchBar.jsx
import React from 'react';

export default function SearchBar({ value, onChange, placeholder = 'Buscar...' }) {
  return (
    <div className="mb-3">
      <div className="input-group">
        <span className="input-group-text bg-white border-end-0">
          <i className="bi bi-search text-danger"></i>
        </span>
        <input
          type="text"
          className="form-control historial-search border-start-0"
          placeholder={placeholder}
          value={value}
          onChange={(e) => onChange(e.target.value)}
        />
        {value && (
          <button 
            className="btn btn-link text-muted" 
            type="button"
            onClick={() => onChange('')}
          >
            <i className="bi bi-x-lg"></i>
          </button>
        )}
      </div>
    </div>
  );
}