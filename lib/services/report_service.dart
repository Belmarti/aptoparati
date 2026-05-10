import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio sin estado para enviar reportes de errores a Firestore.
/// Colección: `reports/`
class ReportService {
  ReportService._();

  /// Guarda un reporte en la colección `reports` con los datos del usuario
  /// autenticado, el código de barras del producto y el motivo introducido.
  ///
  /// Lanza una excepción si el usuario no está autenticado o falla Firestore.
  static Future<void> sendReport({
    required String barcode,
    required String productName,
    required String reason,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    await FirebaseFirestore.instance.collection('reports').add({
      'user_id': user.uid,
      'email': user.email ?? '',
      'barcode': barcode,
      'product_name': productName,
      'reason': reason,
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}
