import { useState, useEffect, useCallback } from 'react';
import { getDeletedItems, restoreItem, deleteItemPermanently } from '../services/historialService';

/**
 * Hook personalizado para manejar la lógica de historiales (soft delete)
 */
const useHistorial = (entityType) => {
  const [items, setItems] = useState([]);
  const [filteredItems, setFilteredItems] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [searchQuery, setSearchQuery] = useState('');

  /**
   * Cargar items eliminados desde la API
   */
  const loadItems = useCallback(async () => {
    setLoading(true);
    setError(null);

    try {
      const data = await getDeletedItems(entityType);
      setItems(data);
      setFilteredItems(data);
    } catch (err) {
      setError(err.message);
      setItems([]);
      setFilteredItems([]);
    } finally {
      setLoading(false);
    }
  }, [entityType]);

  /**
   * Buscar/filtrar items localmente
   */
  const searchItems = useCallback((query) => {
    setSearchQuery(query);

    if (!query.trim()) {
      setFilteredItems(items);
      return;
    }

    const queryLower = query.toLowerCase().trim();

    const filtered = items.filter((item) => {
      // Convertir el objeto a string y buscar
      const itemString = JSON.stringify(item).toLowerCase();
      return itemString.includes(queryLower);
    });

    setFilteredItems(filtered);
  }, [items]);

  /**
   * Restaurar un item
   */
  const restore = useCallback(async (id) => {
    try {
      await restoreItem(entityType, id);
      
      // Remover el item de la lista local
      setItems((prev) => prev.filter((item) => {
        // Buscar el ID en diferentes posibles nombres de campo
        return item.idJugadores !== id && 
               item.idEntrenadores !== id && 
               item.idCategorias !== id &&
               item.idEntrenamientos !== id &&
               item.idPartidos !== id &&
               item.idRendimientos !== id;
      }));
      
      setFilteredItems((prev) => prev.filter((item) => {
        return item.idJugadores !== id && 
               item.idEntrenadores !== id && 
               item.idCategorias !== id &&
               item.idEntrenamientos !== id &&
               item.idPartidos !== id &&
               item.idRendimientos !== id;
      }));
      
      return { success: true };
    } catch (err) {
      return { success: false, error: err.message };
    }
  }, [entityType]);

  /**
   * Eliminar permanentemente un item
   */
  const deletePermanently = useCallback(async (id) => {
    try {
      await deleteItemPermanently(entityType, id);
      
      // Remover el item de la lista local
      setItems((prev) => prev.filter((item) => {
        return item.idJugadores !== id && 
               item.idEntrenadores !== id && 
               item.idCategorias !== id &&
               item.idEntrenamientos !== id &&
               item.idPartidos !== id &&
               item.idRendimientos !== id;
      }));
      
      setFilteredItems((prev) => prev.filter((item) => {
        return item.idJugadores !== id && 
               item.idEntrenadores !== id && 
               item.idCategorias !== id &&
               item.idEntrenamientos !== id &&
               item.idPartidos !== id &&
               item.idRendimientos !== id;
      }));
      
      return { success: true };
    } catch (err) {
      return { success: false, error: err.message };
    }
  }, [entityType]);

  /**
   * Recargar items
   */
  const refresh = useCallback(() => {
    loadItems();
  }, [loadItems]);

  // Cargar items al montar el componente
  useEffect(() => {
    loadItems();
  }, [loadItems]);

  return {
    items,
    filteredItems,
    loading,
    error,
    searchQuery,
    loadItems,
    searchItems,
    restore,
    deletePermanently,
    refresh
  };
};

export default useHistorial;