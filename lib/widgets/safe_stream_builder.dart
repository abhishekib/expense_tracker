import 'package:flutter/material.dart';

class SafeStreamBuilder<T> extends StatelessWidget {
  final Stream<T> stream;
  final T? initialData;
  final AsyncWidgetBuilder<T> builder;

  const SafeStreamBuilder({
    required this.stream,
    required this.builder,
    this.initialData,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream.cast<T>().handleError((error, stackTrace) {
        debugPrint('Stream error: $error\n$stackTrace');
        // Return empty data or initialData on error
        return initialData as T;
      }),
      initialData: initialData,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorWidget(snapshot.error!);
        }
        return builder(context, snapshot);
      },
    );
  }
}
