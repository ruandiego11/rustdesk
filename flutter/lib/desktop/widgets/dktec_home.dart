import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hbb/common.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dktec_contato.dart';

String _digits(String s) => s.replaceAll(RegExp(r'\D'), '');

void _copy(String text) {
  Clipboard.setData(ClipboardData(text: text));
  showToast(translate('Copied'));
}

Widget dktecCopyButton(String Function() id, String Function() password) {
  return Container(
    margin: const EdgeInsets.only(left: 20, right: 16, bottom: 12),
    width: double.infinity,
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: MyTheme.button,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: const Icon(Icons.copy, size: 18),
      label: const Text('Copiar ID e senha'),
      onPressed: () {
        final lines = [dktecTitulo, 'ID: ${id()}'];
        final pw = password().trim();
        if (pw.isNotEmpty && pw != '-') lines.add('Senha: $pw');
        _copy(lines.join('\n'));
      },
    ),
  );
}

Widget _contactItem(BuildContext context, IconData icon, String text,
    {String? link}) {
  return InkWell(
    borderRadius: BorderRadius.circular(6),
    onTap: () async {
      if (link != null && await canLaunchUrl(Uri.parse(link))) {
        await launchUrl(Uri.parse(link));
      } else {
        _copy(text);
      }
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: MyTheme.button),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    ),
  );
}

Widget dktecContactCard(BuildContext context) {
  final items = <Widget>[
    if (dktecTelefone.isNotEmpty)
      _contactItem(context, Icons.phone, dktecTelefone),
    if (dktecWhatsapp.isNotEmpty)
      _contactItem(context, Icons.chat_outlined, dktecWhatsapp,
          link: 'https://wa.me/${_digits(dktecWhatsapp)}'),
    if (dktecEmail.isNotEmpty)
      _contactItem(context, Icons.email_outlined, dktecEmail,
          link: 'mailto:$dktecEmail'),
    if (dktecSite.isNotEmpty)
      _contactItem(context, Icons.language, dktecSite,
          link: dktecSite.startsWith('http') ? dktecSite : 'https://$dktecSite'),
    if (dktecHorario.isNotEmpty)
      _contactItem(context, Icons.schedule, dktecHorario),
  ];
  if (items.isEmpty) return const Offstage();
  return Container(
    margin: const EdgeInsets.only(left: 20, right: 16, bottom: 12),
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
    decoration: BoxDecoration(
      color: MyTheme.button.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: MyTheme.button.withOpacity(0.4)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(dktecContatoTitulo,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        ...items,
      ],
    ),
  );
}
