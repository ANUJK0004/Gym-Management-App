import 'package:flutter/material.dart';

import '../../domain/entities/activity_log.dart';

class ActivityTile extends StatelessWidget {
  const ActivityTile({
    super.key,
    required this.activity,
  });

  final ActivityLog activity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.history),
      title: Text(activity.title),
      subtitle: Text(activity.description),
      trailing: Text(activity.actorName),
    );
  }
}