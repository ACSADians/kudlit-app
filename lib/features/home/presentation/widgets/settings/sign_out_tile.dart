import 'package:flutter/material.dart';

class SignOutTile extends StatefulWidget {
  const SignOutTile({super.key, required this.onTap, this.isLoading = false});

  final VoidCallback onTap;
  final bool isLoading;

  @override
  State<SignOutTile> createState() => _SignOutTileState();
}

class _SignOutTileState extends State<SignOutTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    if (widget.isLoading) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(SignOutTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _animationController.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final BorderRadius radius = BorderRadius.circular(14);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Semantics(
        button: true,
        enabled: !widget.isLoading,
        label: widget.isLoading ? 'Sign out, loading' : 'Sign out',
        child: ExcludeSemantics(
          child: Opacity(
            opacity: widget.isLoading ? 0.6 : 1.0,
            child: Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  color: cs.errorContainer,
                  borderRadius: radius,
                  border: Border.all(
                    color: cs.error.withAlpha(widget.isLoading ? 30 : 68),
                  ),
                ),
                child: InkWell(
                  onTap: widget.isLoading ? null : widget.onTap,
                  borderRadius: radius,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 52),
                    child: Center(
                      child: widget.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: cs.error,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  cs.error,
                                ),
                              ),
                            )
                          : Text(
                              'Sign out',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: cs.error,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
