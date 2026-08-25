import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PremiumAnimatedAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;

  const PremiumAnimatedAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<PremiumAnimatedAppBar> createState() => _PremiumAnimatedAppBarState();
}

class _PremiumAnimatedAppBarState extends State<PremiumAnimatedAppBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _topAlignment;
  late Animation<Alignment> _bottomAlignment;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _topAlignment = TweenSequence<Alignment>([
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1),
    ]).animate(_controller);
    _bottomAlignment = TweenSequence<Alignment>([
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return AppBar(
          title: widget.title,
          leading: widget.leading,
          actions: widget.actions,
          centerTitle: widget.centerTitle,
          backgroundColor: Colors.transparent,
          elevation: 8,
          shadowColor: AppColors.primaryDark.withOpacity(0.5),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [
                  AppColors.primary,
                  AppColors.primaryLight,
                ],
                begin: _topAlignment.value,
                end: _bottomAlignment.value,
              ),
            ),
          ),
        );
      },
    );
  }
}
