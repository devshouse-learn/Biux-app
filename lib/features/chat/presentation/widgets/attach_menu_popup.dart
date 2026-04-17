import 'package:flutter/material.dart';

/// Ítem del menú de adjuntos
class AttachMenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const AttachMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

/// Menú flotante tipo WhatsApp que aparece arriba del input.
class AttachMenuPopup {
  static void show(
    BuildContext context, {
    required List<AttachMenuItem> items,
    required bool isDark,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => _AttachMenuOverlay(
        items: items,
        isDark: isDark,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _AttachMenuOverlay extends StatefulWidget {
  final List<AttachMenuItem> items;
  final bool isDark;
  final VoidCallback onDismiss;

  const _AttachMenuOverlay({
    required this.items,
    required this.isDark,
    required this.onDismiss,
  });

  @override
  State<_AttachMenuOverlay> createState() => _AttachMenuOverlayState();
}

class _AttachMenuOverlayState extends State<_AttachMenuOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _animController.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? const Color(0xFF1A2B3C) : Colors.white;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    // Calcular filas de 3
    final rows = <List<AttachMenuItem>>[];
    for (var i = 0; i < widget.items.length; i += 3) {
      rows.add(
        widget.items.sublist(
          i,
          i + 3 > widget.items.length ? widget.items.length : i + 3,
        ),
      );
    }

    return GestureDetector(
      onTap: _dismiss,
      behavior: HitTestBehavior.opaque,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // Fondo semi-transparente
            Container(color: Colors.black26),
            // Menú flotante
            Positioned(
              left: 12,
              right: 12,
              bottom: bottomPadding + 70,
              child: ScaleTransition(
                scale: _scaleAnim,
                alignment: Alignment.bottomCenter,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: rows
                          .map(
                            (row) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: row
                                    .map(
                                      (item) => _AttachMenuButton(
                                        item: item,
                                        isDark: widget.isDark,
                                        onTap: () {
                                          _dismiss();
                                          item.onTap();
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachMenuButton extends StatelessWidget {
  final AttachMenuItem item;
  final bool isDark;
  final VoidCallback onTap;

  const _AttachMenuButton({
    required this.item,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: item.color,
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
