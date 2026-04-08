import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(color: F1Theme.red),
      );
}

class ErrorWidget2 extends StatelessWidget {
  final String message;
  const ErrorWidget2({super.key, required this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: F1Theme.red, size: 40),
            const SizedBox(height: 12),
            Text(message,
                style: const TextStyle(color: F1Theme.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      );
}

class F1Card extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool highlight;
  final EdgeInsets? padding;

  const F1Card({
    super.key,
    required this.child,
    this.onTap,
    this.highlight = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: F1Theme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: highlight
                  ? const BorderSide(color: F1Theme.red, width: 3)
                  : const BorderSide(color: F1Theme.border),
              top: const BorderSide(color: F1Theme.border),
              right: const BorderSide(color: F1Theme.border),
              bottom: const BorderSide(color: F1Theme.border),
            ),
          ),
          child: child,
        ),
      );
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          text,
          style: const TextStyle(
            color: F1Theme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class MedalBadge extends StatelessWidget {
  final int position;
  const MedalBadge({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    final medals = {1: '🥇', 2: '🥈', 3: '🥉'};
    if (medals.containsKey(position)) {
      return Text(medals[position]!, style: const TextStyle(fontSize: 22));
    }
    return SizedBox(
      width: 32,
      child: Text(
        '$position',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: F1Theme.textMuted,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class PointsBar extends StatelessWidget {
  final double fraction;
  const PointsBar({super.key, required this.fraction});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: fraction.clamp(0.04, 1.0),
          backgroundColor: F1Theme.border,
          valueColor: const AlwaysStoppedAnimation(F1Theme.red),
          minHeight: 3,
        ),
      );
}

class WinsBadge extends StatelessWidget {
  final int wins;
  const WinsBadge({super.key, required this.wins});

  @override
  Widget build(BuildContext context) {
    if (wins == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: F1Theme.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '${wins}V',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class RedBadge extends StatelessWidget {
  final String text;
  const RedBadge({super.key, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: F1Theme.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      );
}

class InfoTag extends StatelessWidget {
  final String text;
  const InfoTag({super.key, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: F1Theme.border,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(color: F1Theme.textSecondary, fontSize: 12),
        ),
      );
}
