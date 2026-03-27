// src/services/historialService.js
import api from '../config/axiosConfig';

// Mapeo de tipos de entidad a endpoints y rutas de API
const ENTITY_CONFIG = {
  jugadores: {
    endpoint: 'jugadores',
    trashedRoute: 'trashed',
    restoreRoute: 'restore',
    deleteRoute: 'force'
  },
  entrenadores: {
    endpoint: 'entrenadores',
    trashedRoute: 'trashed',
    restoreRoute: 'restore',
    deleteRoute: 'force'
  },
  categorias: {
    endpoint: 'categorias',
    trashedRoute: 'papelera/listar',
    restoreRoute: 'restaurar',
    deleteRoute: 'forzar'
  },
  entrenamientos: {
    endpoint: 'cronogramas',
    trashedRoute: 'papelera/listar',
    restoreRoute: 'restaurar',
    deleteRoute: 'forzar'
  },
  partidos: {
    endpoint: 'partidos',
    trashedRoute: 'papelera/listar',
    restoreRoute: 'restaurar',
    deleteRoute: 'forzar'
  },
  rendimientos: {
    endpoint: 'rendimientospartidos',
    trashedRoute: 'papelera/listar',
    restoreRoute: 'restaurar',
    deleteRoute: 'forzar'
  }
};

/**
 * Obtiene la lista de items eliminados (soft delete)
 */
export const getDeletedItems = async (entityType) => {
  try {
    const config = ENTITY_CONFIG[entityType];
    
    if (!config) {
      throw new Error(`Tipo de entidad no válido: ${entityType}`);
    }

    const url = `/${config.endpoint}/${config.trashedRoute}`;
    const response = await api.get(url);
    
    console.log(`✅ Items eliminados de ${entityType}:`, response.data);
    console.log(`📊 Tipo de dato recibido:`, typeof response.data, Array.isArray(response.data));
    
    // Manejar diferentes estructuras de respuesta
    let items = response.data;

    // Si viene dentro de un objeto "data"
    if (items && items.data && Array.isArray(items.data)) {
      items = items.data;
    }

    // Si viene dentro de un objeto con el nombre de la entidad
    if (items && items[config.endpoint] && Array.isArray(items[config.endpoint])) {
      items = items[config.endpoint];
    }

    // Asegurarse de que sea un array
    if (!Array.isArray(items)) {
      console.warn('⚠️ La respuesta no es un array, convirtiendo:', items);
      items = [];
    }

    return items;
    
  } catch (error) {
    console.error(`❌ Error obteniendo ${entityType} eliminados:`, error);
    
    if (error.response) {
      throw new Error(
        error.response.data?.message || 
        `Error al cargar ${entityType} eliminados`
      );
    } else if (error.request) {
      throw new Error('No se pudo conectar con el servidor');
    } else {
      throw new Error(error.message);
    }
  }
};

/**
 * Restaura un item eliminado
 */
export const restoreItem = async (entityType, id) => {
  try {
    const config = ENTITY_CONFIG[entityType];
    
    if (!config) {
      throw new Error(`Tipo de entidad no válido: ${entityType}`);
    }

    const url = `/${config.endpoint}/${id}/${config.restoreRoute}`;
    const response = await api.post(url);
    
    console.log(`✅ Item restaurado (${entityType} #${id}):`, response.data);
    
    return true;
    
  } catch (error) {
    console.error(`❌ Error restaurando ${entityType} #${id}:`, error);
    
    if (error.response) {
      throw new Error(
        error.response.data?.message || 
        `Error al restaurar el elemento`
      );
    } else if (error.request) {
      throw new Error('No se pudo conectar con el servidor');
    } else {
      throw new Error(error.message);
    }
  }
};

/**
 * Elimina permanentemente un item (hard delete)
 */
export const deleteItemPermanently = async (entityType, id) => {
  try {
    const config = ENTITY_CONFIG[entityType];
    
    if (!config) {
      throw new Error(`Tipo de entidad no válido: ${entityType}`);
    }

    const url = `/${config.endpoint}/${id}/${config.deleteRoute}`;
    const response = await api.delete(url);
    
    console.log(`✅ Item eliminado permanentemente (${entityType} #${id}):`, response.data);
    
    return true;
    
  } catch (error) {
    console.error(`❌ Error eliminando permanentemente ${entityType} #${id}:`, error);
    
    if (error.response) {
      throw new Error(
        error.response.data?.message || 
        `Error al eliminar el elemento permanentemente`
      );
    } else if (error.request) {
      throw new Error('No se pudo conectar con el servidor');
    } else {
      throw new Error(error.message);
    }
  }
};

// eslint-disable-next-line import/no-anonymous-default-export
export default {
  getDeletedItems,
  restoreItem,
  deleteItemPermanently
};