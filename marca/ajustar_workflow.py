#!/usr/bin/env python3
"""Ajusta .github/workflows/flutter-build.yml do fork para o build Dktec.

- compila só Windows x64 e Linux x86_64 (os outros jobs ficam desligados);
- aplica a marca (personalizar.py --sem-imagens) logo após o checkout, porque o
  submódulo libs/hbb_common chega do repositório oficial sem a marca;
- renomeia o executável para <app_name>.exe e publica os arquivos com esse nome.

Uso: python3 marca/ajustar_workflow.py [pasta-do-rustdesk]
"""

import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
WORKFLOW = ".github/workflows/flutter-build.yml"
DISABLED_JOBS = {
    "build-for-windows-sciter", "build-rustdesk-ios", "build-for-macOS", "publish_unsigned",
    "build-rustdesk-android", "build-rustdesk-android-universal", "build-rustdesk-linux-sciter",
    "build-flatpak",
}
BRANDED_JOBS = {"build-for-windows-flutter", "build-rustdesk-linux"}
BRAND_STEP = [
    "      - name: Aplicar marca Dktec\n",
    "        shell: bash\n",
    "        run: python3 marca/personalizar.py . --sem-imagens\n",
    "\n",
]
MARK = "Aplicar marca Dktec"


def drop_matrix_entry(text, marker):
    """Remove da matriz o bloco '- {' que contém marker."""
    pattern = re.compile(r"\n          - \{\n(?:(?!          - \{|    steps:).*\n)*?.*" + re.escape(marker) +
                         r".*\n(?:(?!          - \{|    steps:).*\n)*?\s*\}\n")
    new, n = pattern.subn("\n", text, count=1)
    if n != 1:
        sys.exit(f"ERRO: entrada de matriz com {marker!r} não encontrada")
    return new


def replace(text, old, new, count=1):
    if new in text and old not in text:
        return text
    found = text.count(old)
    if found != count:
        sys.exit(f"ERRO: esperava {count} ocorrência(s) de {old!r}, achei {found}")
    return text.replace(old, new)


def main():
    root = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "..", "rustdesk"))
    with open(os.path.join(HERE, "dktec.json"), encoding="utf-8") as f:
        cfg = json.load(f)
    app, company = cfg["app_name"], cfg["empresa"]
    path = os.path.join(root, WORKFLOW)
    with open(path, encoding="utf-8") as f:
        text = f.read()
    appimage_aarch64 = "          - { target: aarch64-unknown-linux-gnu, arch: aarch64 }\n"
    if text.count(appimage_aarch64) == 1:
        text = text.replace(appimage_aarch64, "")
    if MARK in text:
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
        print("Workflow já ajustado.")
        return

    text = drop_matrix_entry(text, "target: aarch64-pc-windows-msvc")
    text = drop_matrix_entry(text, "target: aarch64-unknown-linux-gnu")

    out, job, in_header, pending_brand = [], None, False, False
    for line in text.splitlines(keepends=True):
        m = re.match(r"^  ([\w-]+):\s*$", line)
        if m:
            job, in_header = m.group(1), True
            out.append(line)
            if job in DISABLED_JOBS:
                out.append("    if: false\n")
            continue
        if line.startswith("    steps:"):
            in_header = False
        if in_header and job in DISABLED_JOBS and line.startswith("    if:"):
            continue
        out.append(line)
        if job in BRANDED_JOBS and "name: Checkout source code" in line:
            pending_brand = True
        elif pending_brand and line.strip() == "submodules: recursive":
            out.append("\n")
            out.extend(BRAND_STEP[:-1])
            pending_brand = False
    text = "".join(out)
    if text.count(MARK) != len(BRANDED_JOBS):
        sys.exit("ERRO: passo da marca não foi inserido em todos os jobs")

    text = replace(text, "mv ./flutter/build/windows/${{ matrix.job.flutter-arch }}/runner/Release ./rustdesk\n",
                   "mv ./flutter/build/windows/${{ matrix.job.flutter-arch }}/runner/Release ./rustdesk\n"
                   f"          mv ./rustdesk/rustdesk.exe ./rustdesk/{app}.exe\n")
    text = replace(text, "-e ../../rustdesk/rustdesk.exe", f"-e ../../rustdesk/{app}.exe")
    text = replace(text, "./SignOutput/rustdesk-${{ env.VERSION }}-${{ matrix.job.arch }}.exe",
                   f"./SignOutput/{app}-${{{{ env.VERSION }}}}-${{{{ matrix.job.arch }}}}.exe")
    text = replace(text, "../../SignOutput/rustdesk-${{ env.VERSION }}-${{ matrix.job.arch }}.msi",
                   f"../../SignOutput/{app}-${{{{ env.VERSION }}}}-${{{{ matrix.job.arch }}}}.msi")
    text = replace(text, "sha256sum ../../SignOutput/rustdesk-*.msi", f"sha256sum ../../SignOutput/{app}-*.msi")
    text = replace(text, "python preprocess.py --arp -d ../../rustdesk",
                   f"python preprocess.py --arp -d ../../rustdesk --app-name {app} -m {company}")
    text = replace(text, "            ./SignOutput/rustdesk-*.msi\n            ./SignOutput/rustdesk-*.exe\n",
                   f"            ./SignOutput/{app}-*.msi\n            ./SignOutput/{app}-*.exe\n")

    with open(path, "w", encoding="utf-8") as f:
        f.write(text)
    print("Workflow ajustado:", path)


if __name__ == "__main__":
    main()
