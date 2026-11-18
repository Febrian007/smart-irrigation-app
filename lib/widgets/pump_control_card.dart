import 'package:material_ui/material_ui.dart';

import '../theme/app_palette.dart';

class PumpControlCard extends StatelessWidget {
  final String pumpMode;
  final bool pumpOn;
  final int pumpActiveSec;
  final void Function(String command) onCommand;

  const PumpControlCard({
    super.key,
    required this.pumpMode,
    required this.pumpOn,
    required this.pumpActiveSec,
    required this.onCommand,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedMode = pumpMode.toUpperCase();
    final isAuto = normalizedMode == 'AUTO';
    final isManualOn = !isAuto && pumpOn;
    final isManualOff = !isAuto && !pumpOn;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.border),
        boxShadow: [
          BoxShadow(
            color: AppPalette.primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: pumpOn ? AppPalette.mintSoft : AppPalette.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.water_rounded,
                  color: pumpOn ? AppPalette.mint : AppPalette.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pompa Siram',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppPalette.textPrimary,
                      ),
                    ),
                    Text(
                      'Mode $normalizedMode · Aktif $pumpActiveSec dtk',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppPalette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: pumpOn ? AppPalette.mintSoft : AppPalette.coralSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  pumpOn ? 'POMPA ON' : 'POMPA OFF',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: pumpOn ? AppPalette.mint : AppPalette.coral,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PumpActionButton(
                  label: 'AUTO',
                  active: isAuto,
                  activeColor: AppPalette.primary,
                  inactiveBg: AppPalette.primarySoft,
                  inactiveFg: AppPalette.primary,
                  onTap: () => onCommand('auto'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PumpActionButton(
                  label: 'ON',
                  active: isManualOn,
                  activeColor: AppPalette.mint,
                  inactiveBg: AppPalette.mintSoft,
                  inactiveFg: AppPalette.mint,
                  onTap: () => onCommand('on'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PumpActionButton(
                  label: 'OFF',
                  active: isManualOff,
                  activeColor: AppPalette.coral,
                  inactiveBg: AppPalette.coralSoft,
                  inactiveFg: AppPalette.coral,
                  onTap: () => onCommand('off'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PumpActionButton extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor;
  final Color inactiveBg;
  final Color inactiveFg;
  final VoidCallback onTap;

  const _PumpActionButton({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.inactiveBg,
    required this.inactiveFg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? activeColor : inactiveBg,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : inactiveFg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
