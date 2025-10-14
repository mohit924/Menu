import 'package:flutter/material.dart';
import 'package:menu_scan_web/Custom/App_colors.dart';

class ToggleAddButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final double? width; // optional width

  const ToggleAddButton({Key? key, this.onPressed, this.width})
    : super(key: key);

  @override
  State<ToggleAddButton> createState() => _ToggleAddButtonState();
}

class _ToggleAddButtonState extends State<ToggleAddButton>
    with SingleTickerProviderStateMixin {
  bool _isCompleted = false;
  int _count = 0; // quantity
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
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            _isCompleted = true;
            _count = 1; // initial count after adding
          });
        });
      }
    });
  }

  void _startAnimation() {
    if (!_isCompleted) {
      _controller.forward();
      widget.onPressed?.call();
    }
  }

  void _increment() {
    setState(() {
      _count++;
    });
  }

  void _decrement() {
    setState(() {
      _count--;
      if (_count <= 0) {
        _count = 0;
        _isCompleted = false;
        _controller.reset();
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
    double buttonWidth = widget.width ?? 60; // default width
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
            // Orange background animation
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

            // Center content
            Center(
              child: _isCompleted
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _decrement,
                          child: Text(
                            "-",
                            style: TextStyle(
                              color: AppColors.whiteColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "$_count",
                          style: TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _increment,
                          child: Text(
                            "+",
                            style: TextStyle(
                              color: AppColors.whiteColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  : AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Text(
                          (_animation.value > 0) ? "" : "Add",
                          style: TextStyle(
                            color: (_animation.value > 0)
                                ? AppColors.whiteColor
                                : AppColors.LightGreyColor,
                            fontWeight: FontWeight.w500,
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
