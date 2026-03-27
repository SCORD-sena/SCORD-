import { buildParams, validarCampos } from './CompetenciaJugador'; // Asegúrate de exportarlas en el original

describe('Pruebas unitarias - CompetenciaJugador Utils', () => {

  describe('buildParams', () => {
    test('debe construir parámetros básicos de paginación y orden', () => {
      const filtros = { sort_by: 'id', sort_order: 'asc' };
      const result = buildParams(1, filtros);
      
      expect(result.get('page')).toBe('1');
      expect(result.get('sort_by')).toBe('id');
      expect(result.get('sort_order')).toBe('asc');
    });

    test('debe agregar filtros opcionales si están presentes', () => {
      const filtros = {
        nombre: 'Torneo Local',
        tipo: 'Futbol',
        ano: '2024',
        id_equipo: '10',
        sort_by: 'id',
        sort_order: 'desc'
      };
      const result = buildParams(5, filtros);
      
      expect(result.get('nombre')).toBe('Torneo Local');
      expect(result.get('tipo')).toBe('Futbol');
      expect(result.get('ano')).toBe('2024');
      expect(result.get('id_equipo')).toBe('10');
    });
  });

  describe('validarCampos', () => {
    test('debe retornar errores si los campos están vacíos o son espacios', () => {
      const competenciaVacia = { Nombre: '  ', TipoCompetencia: '', Ano: '', idEquipos: '' };
      const errores = validarCampos(competenciaVacia);
      
      expect(errores.Nombre).toBe("El nombre es requerido");
      expect(errores.TipoCompetencia).toBe("El tipo de competencia es requerido");
      expect(errores.Ano).toBe("El año es requerido");
      expect(errores.idEquipos).toBe("Debe seleccionar un equipo");
    });

    test('debe validar límites de longitud de caracteres', () => {
      const competenciaLarga = { 
        Nombre: 'A'.repeat(51), 
        TipoCompetencia: 'B'.repeat(31), 
        Ano: 2024, 
        idEquipos: '1' 
      };
      const errores = validarCampos(competenciaLarga);
      
      expect(errores.Nombre).toBe("El nombre no puede exceder 50 caracteres");
      expect(errores.TipoCompetencia).toBe("El tipo no puede exceder 30 caracteres");
    });

    test('debe validar rangos de años (1900 - 2100)', () => {
      const añoInvalidoBajo = { Nombre: 'Copa', TipoCompetencia: 'X', Ano: 1899, idEquipos: '1' };
      const añoInvalidoAlto = { Nombre: 'Copa', TipoCompetencia: 'X', Ano: 2101, idEquipos: '1' };
      const añoNaN = { Nombre: 'Copa', TipoCompetencia: 'X', Ano: NaN, idEquipos: '1' };

      expect(validarCampos(añoInvalidoBajo).Ano).toBe("Ingrese un año válido");
      expect(validarCampos(añoInvalidoAlto).Ano).toBe("Ingrese un año válido");
      expect(validarCampos(añoNaN).Ano).toBe("Ingrese un año válido");
    });

    test('debe retornar objeto vacío si todo es correcto', () => {
      const competenciaOk = { 
        Nombre: 'Torneo SENA', 
        TipoCompetencia: 'Interno', 
        Ano: 2026, 
        idEquipos: '5' 
      };
      const errores = validarCampos(competenciaOk);
      expect(Object.keys(errores).length).toBe(0);
    });
  });
});