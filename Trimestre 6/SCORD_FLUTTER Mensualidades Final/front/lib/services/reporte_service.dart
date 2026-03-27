import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:typed_data'; // Añadido para el nuevo método
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class ReporteService {
  final AuthService _authService = AuthService();

  // ========================================
  // NUEVO MÉTODO: OBTENER BYTES DEL PDF (Lógica compatible con Web)
  // ========================================

  /// Obtiene el contenido binario (bytes) del reporte PDF desde la API.
  /// Esto es reutilizado tanto por la web (para descarga) como por las plataformas nativas (para guardado).
  Future<Uint8List?> getReportePDFBytes(int idJugador) async {
    try {     
      final headers = await _authService.obtenerHeaders();
      final url = Uri.parse('$baseUrl/reportes/jugador/$idJugador/pdf');
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {    
        if (response.statusCode == 404) {
          throw Exception('No se encontraron registros para este jugador');
        } else {
          throw Exception('Error al obtener el contenido del reporte: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // ========================================
  // MÉTODO ORIGINAL: GUARDADO NATIVO (Solo para Android/iOS/Desktop)
  // ========================================

  /// Genera y guarda el reporte PDF en el sistema de archivos local. 
  /// ESTE MÉTODO SÓLO DEBE SER LLAMADO POR PLATAFORMAS NATIVAS.
  Future<String?> generarReportePDF(int idJugador) async {
    // Si la plataforma no es nativa (ej: web), el controlador debería manejarlo
    // Esto es un fallback, pero el controlador debe hacer la verificación principal.
    if (Platform.environment.containsKey('FLUTTER_WEB')) {
        throw UnsupportedError('El guardado nativo no es compatible con la Web. Use getReportePDFBytes.');
    }
    
    try {
      // CAMBIO CLAVE: Obtener los bytes a través del nuevo método (compatible con Auth)
      final responseBodyBytes = await getReportePDFBytes(idJugador);
      
      if (responseBodyBytes == null) {
        throw Exception('No se pudo obtener el contenido binario del PDF.');
      }
      
      // Verificar y solicitar permisos de almacenamiento
      final permiso = await _verificarPermisos();
      if (!permiso) {
        throw Exception('Se requieren permisos de almacenamiento para guardar el PDF');
      }
      
      // Obtener el directorio de descargas
      final directorio = await _obtenerDirectorioDescargas();
      
      // Crear nombre único para el archivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final nombreArchivo = 'reporte_jugador_${idJugador}_$timestamp.pdf';
      final rutaArchivo = '${directorio.path}/$nombreArchivo';
      
      // Guardar el archivo
      final file = File(rutaArchivo);
      await file.writeAsBytes(responseBodyBytes); // Usar los bytes obtenidos
      return rutaArchivo;

    } catch (e) {
      rethrow;
    }
  }

  /// Verifica y solicita permisos de almacenamiento
  Future<bool> _verificarPermisos() async {
    // ... (Tu implementación original sin cambios)
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
    // ... (Tu implementación original sin cambios)
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