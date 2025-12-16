import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/api_config.dart';
import '../models/pdf_report_config.dart';
import 'auth_service.dart';

class ReporteService {
  final AuthService _authService = AuthService();

  /// Genera el reporte PDF según la configuración
  Future<String?> generarReportePDF(int idJugador, PdfReportConfig config) async {
    try {
      print('📄 Generando reporte PDF para jugador: $idJugador');
      print('📋 Config: ${config.toString()}');
      
      // Obtener headers con autenticación
      final headers = await _authService.obtenerHeaders();
      
      // Construir la URL según el tipo de reporte
      Uri url;
      if (config.tipo == TipoReportePdf.general) {
        // REPORTE GENERAL (todas las competencias)
        url = Uri.parse('$baseUrl/reportes/jugador/$idJugador/pdf');
        print('🌐 Reporte GENERAL: $url');
      } else {
        // REPORTE POR COMPETENCIA ESPECÍFICA (PLURAL)
        if (config.idCompetencia == null) {
          throw Exception('Se requiere un ID de competencia para generar el reporte');
        }
        url = Uri.parse('$baseUrl/reportes/jugador/$idJugador/competencias/${config.idCompetencia}/pdf');
        print('🌐 Reporte POR COMPETENCIA (${config.idCompetencia}): $url');
      }
      
      // Hacer la petición al backend
      final response = await http.get(url, headers: headers);
      
      print('✅ Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        // Verificar que la respuesta contenga datos
        if (response.bodyBytes.isEmpty) {
          throw Exception('El PDF generado está vacío');
        }
        
        // Verificar y solicitar permisos de almacenamiento
        final permiso = await _verificarPermisos();
        if (!permiso) {
          print('❌ Permisos de almacenamiento denegados');
          throw Exception('Se requieren permisos de almacenamiento para guardar el PDF');
        }
        
        // Obtener el directorio de descargas
        final directorio = await _obtenerDirectorioDescargas();
        
        // Crear nombre único para el archivo
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final tipoReporte = config.tipo == TipoReportePdf.general 
            ? 'general' 
            : 'competencia_${config.idCompetencia}';
        final nombreArchivo = 'reporte_${tipoReporte}_jugador_${idJugador}_$timestamp.pdf';
        final rutaArchivo = '${directorio.path}/$nombreArchivo';
        
        // Guardar el archivo
        final file = File(rutaArchivo);
        await file.writeAsBytes(response.bodyBytes);
        
        print('✅ PDF guardado en: $rutaArchivo');
        return rutaArchivo;
      } else {
        print('❌ Error en respuesta: ${response.statusCode}');
        print('❌ Body: ${response.body}');
        
        if (response.statusCode == 404) {
          throw Exception('No se encontraron registros para este jugador');
        } else if (response.statusCode == 500) {
          throw Exception('Error en el servidor. Revisa los logs del backend.');
        } else {
          throw Exception('Error al generar el reporte: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('❌ Error generando reporte: $e');
      rethrow;
    }
  }

  /// Obtiene los bytes del PDF (para Web)
  Future<List<int>?> getReportePDFBytes(int idJugador, PdfReportConfig config) async {
    try {
      print('📄 Obteniendo bytes del PDF para jugador: $idJugador');
      print('📋 Config: ${config.toString()}');
      
      // Obtener headers con autenticación
      final headers = await _authService.obtenerHeaders();
      
      // Construir la URL según el tipo de reporte
      Uri url;
      if (config.tipo == TipoReportePdf.general) {
        url = Uri.parse('$baseUrl/reportes/jugador/$idJugador/pdf');
        print('🌐 Reporte GENERAL: $url');
      } else {
        if (config.idCompetencia == null) {
          throw Exception('Se requiere un ID de competencia para generar el reporte');
        }
        url = Uri.parse('$baseUrl/reportes/jugador/$idJugador/competencias/${config.idCompetencia}/pdf');
        print('🌐 Reporte POR COMPETENCIA (${config.idCompetencia}): $url');
      }
      
      // Hacer la petición al backend
      final response = await http.get(url, headers: headers);
      
      print('✅ Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        if (response.bodyBytes.isEmpty) {
          throw Exception('El PDF generado está vacío');
        }
        return response.bodyBytes;
      } else {
        print('❌ Error en respuesta: ${response.statusCode}');
        print('❌ Body: ${response.body}');
        
        if (response.statusCode == 404) {
          throw Exception('No se encontraron registros para este jugador');
        } else if (response.statusCode == 500) {
          throw Exception('Error en el servidor. Revisa los logs del backend.');
        } else {
          throw Exception('Error al generar el reporte: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('❌ Error obteniendo bytes del PDF: $e');
      rethrow;
    }
  }

  /// Verifica y solicita permisos de almacenamiento
  Future<bool> _verificarPermisos() async {
    if (Platform.isAndroid) {
      // Para Android 13+ (API 33+)
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }
      
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        return true;
      }
      
      // Intentar con el permiso legacy
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    } else if (Platform.isIOS) {
      // En iOS, path_provider maneja los permisos automáticamente
      return true;
    }
    
    return false;
  }

  /// Obtiene el directorio de descargas según la plataforma
  Future<Directory> _obtenerDirectorioDescargas() async {
    if (Platform.isAndroid) {
      // En Android, usar el directorio de Descargas público
      Directory? directory = Directory('/storage/emulated/0/Download');
      
      // Verificar si existe
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
      
      return directory!;
    } else if (Platform.isIOS) {
      // En iOS, usar el directorio de documentos de la app
      return await getApplicationDocumentsDirectory();
    } else {
      // Fallback para otras plataformas
      return await getApplicationDocumentsDirectory();
    }
  }
}