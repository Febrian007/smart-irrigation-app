import 'package:material_ui/material_ui.dart';

import '../models/irrigation_state.dart';
import '../theme/app_palette.dart';
import 'ui_kit.dart';

Color connectionColor(ConnectionHealth health) {
  switch (health) {
    case ConnectionHealth.connected:
      return AppPalette.mint;
    case ConnectionHealth.connecting:
    case ConnectionHealth.disconnected:
      return AppPalette.amber;
    case ConnectionHealth.reconnecting:
      return AppPalette.coral;
    case ConnectionHealth.simulation:
      return AppPalette.primary;
  }
}

bool _isBusy(ConnectionHealth h) =>
    h == ConnectionHealth.connecting || h == ConnectionHealth.reconnecting;

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
    final color = connectionColor(health);
    final isFirebase = mode == ConnectionMode.firebase;
    final shortEndpoint = endpoint.replaceFirst(RegExp(r'^https?://'), '');
    final busy = _isBusy(health);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      radius: 20,
      child: Row(
        children: [
          Expanded(
            child: Pressable(
              onTap: onEditTap,
              child: Row(
                children: [
                  IconBadge(
                    icon: isFirebase
                        ? Icons.cloud_outlined
                        : Icons.lan_outlined,
                    color: color,
                    size: 44,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatusPill(
                          label: statusLabel,
                          color: color,
                          pulse: health != ConnectionHealth.disconnected,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          shortEndpoint.isEmpty
                              ? 'Ketuk untuk atur alamat'
                              : '$shortEndpoint · Ubah',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppPalette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: busy ? null : onConnect,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              minimumSize: const Size(96, 44),
              disabledBackgroundColor: AppPalette.surfaceHigh,
            ),
            child: busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppPalette.textPrimary,
                    ),
                  )
                : const Text('Connect'),
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
    final color = connectionColor(health);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const IconBadge(
              icon: Icons.wifi_tethering_rounded,
              color: AppPalette.primary,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Koneksi Sistem',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: AppPalette.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Flexible(
              child: StatusPill(
                label: statusLabel,
                color: color,
                pulse: health != ConnectionHealth.disconnected,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppPalette.background,
            borderRadius: BorderRadius.circular(16),
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
                  label: 'Jarak Jauh (Firebase)',
                  icon: Icons.cloud_outlined,
                  selected: isFirebase,
                  onTap: () => onModeChanged(ConnectionMode.firebase),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: ipController,
          keyboardType: TextInputType.url,
          autocorrect: false,
          style: const TextStyle(fontSize: 14, color: AppPalette.textPrimary),
          decoration: InputDecoration(
            labelText: isFirebase ? 'URL Firebase RTDB' : 'Alamat IP ESP32',
            labelStyle: const TextStyle(
              fontSize: 13,
              color: AppPalette.textSecondary,
            ),
            hintText: isFirebase
                ? 'https://xxx-default-rtdb.asia-southeast1.firebasedatabase.app'
                : 'http://192.168.137.10',
            hintStyle: const TextStyle(color: AppPalette.textMuted),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onConnect,
            icon: Icon(
              isFirebase ? Icons.cloud_done_outlined : Icons.wifi_rounded,
              size: 18,
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
    final fg = selected ? AppPalette.onAccent : AppPalette.textSecondary;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? AppPalette.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
