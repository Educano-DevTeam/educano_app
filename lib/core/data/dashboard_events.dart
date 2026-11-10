import 'package:flutter/foundation.dart';

/// Avisa as listagens do dashboard que algo foi cadastrado fora delas
/// (por exemplo, pelo botão flutuante), para que recarreguem os dados.
class DashboardEvents {
  DashboardEvents._();

  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static void notifyChanged() => changes.value++;
}
