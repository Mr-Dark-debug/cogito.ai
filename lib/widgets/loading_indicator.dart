import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;

  const LoadingIndicator({
    super.key,
    this.message = 'Loading...',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          )
          .animate(
            onPlay: (controller) => controller.repeat(),
          )
          .rotate(
            duration: const Duration(seconds: 1),
            curve: Curves.linear,
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          )
          .animate()
          .fadeIn(duration: 300.ms),
        ],
      ),
    );
  }
}
