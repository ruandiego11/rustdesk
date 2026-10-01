import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/models/state_model.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dktec_contato.dart';

class DkColors {
  static const window = Color(0xFF070C18);
  static const workspace = Color(0xFF070B16);
  static const sidebar = Color(0xFF080D1A);
  static const titleBar = Color(0xFF090F20);
  static const card = Color(0xFF0B1224);
  static const cardAlt = Color(0xFF0A1122);
  static const row = Color(0xFF0D162C);
  static const rowHover = Color(0xFF122040);
  static const input = Color(0xFF091122);
  static const border = Color(0xFF1C2C4D);
  static const borderSoft = Color(0xFF16233D);
  static const divider = Color(0xFF141F36);
  static const neonBlue = Color(0xFF0066FF);
  static const cyan = Color(0xFF00D2FF);
  static const sky400 = Color(0xFF38BDF8);
  static const sky500 = Color(0xFF0EA5E9);
  static const sky600 = Color(0xFF0284C7);
  static const blue400 = Color(0xFF60A5FA);
  static const blue500 = Color(0xFF3B82F6);
  static const blue600 = Color(0xFF2563EB);
  static const indigo400 = Color(0xFF818CF8);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate300 = Color(0xFFCBD5E1);
  static const slate400 = Color(0xFF94A3B8);
  static const slate500 = Color(0xFF64748B);
  static const slate600 = Color(0xFF475569);
  static const emerald400 = Color(0xFF34D399);
  static const emerald500 = Color(0xFF10B981);
  static const amber400 = Color(0xFFFBBF24);
  static const red400 = Color(0xFFF87171);

  static const buttonGradient =
      LinearGradient(colors: [blue600, Color(0xFF3B82F6), sky500]);
}

const dkMono = TextStyle(
  fontFamily: 'monospace',
  fontFamilyFallback: [
    'Consolas',
    'JetBrains Mono',
    'DejaVu Sans Mono',
    'Liberation Mono',
    'Courier New',
  ],
);

VoidCallback? dktecFocusRemoteId;

String _digits(String s) => s.replaceAll(RegExp(r'\D'), '');

void _copy(String text, [String? message]) {
  Clipboard.setData(ClipboardData(text: text));
  showToast(message ?? translate('Copied'));
}

class _HoverIcon extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final double size;

  const _HoverIcon(this.icon, this.tooltip, this.onTap, {this.size = 15});

  @override
  State<_HoverIcon> createState() => _HoverIconState();
}

class _HoverIconState extends State<_HoverIcon> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _hover ? const Color(0xFF131F3B) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: _hover
                      ? const Color(0x801E3A8A)
                      : Colors.transparent),
            ),
            child: Icon(widget.icon,
                size: widget.size,
                color: _hover ? DkColors.blue400 : DkColors.slate400),
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    paint.shader = const SweepGradient(
      colors: [DkColors.cyan, DkColors.blue600, DkColors.cyan],
    ).createShader(rect);
    canvas.drawArc(rect, -math.pi * 0.85, math.pi * 0.95, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = DkColors.sky400.withOpacity(0.35);
    final r = size.width / 2;
    const dashes = 28;
    for (var i = 0; i < dashes; i++) {
      final start = i * 2 * math.pi / dashes;
      canvas.drawArc(Rect.fromCircle(center: Offset(r, r), radius: r - 1),
          start, math.pi / dashes, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DktecLogo extends StatefulWidget {
  const DktecLogo({Key? key}) : super(key: key);

  @override
  State<DktecLogo> createState() => _DktecLogoState();
}

class _DktecLogoState extends State<DktecLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
      vsync: this, duration: const Duration(seconds: 25))
    ..repeat();

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Column(
        children: [
          SizedBox(
            width: 150,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                RotationTransition(
                  turns: _spin,
                  child: CustomPaint(
                      size: const Size(64, 64), painter: _DashedRingPainter()),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShaderMask(
                          shaderCallback: (r) => const LinearGradient(colors: [
                            DkColors.sky400,
                            DkColors.blue500,
                          ]).createShader(r),
                          child: const Text('dk',
                              style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.8,
                                  color: Colors.white)),
                        ),
                        const Text('tec',
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                                color: Colors.white)),
                      ],
                    ),
                    Positioned(
                      left: -8,
                      right: -8,
                      top: -6,
                      bottom: -6,
                      child: Transform.rotate(
                        angle: -0.2,
                        child: CustomPaint(painter: _ArcPainter()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text('SUPORTE REMOTO',
              style: dkMono.copyWith(
                  fontSize: 11,
                  letterSpacing: 2.6,
                  fontWeight: FontWeight.w600,
                  color: DkColors.sky400.withOpacity(0.9))),
        ],
      ),
    );
  }
}

Widget dktecSidebarHeader(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 16, 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(translate('Your Desktop'),
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.2)),
        const SizedBox(height: 3),
        Text(dktecDica.isNotEmpty ? dktecDica : translate('desk_tip'),
            style: const TextStyle(
                fontSize: 12, height: 1.5, color: DkColors.slate400)),
      ],
    ),
  );
}

class DktecIdCard extends StatelessWidget {
  final TextEditingController controller;
  final Widget? menu;

  const DktecIdCard({Key? key, required this.controller, this.menu})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0C162B), Color(0xFF091022)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DkColors.neonBlue, width: 2),
        boxShadow: [
          BoxShadow(
              color: DkColors.neonBlue.withOpacity(0.38), blurRadius: 18),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.desktop_windows_outlined,
                  size: 16, color: DkColors.blue400),
              const SizedBox(width: 8),
              Text(translate('ID'),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: DkColors.slate300)),
              const Spacer(),
              if (menu != null) menu!,
              _HoverIcon(Icons.copy_rounded, translate('Copy'),
                  () => _copy(controller.text.replaceAll(' ', ''))),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, _) => GestureDetector(
                    onDoubleTap: () => _copy(value.text.replaceAll(' ', '')),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: SelectableText(
                        value.text,
                        maxLines: 1,
                        style: dkMono.copyWith(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                margin: const EdgeInsets.only(bottom: 6, right: 4),
                decoration: BoxDecoration(
                  color: const Color(0x99172554),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0x661E40AF)),
                ),
                child: Text('DK-ID',
                    style: dkMono.copyWith(
                        fontSize: 10,
                        color: DkColors.blue400.withOpacity(0.8))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DktecPasswordCard extends StatefulWidget {
  final TextEditingController controller;
  final bool showOneTime;
  final VoidCallback? onRefresh;
  final VoidCallback? onEdit;

  const DktecPasswordCard(
      {Key? key,
      required this.controller,
      required this.showOneTime,
      this.onRefresh,
      this.onEdit})
      : super(key: key);

  @override
  State<DktecPasswordCard> createState() => _DktecPasswordCardState();
}

class _DktecPasswordCardState extends State<DktecPasswordCard> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: DkColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DkColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x40000000), blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.vpn_key_outlined,
                  size: 14, color: DkColors.slate400),
              const SizedBox(width: 6),
              Expanded(
                child: Text(translate('One-time Password'),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: DkColors.slate400)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: widget.controller,
                  builder: (context, value, _) => GestureDetector(
                    onDoubleTap: widget.showOneTime
                        ? () => _copy(value.text)
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Text(
                        _visible || value.text.length < 2
                            ? value.text
                            : '•' * value.text.length,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: dkMono.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: DkColors.slate100),
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.showOneTime)
                _HoverIcon(
                    _visible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    translate('Show'),
                    () => setState(() => _visible = !_visible)),
              if (widget.showOneTime && widget.onRefresh != null)
                _HoverIcon(Icons.refresh_rounded, translate('Refresh Password'),
                    widget.onRefresh),
              if (widget.showOneTime)
                _HoverIcon(Icons.copy_rounded, translate('Copy'),
                    () => _copy(widget.controller.text)),
              if (widget.onEdit != null)
                _HoverIcon(Icons.edit_outlined, translate('Change Password'),
                    widget.onEdit),
            ],
          ),
        ],
      ),
    );
  }
}

class DktecGradientButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final Gradient gradient;
  final bool shadow;

  const DktecGradientButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
    this.gradient = DkColors.buttonGradient,
    this.shadow = true,
  }) : super(key: key);

  @override
  State<DktecGradientButton> createState() => _DktecGradientButtonState();
}

class _DktecGradientButtonState extends State<DktecGradientButton> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _down = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _down ? 0.985 : 1,
          duration: const Duration(milliseconds: 90),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: widget.padding,
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: widget.borderRadius,
              border: Border.all(color: DkColors.blue400.withOpacity(0.4)),
              boxShadow: widget.shadow
                  ? [
                      BoxShadow(
                          color: DkColors.blue600
                              .withOpacity(_hover ? 0.45 : 0.25),
                          blurRadius: _hover ? 18 : 12,
                          offset: const Offset(0, 4)),
                    ]
                  : null,
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              color: _hover ? Colors.white.withOpacity(0.08) : null,
            ),
            child: DefaultTextStyle.merge(
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
              child: IconTheme.merge(
                data: const IconThemeData(color: Colors.white, size: 16),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget dktecCopyButton(String Function() id, String Function() password) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
    child: DktecGradientButton(
      gradient: const LinearGradient(colors: [DkColors.blue600, DkColors.sky600]),
      onPressed: () {
        final lines = [dktecTitulo, 'ID: ${id()}'];
        final pw = password().trim();
        if (pw.isNotEmpty && pw != '-') lines.add('Senha: $pw');
        _copy(lines.join('\n'), 'ID e senha copiados!');
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.copy_rounded),
          SizedBox(width: 8),
          Text('Copiar ID e senha'),
        ],
      ),
    ),
  );
}

class _ContactRow extends StatefulWidget {
  final Widget leading;
  final String text;
  final Widget? badge;
  final Color hoverColor;
  final VoidCallback onTap;

  const _ContactRow(
      {required this.leading,
      required this.text,
      this.badge,
      this.hoverColor = DkColors.sky400,
      required this.onTap});

  @override
  State<_ContactRow> createState() => _ContactRowState();
}

class _ContactRowState extends State<_ContactRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: _hover ? DkColors.rowHover : DkColors.row,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF192B4D)),
          ),
          child: Row(
            children: [
              AnimatedScale(
                  scale: _hover ? 1.1 : 1,
                  duration: const Duration(milliseconds: 150),
                  child: widget.leading),
              const SizedBox(width: 8),
              Flexible(
                child: Text(widget.text,
                    overflow: TextOverflow.ellipsis,
                    style: dkMono.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: DkColors.slate200)),
              ),
              if (widget.badge != null) ...[
                const SizedBox(width: 8),
                widget.badge!,
              ],
              const Spacer(),
              AnimatedSlide(
                offset: Offset(_hover ? 0.15 : 0, 0),
                duration: const Duration(milliseconds: 150),
                child: Icon(Icons.chevron_right_rounded,
                    size: 16,
                    color: _hover ? widget.hoverColor : DkColors.slate500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _open(String link, String fallbackText) async {
  final uri = Uri.parse(link);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    _copy(fallbackText);
  }
}

Widget dktecContactCard(BuildContext context) {
  final rows = <Widget>[
    if (dktecTelefone.isNotEmpty)
      _ContactRow(
        leading: const Icon(Icons.phone_in_talk_outlined,
            size: 15, color: DkColors.sky400),
        text: dktecTelefone,
        onTap: () => _copy(dktecTelefone, 'Telefone copiado!'),
      ),
    if (dktecWhatsapp.isNotEmpty)
      _ContactRow(
        leading: const Icon(Icons.chat_bubble_outline_rounded,
            size: 15, color: DkColors.emerald400),
        text: dktecWhatsapp,
        hoverColor: DkColors.emerald400,
        badge: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: DkColors.emerald500.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: DkColors.emerald500.withOpacity(0.4)),
          ),
          child: const Text('WhatsApp',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: DkColors.emerald400)),
        ),
        onTap: () =>
            _open('https://wa.me/${_digits(dktecWhatsapp)}', dktecWhatsapp),
      ),
    if (dktecEmail.isNotEmpty)
      _ContactRow(
        leading: const Icon(Icons.mail_outline_rounded,
            size: 15, color: DkColors.sky400),
        text: dktecEmail,
        onTap: () => _open('mailto:$dktecEmail', dktecEmail),
      ),
    if (dktecSite.isNotEmpty)
      _ContactRow(
        leading:
            const Icon(Icons.language_rounded, size: 15, color: DkColors.sky400),
        text: dktecSite,
        onTap: () => _open(
            dktecSite.startsWith('http') ? dktecSite : 'https://$dktecSite',
            dktecSite),
      ),
    if (dktecHorario.isNotEmpty)
      _ContactRow(
        leading:
            const Icon(Icons.schedule_rounded, size: 15, color: DkColors.sky400),
        text: dktecHorario,
        onTap: () => _copy(dktecHorario),
      ),
  ];
  if (rows.isEmpty) return const Offstage();
  return Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
    decoration: BoxDecoration(
      color: DkColors.cardAlt,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: DkColors.borderSoft),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xB3172554),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0x661E40AF)),
              ),
              child: const Icon(Icons.headset_mic_outlined,
                  size: 16, color: DkColors.sky400),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dktecContatoTitulo,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  if (dktecContatoSubtitulo.isNotEmpty)
                    Text(dktecContatoSubtitulo,
                        style: const TextStyle(
                            fontSize: 11, color: DkColors.slate400)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...rows,
      ],
    ),
  );
}

class _PulseDot extends StatefulWidget {
  final Color color;
  final bool animate;

  const _PulseDot({required this.color, this.animate = true});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 14,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.animate)
            AnimatedBuilder(
              animation: _c,
              builder: (_, __) => Transform.scale(
                scale: 1 + _c.value * 1.2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity(0.6 * (1 - _c.value)),
                  ),
                ),
              ),
            ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
              boxShadow: [
                BoxShadow(color: widget.color.withOpacity(0.7), blurRadius: 6)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget dktecSidebarStatus() {
  return Obx(() {
    final status = stateGlobal.svcStatus.value;
    final Color color;
    final String title;
    final String sub;
    if (status == SvcStatus.ready) {
      color = DkColors.emerald500;
      title = 'Online';
      sub = 'Pronto para receber conexões';
    } else if (status == SvcStatus.connecting) {
      color = DkColors.amber400;
      title = 'Conectando';
      sub = 'Conectando ao servidor Dktec…';
    } else {
      color = DkColors.red400;
      title = 'Offline';
      sub = 'Sem conexão com o servidor Dktec';
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF131D33))),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1222),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF172544)),
        ),
        child: Row(
          children: [
            _PulseDot(color: color, animate: status == SvcStatus.ready),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color == DkColors.emerald500
                              ? DkColors.emerald400
                              : color)),
                  Text(sub,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 10, color: DkColors.slate400)),
                ],
              ),
            ),
            SizedBox(
              width: 34,
              height: 34,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _ring(32, color.withOpacity(0.2)),
                  _ring(20, color.withOpacity(0.4)),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  });
}

Widget _ring(double size, Color color) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle, border: Border.all(color: color)),
    );

class _HoloPainter extends CustomPainter {
  final double t;

  _HoloPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final scale = math.min(size.width / 450, size.height / 180);
    canvas.translate(size.width - 450 * scale, (size.height - 180 * scale) / 2);
    canvas.scale(scale);

    final glow = const LinearGradient(colors: [DkColors.neonBlue, DkColors.cyan])
        .createShader(const Rect.fromLTWH(0, 0, 450, 180));
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..shader = glow
      ..strokeCap = StrokeCap.round;

    void monitor(Offset at, double skew, double s, double w, double h,
        Color fill, bool details) {
      canvas.save();
      canvas.translate(at.dx, at.dy);
      canvas.transform(Matrix4.skewY(skew).storage);
      canvas.scale(s);
      final body = RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, w, h), const Radius.circular(8));
      canvas.drawRRect(body, Paint()..color = fill);
      canvas.drawRRect(body, stroke..strokeWidth = 1.8);
      canvas.drawLine(Offset(w / 2, h), Offset(w / 2, h + 26),
          stroke..strokeWidth = 2);
      canvas.drawLine(Offset(w / 2 - 22, h + 26), Offset(w / 2 + 22, h + 26),
          stroke..strokeWidth = 2.6);
      if (details) {
        canvas.drawCircle(const Offset(20, 22), 5, Paint()..color = DkColors.cyan);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTWH(35, 18, 55, 8), const Radius.circular(2)),
            Paint()..color = DkColors.neonBlue.withOpacity(0.4));
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTWH(20, 40, 100, 38), const Radius.circular(4)),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1
              ..color = DkColors.cyan.withOpacity(0.5));
      } else {
        for (var x = 15.0; x < 60; x += 6) {
          canvas.drawLine(Offset(x, 20), Offset(x + 3, 20),
              stroke..strokeWidth = 1.5);
        }
        canvas.drawLine(const Offset(15, 35), const Offset(95, 35),
            Paint()
              ..strokeWidth = 1.2
              ..color = DkColors.cyan.withOpacity(0.6));
      }
      canvas.restore();
    }

    monitor(const Offset(40, 20), -0.14, 0.75, 130, 90,
        const Color(0x6606193C), false);

    final path = Path()
      ..moveTo(140, 70)
      ..cubicTo(210, 10, 260, 20, 310, 65);
    final pulse = 0.55 + 0.45 * math.sin(t * 2 * math.pi);
    final dash = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = DkColors.cyan.withOpacity(pulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 10) {
        canvas.drawPath(metric.extractPath(d, d + 4), dash);
      }
      final pos = metric.getTangentForOffset(metric.length * t)?.position;
      if (pos != null) {
        canvas.drawCircle(
            pos,
            3.5,
            Paint()
              ..color = Colors.white
              ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3));
      }
    }

    monitor(const Offset(300, 35), 0.14, 0.9, 140, 96,
        const Color(0x80081E4B), true);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HoloPainter oldDelegate) => oldDelegate.t != t;
}

class DktecHeroCard extends StatefulWidget {
  final Widget child;

  const DktecHeroCard({Key? key, required this.child}) : super(key: key);

  @override
  State<DktecHeroCard> createState() => _DktecHeroCardState();
}

class _DktecHeroCardState extends State<DktecHeroCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2200))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xE6091A3E), Color(0xF2071026)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DkColors.blue500.withOpacity(0.3)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x99000000), blurRadius: 25, offset: Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Color(0x3338BDF8), width: 1)),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: LayoutBuilder(builder: (context, _) {
                final w = MediaQuery.of(context).size.width;
                if (w < 900) return const SizedBox.shrink();
                return IgnorePointer(
                  child: Opacity(
                    opacity: w < 1200 ? 0.45 : 0.75,
                    child: SizedBox(
                      width: w * 0.28,
                      child: AnimatedBuilder(
                        animation: _c,
                        builder: (_, __) =>
                            CustomPaint(painter: _HoloPainter(_c.value)),
                      ),
                    ),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration dktecIdInputDecoration(String? hint) {
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c, width: w),
      );
  return InputDecoration(
    filled: true,
    fillColor: DkColors.input.withOpacity(0.9),
    counterText: '',
    hintText: hint,
    hintStyle: const TextStyle(color: DkColors.slate400, fontSize: 14),
    prefixIcon: const Icon(Icons.desktop_windows_outlined,
        size: 17, color: DkColors.slate400),
    prefixIconConstraints: const BoxConstraints(minWidth: 42),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: border(const Color(0xCC334155)),
    enabledBorder: border(const Color(0xCC334155)),
    focusedBorder: border(DkColors.blue500, 1.5),
  );
}

Widget dktecHeroTitle(Widget title) {
  return Row(
    children: [
      const Icon(Icons.desktop_windows_outlined,
          size: 20, color: DkColors.sky400),
      const SizedBox(width: 10),
      Expanded(child: title),
    ],
  );
}

class DktecEmptyState extends StatelessWidget {
  final String message;

  const DktecEmptyState({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final parts = message.split('\n');
    final title = parts.first.trim();
    final sub = parts.skip(1).join(' ').trim();
    return Center(
      child: SingleChildScrollView(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  DkColors.blue600.withOpacity(0.08),
                  DkColors.blue600.withOpacity(0),
                ]),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF0C1933), Color(0xFF071022)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF1C2E55)),
                      ),
                      child: const Icon(Icons.desktop_windows_outlined,
                          size: 46, color: DkColors.slate500),
                    ),
                    Positioned(
                      right: -6,
                      bottom: -6,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF091329),
                          shape: BoxShape.circle,
                          border: Border.all(color: DkColors.slate600),
                        ),
                        child: const Icon(Icons.schedule_rounded,
                            size: 16, color: DkColors.sky400),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: DkColors.slate200)),
                if (sub.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(sub,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13, color: DkColors.slate400)),
                ],
                if (dktecFocusRemoteId != null) ...[
                  const SizedBox(height: 20),
                  DktecGradientButton(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                    gradient: const LinearGradient(
                        colors: [DkColors.blue600, DkColors.sky600]),
                    onPressed: () => dktecFocusRemoteId?.call(),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Conectar agora', style: TextStyle(fontSize: 12)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 14),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget dktecServerInfo() {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.dns_outlined, size: 14, color: DkColors.sky400),
      const SizedBox(width: 6),
      const Text('Servidor: ',
          style: TextStyle(fontSize: 11, color: DkColors.slate300)),
      Text('Padrão (${dktecEmpresa})',
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: DkColors.slate100)),
    ],
  ).marginOnly(right: 14);
}
