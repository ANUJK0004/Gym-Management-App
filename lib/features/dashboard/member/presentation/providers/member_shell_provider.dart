import 'package:flutter_riverpod/flutter_riverpod.dart';

class MemberNavNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final memberNavIndexProvider =
    NotifierProvider<MemberNavNotifier, int>(MemberNavNotifier.new);
