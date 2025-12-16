// src/api/axiosConfig.js
import axios from 'axios';

// Configuración base de Axios
const api = axios.create({
  baseURL: 'http://127.0.0.1:8000/api',
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

// Interceptor para agregar el token automáticamente
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`; // 👈 CON BACKTICKS
    }
    return config;
  },
  (error) => {
    console.error('Error en la petición:', error.message);
    return Promise.reject(error);
  }
);

// Interceptor para manejar errores globalmente
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response) {
      // Errores de la API (4xx, 5xx)
      console.error('Error de respuesta:', error.response.data);
      
      // Si el token expiró (401), redirigir al login
      if (error.response.status === 401) {
        localStorage.removeItem('token');
        window.location.href = '/login';
      }
    } else if (error.request) {
      // No hubo respuesta del servidor
      console.error('No hay respuesta del servidor:', error.request);
    } else {
      // Error en la configuración de la petición
      console.error('Error en la petición:', error.message);
    }
    return Promise.reject(error);
  }
);

export default api;