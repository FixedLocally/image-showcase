import 'package:flutter/material.dart';

class ExpandableFloatingActionButton<T> extends StatefulWidget {
  final List<ExpandableFloatingActionButtonItem<T>> items;
  final Widget? icon;
  final Widget? openIcon;
  final ValueChanged<T>? onPressed;

  const ExpandableFloatingActionButton({
    super.key,
    required this.items,
    this.icon,
    this.openIcon,
    this.onPressed,
  });

  @override
  State<ExpandableFloatingActionButton<T>> createState() => _ExpandableFloatingActionButtonState();
}

class _ExpandableFloatingActionButtonState<T> extends State<ExpandableFloatingActionButton<T>> {
  bool _open = false;
  bool _showOthers = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          ...widget.items.asMap().map((i, item) {
            return MapEntry(i, AnimatedPositioned(
              bottom: (i + 1) * 64 * (_open ? 1 : 0),
              duration: const Duration(milliseconds: 150),
              child: Offstage(
                offstage: !_showOthers,
                child: FloatingActionButton(
                  onPressed: () {
                    widget.onPressed?.call(item.value);
                    setState(() {
                      _open = false;
                    });
                  },
                  tooltip: item.tooltip,
                  child: item.icon,
                ),
              ),
            ));
          }).values,
          FloatingActionButton(
            onPressed: _onTap,
            child: _open ? widget.openIcon ?? widget.icon : widget.icon,
          ),
        ],
      ),
    );
  }

  void _onTap() {
    setState(() {
      _open = !_open;
      if (!_open) {
        Future.delayed(const Duration(milliseconds: 150), () {
          setState(() {
            _showOthers = false;
          });
        });
      } else {
        _showOthers = true;
      }
    });
  }
}

class ExpandableFloatingActionButtonItem<T> {
  final Widget icon;
  final Widget? label;
  final String? tooltip;
  final T value;

  const ExpandableFloatingActionButtonItem({
    required this.icon,
    this.label,
    this.tooltip,
    required this.value,
  });
}
