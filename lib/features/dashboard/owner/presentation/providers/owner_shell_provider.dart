import 'package:flutter_riverpod/flutter_riverpod.dart';

class OwnerNavNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final ownerNavIndexProvider =
    NotifierProvider<OwnerNavNotifier, int>(OwnerNavNotifier.new);
