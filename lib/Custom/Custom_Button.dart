import 'package:flutter/material.dart';
import 'package:menu_scan_web/Custom/App_colors.dart';

class ToggleAddButton extends StatefulWidget {
  final VoidCallback? onPressed;
  const ToggleAddButton({Key? key, this.onPressed}) : super(key: key);

  @override
  State<ToggleAddButton> createState() => _ToggleAddButtonState();
}

class _ToggleAddButtonState extends State<ToggleAddButton>
    with SingleTickerProviderStateMixin {
  bool _isCompleted = false;
  bool _showIcon = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        setState(() {
          _showIcon = true;
        });
      }
      if (status == AnimationStatus.completed) {
        setState(() {
          _isCompleted = true;
        });
      }
    });
  }

  void _startAnimation() {
    if (!_isCompleted) {
      _controller.forward();
      if (widget.onPressed != null) widget.onPressed!();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double buttonWidth = 100;
    double circleSize = 20;
    double rightPadding = 8;
    double maxLeft = buttonWidth - circleSize - rightPadding - 8;

    return GestureDetector(
      onTap: _startAnimation,
      child: Container(
        width: buttonWidth,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isCompleted
                ? AppColors.OrangeColor
                : AppColors.LightGreyColor,
          ),
        ),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FractionallySizedBox(
                    widthFactor: _animation.value,
                    alignment: Alignment.centerLeft,
                    child: Container(color: AppColors.OrangeColor),
                  ),
                );
              },
            ),

            if (_showIcon)
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  double left = 8 + (_animation.value * maxLeft);
                  if (_isCompleted) left = 8 + maxLeft;
                  return Positioned(
                    left: left,
                    top: 10,
                    child: Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: const BoxDecoration(
                        color: AppColors.whiteColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColors.OrangeColor,

                        size: 16,
                      ),
                    ),
                  );
                },
              ),

            Center(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Text(
                    (_animation.value > 0 || _isCompleted) ? "Added" : "Add",
                    style: TextStyle(
                      color: (_animation.value > 0 || _isCompleted)
                          ? AppColors.whiteColor
                          : AppColors.LightGreyColor,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
