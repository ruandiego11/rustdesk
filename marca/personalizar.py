#!/usr/bin/env python3
"""Aplica a marca Dktec num checkout do RustDesk.

Uso: python3 marca/personalizar.py [pasta-do-rustdesk] [--sem-imagens]   (padrão: ../rustdesk)

--sem-imagens: só as trocas de texto (usado no GitHub Actions, onde os ícones já vêm no fork
e o submódulo libs/hbb_common chega sem a marca).

Cada troca precisa encontrar o trecho original exatamente; se uma versão nova do RustDesk
mudar algum deles, o script para com erro em vez de gerar um build pela metade.
Rodar de novo no mesmo checkout não faz nada (as trocas já aplicadas são reconhecidas).
"""

import base64
import json
import os
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))


def load_config():
    with open(os.path.join(HERE, "dktec.json"), encoding="utf-8") as f:
        return json.load(f)


def replace(root, path, old, new, count=1):
    full = os.path.join(root, path)
    with open(full, encoding="utf-8") as f:
        text = f.read()
    if new in text and old not in text:
        return
    found = text.count(old)
    if found != count:
        sys.exit(f"ERRO: {path}: esperava {count} ocorrência(s) de {old!r}, achei {found}")
    with open(full, "w", encoding="utf-8") as f:
        f.write(text.replace(old, new))
    print(f"  {path}")


def magick(*args):
    subprocess.run(["magick", *args], check=True)


def make_images(root):
    icon = os.path.join(HERE, "icone.png")
    logo = os.path.join(HERE, "logo.png")
    tmp = tempfile.mkdtemp()
    sizes = [16, 24, 32, 48, 64, 128, 256]
    for s in sizes:
        magick(icon, "-resize", f"{s}x{s}", os.path.join(tmp, f"{s}.png"))
    ico = os.path.join(tmp, "icon.ico")
    magick(*[os.path.join(tmp, f"{s}.png") for s in sizes], ico)
    tray = os.path.join(tmp, "tray.ico")
    magick(*[os.path.join(tmp, f"{s}.png") for s in (16, 24, 32)], tray)

    copies = {
        "res/icon.ico": ico,
        "res/tray-icon.ico": tray,
        "flutter/windows/runner/resources/app_icon.ico": ico,
        "flutter/assets/icon.ico": ico,
        "res/icon.png": icon,
        "res/mac-icon.png": icon,
        "flutter/assets/icon.png": os.path.join(tmp, "256.png"),
        "res/32x32.png": os.path.join(tmp, "32.png"),
        "res/64x64.png": os.path.join(tmp, "64.png"),
        "res/128x128.png": os.path.join(tmp, "128.png"),
        "res/128x128@2x.png": os.path.join(tmp, "256.png"),
        "flutter/assets/logo.png": logo,
    }
    for dst, src in copies.items():
        shutil.copyfile(src, os.path.join(root, dst))
        print(f"  {dst}")

    with open(os.path.join(tmp, "256.png"), "rb") as f:
        data = base64.b64encode(f.read()).decode()
    svg = ('<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" '
           'viewBox="0 0 256 256"><image width="256" height="256" '
           f'xlink:href="data:image/png;base64,{data}"/></svg>\n')
    for dst in ("flutter/assets/icon.svg", "res/scalable.svg"):
        with open(os.path.join(root, dst), "w") as f:
            f.write(svg)
        print(f"  {dst}")
    shutil.rmtree(tmp)


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    with_images = "--sem-imagens" not in sys.argv
    root = os.path.abspath(args[0] if args else os.path.join(HERE, "..", "rustdesk"))
    cfg = load_config()
    c = cfg["cores"]

    print("Nome, servidor e chave:")
    replace(root, "libs/hbb_common/src/config.rs",
            'RwLock::new("RustDesk".to_owned())', f'RwLock::new("{cfg["app_name"]}".to_owned())')
    replace(root, "libs/hbb_common/src/config.rs",
            'RENDEZVOUS_SERVERS: &[&str] = &["rs-ny.rustdesk.com"]',
            f'RENDEZVOUS_SERVERS: &[&str] = &["{cfg["servidor"]}"]')
    replace(root, "libs/hbb_common/src/config.rs",
            'RS_PUB_KEY: &str = "OeVuKk5nlHiXp+APNn0Y3pC1Iwpwn44JGqrQCsWqmBw="',
            f'RS_PUB_KEY: &str = "{cfg["chave"]}"')

    print("Cores e título:")
    common = "flutter/lib/common.dart"
    replace(root, common, "accent = Color(0xFF0071FF)", f"accent = Color(0xFF{c['primaria']})")
    replace(root, common, "accent50 = Color(0x770071FF)", f"accent50 = Color(0x77{c['primaria']})")
    replace(root, common, "accent80 = Color(0xAA0071FF)", f"accent80 = Color(0xAA{c['primaria']})")
    replace(root, common, "idColor = Color(0xFF00B6F0)", f"idColor = Color(0xFF{c['id']})")
    replace(root, common, "button = Color(0xFF2C8CFF)", f"button = Color(0xFF{c['botao']})")
    replace(root, "flutter/lib/desktop/widgets/tabbar_widget.dart",
            '"RustDesk",\n                              style: TextStyle(fontSize: 13)',
            f'"{cfg["titulo"]}",\n                              style: TextStyle(fontSize: 13)')

    print("Informações do executável:")
    rc = "flutter/windows/runner/Runner.rc"
    replace(root, rc, 'VALUE "CompanyName", "Purslane Tech Pte. Ltd."', f'VALUE "CompanyName", "{cfg["empresa"]}"')
    replace(root, rc, 'VALUE "FileDescription", "RustDesk Remote Desktop"',
            f'VALUE "FileDescription", "{cfg["descricao"]}"')
    replace(root, rc, 'VALUE "LegalCopyright", "Copyright © 2026 Purslane Tech Pte. Ltd. All rights reserved."',
            f'VALUE "LegalCopyright", "{cfg["copyright"]}"')
    replace(root, rc, 'VALUE "ProductName", "RustDesk"', f'VALUE "ProductName", "{cfg["descricao"]}"')
    for cargo in ("Cargo.toml", "libs/portable/Cargo.toml"):
        replace(root, cargo, 'LegalCopyright = "Copyright © 2026 Purslane Tech Pte. Ltd. All rights reserved."',
                f'LegalCopyright = "{cfg["copyright"]}"')
        replace(root, cargo, 'ProductName = "RustDesk"', f'ProductName = "{cfg["descricao"]}"')
        replace(root, cargo, 'FileDescription = "RustDesk Remote Desktop"',
                f'FileDescription = "{cfg["descricao"]}"')
    replace(root, "res/rustdesk.desktop", "Name=RustDesk\n", f"Name={cfg['descricao']}\n")

    if with_images:
        print("Ícones e logo:")
        make_images(root)
    print("Marca Dktec aplicada em", root)


if __name__ == "__main__":
    main()
