import 'package:material_ui/material_ui.dart';

import '../models/irrigation_state.dart';
import '../theme/app_palette.dart';

(Color bg, Color fg) connectionBadgeColors(ConnectionHealth health) {
  switch (health) {
    case ConnectionHealth.connected:
      return (AppPalette.mintSoft, AppPalette.mint);
    case ConnectionHealth.connecting:
    case ConnectionHealth.disconnected:
      return (AppPalette.amberSoft, AppPalette.amber);
    case ConnectionHealth.reconnecting:
      return (AppPalette.coralSoft, AppPalette.coral);
    case ConnectionHealth.simulation:
      return (AppPalette.primarySoft, AppPalette.primary);
  }
}

class CompactConnectionBar extends StatelessWidget {
  final String endpoint;
  final ConnectionMode mode;
  final ConnectionHealth health;
  final String statusLabel;
  final VoidCallback onEditTap;
  final VoidCallback onConnect;

  const CompactConnectionBar({
    super.key,
    required this.endpoint,
    required this.mode,
    required this.health,
    required this.statusLabel,
    required this.onEditTap,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    final (badgeBg, badgeFg) = connectionBadgeColors(health);
    final isFirebase = mode == ConnectionMode.firebase;
    final shortEndpoint = endpoint.replaceFirst(RegExp(r'^https?://'), '');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.border),
        boxShadow: [
          BoxShadow(
            color: AppPalette.primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onEditTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppPalette.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isFirebase ? Icons.cloud_outlined : Icons.lan_outlined,
                color: AppPalette.primary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: onEditTap,
              borderRadius: BorderRadius.circular(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: badgeFg,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              statusLabel,
                              style: TextStyle(
                                color: badgeFg,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '· Ubah',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppPalette.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    shortEndpoint.isEmpty ? 'Ketuk untuk atur alamat' : shortEndpoint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onConnect,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Connect',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class ConnectionCard extends StatelessWidget {
  final TextEditingController ipController;
  final ConnectionMode mode;
  final ConnectionHealth health;
  final String statusLabel;
  final ValueChanged<ConnectionMode> onModeChanged;
  final VoidCallback onConnect;

  const ConnectionCard({
    super.key,
    required this.ipController,
    required this.mode,
    required this.health,
    required this.statusLabel,
    required this.onModeChanged,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    final isFirebase = mode == ConnectionMode.firebase;
    final (badgeBg, badgeFg) = connectionBadgeColors(health);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppPalette.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.wifi_tethering_rounded,
                color: AppPalette.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Pengaturan Koneksi',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppPalette.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: badgeFg,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      color: badgeFg,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppPalette.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppPalette.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: _ModeTab(
                  label: 'Lokal (ESP32)',
                  icon: Icons.lan_outlined,
                  selected: !isFirebase,
                  onTap: () => onModeChanged(ConnectionMode.local),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _ModeTab(
                  label: 'Firebase RTDB',
                  icon: Icons.cloud_outlined,
                  selected: isFirebase,
                  onTap: () => onModeChanged(ConnectionMode.firebase),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: ipController,
          style: const TextStyle(
            fontSize: 13,
            color: AppPalette.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: isFirebase ? 'URL Firebase RTDB' : 'Alamat IP ESP32',
            labelStyle: const TextStyle(
              fontSize: 12,
              color: AppPalette.textSecondary,
            ),
            hintText: isFirebase
                ? 'https://xxx-default-rtdb.asia-southeast1.firebasedatabase.app'
                : 'http://192.168.137.10',
            isDense: true,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onConnect,
            icon: Icon(
              isFirebase ? Icons.cloud_done_outlined : Icons.wifi,
              size: 17,
            ),
            label: const Text('Hubungkan Sekarang'),
          ),
        ),
      ],
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? AppPalette.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected ? Colors.white : AppPalette.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppPalette.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
