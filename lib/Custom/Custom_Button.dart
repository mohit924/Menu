import 'package:flutter/material.dart';
import 'package:menu_scan_web/Custom/App_colors.dart';

class ToggleAddButton extends StatefulWidget {
  final bool isCompleted;
  final int count;
  final Function(bool, int) onChanged;

  const ToggleAddButton({
    Key? key,
    required this.isCompleted,
    required this.count,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<ToggleAddButton> createState() => _ToggleAddButtonState();
}

class _ToggleAddButtonState extends State<ToggleAddButton>
    with SingleTickerProviderStateMixin {
  late bool _isCompleted;
  late int _count;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.isCompleted;
    _count = widget.count;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (_isCompleted) {
      _controller.value = 1;
    }

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            _isCompleted = true;
            _count = 1;
          });
          widget.onChanged(_isCompleted, _count);
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant ToggleAddButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCompleted != _isCompleted || widget.count != _count) {
      setState(() {
        _isCompleted = widget.isCompleted;
        _count = widget.count;
      });
      if (_isCompleted) {
        _controller.value = 1;
      } else {
        _controller.reset();
      }
    }
  }

  void _startAnimation() {
    if (!_isCompleted) {
      _controller.forward();
      widget.onChanged(_isCompleted, _count);
    }
  }

  void _increment() {
    setState(() {
      _count++;
    });
    widget.onChanged(_isCompleted, _count);
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
    widget.onChanged(_isCompleted, _count);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _startAnimation,
      child: Container(
        width: 100,
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
