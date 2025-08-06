import 'package:flutter/material.dart';

class DemoLoading extends StatefulWidget {
  final String message;
  final Duration duration;
  final VoidCallback? onComplete;
  
  const DemoLoading({
    super.key,
    required this.message,
    this.duration = const Duration(seconds: 2),
    this.onComplete,
  });

  @override
  State<DemoLoading> createState() => _DemoLoadingState();
}

class _DemoLoadingState extends State<DemoLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    
    _controller.repeat();
    
    // Auto complete after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.8 + (_animation.value * 0.4),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: Theme.of(context).primaryColor,
                    size: 30,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            widget.message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI が処理しています...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class DemoTransition extends StatelessWidget {
  final Widget child;
  final String? loadingMessage;
  final bool showLoading;
  
  const DemoTransition({
    super.key,
    required this.child,
    this.loadingMessage,
    this.showLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: showLoading
          ? Center(
              key: const ValueKey('loading'),
              child: DemoLoading(
                message: loadingMessage ?? 'Loading...',
              ),
            )
          : child,
    );
  }
}

class PageTransition extends PageRouteBuilder {
  final Widget child;
  final Duration duration;
  
  PageTransition({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.ease;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}