"""Generate standalone, dependency-free CMD downloaders from the local catalog.

The readable PowerShell template is compiled into each CMD as fixed inline code.
Only package metadata is Base64 encoded; it is data, never executable code.
Run with --check to verify generated files without writing anything.
"""
from __future__ import annotations

import argparse
import base64
import json
import re
from pathlib import Path
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parent
FILE_FIELDS = ("filename", "url", "sha256", "integrity", "signer_pattern", "verification")


def powershell_source() -> str:
    lines = (ROOT / "downloader.ps1").read_text(encoding="utf-8").splitlines()
    source = " ".join(line.strip() for line in lines if line.strip() and not line.lstrip().startswith("#"))
    if '"' in source or "%" in source or "\n" in source:
        raise ValueError("The inline template must not contain CMD quotes, percent expansion or newlines")
    return source


def validate_package(package: dict) -> None:
    if not re.fullmatch(r"Download-[A-Za-z0-9-]+\.cmd", package["command"]):
        raise ValueError("Unsafe command name")
    if not package.get("files"):
        raise ValueError("At least one payload is required")
    names = set()
    for file in package["files"]:
        name = file["filename"]
        if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._+-]*", name) or name.casefold() in names:
            raise ValueError("Unsafe or duplicate output filename")
        names.add(name.casefold())
        url = urlsplit(file["url"])
        if url.scheme != "https" or not url.hostname or url.username or url.password:
            raise ValueError("Credential-free HTTPS is required")
        if file.get("sha256") and not re.fullmatch(r"[0-9a-fA-F]{64}", file["sha256"]):
            raise ValueError("Invalid SHA256 pin")
        if file.get("integrity"):
            if not file["integrity"].startswith("sha512-"):
                raise ValueError("Only SHA512 SRI is supported")
            if len(base64.b64decode(file["integrity"][7:], validate=True)) != 64:
                raise ValueError("Invalid SHA512 pin")
        if not (file.get("sha256") or file.get("integrity") or file.get("signer_pattern") or file.get("verification") == "https-only"):
            raise ValueError("An explicit verification policy is required")


def build_cmd(package: dict, source: str) -> bytes:
    validate_package(package)
    data = {"name": package["name"], "version": package["version"], "files": [
        {key: file[key] for key in FILE_FIELDS if key in file} for file in package["files"]
    ]}
    metadata = base64.b64encode(json.dumps(data, ensure_ascii=True, separators=(",", ":")).encode()).decode()
    entry = "$code=Invoke-Download; if($env:LAB_DOWNLOAD_NOPAUSE -ne '1' -and -not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected){Write-Host 'Press Enter to close.';[void][Console]::ReadLine()}; exit $code"
    lines = [
        "@echo off", "setlocal DisableDelayedExpansion",
        'if not "%~2"=="" goto bad_arguments',
        'if /i "%~1"=="--help" goto help',
        'if not "%~1"=="" if /i not "%~1"=="--no-pause" goto bad_arguments',
        f'set "LAB_DOWNLOAD_META={metadata}"',
        'set "LAB_DOWNLOAD_DIR=%CD%"',
        'set "LAB_DOWNLOAD_NOPAUSE="',
        'if /i "%~1"=="--no-pause" set "LAB_DOWNLOAD_NOPAUSE=1"',
        f'"%SystemRoot%\\System32\\WindowsPowerShell\\v1.0\\powershell.exe" -NoLogo -NoProfile -Command "{source} {entry}"',
        'exit /b %ERRORLEVEL%',
        ':bad_arguments',
        'echo Use --help or --no-pause only. 1>&2',
        'exit /b 2',
        ':help', f'echo {package["command"]} - download only',
        'echo Saves to the current working folder, not the script folder.',
        'echo No installation, extraction, execution, elevation or system changes.',
        'echo Existing output files are refused, never overwritten.',
        'echo Usage: "%~nx0" [--help ^| --no-pause]',
    ]
    lines.extend("echo File: " + file["filename"] for file in package["files"])
    lines.extend(['exit /b 0', ''])
    output = '\r\n'.join(lines).encode('utf-8')
    if max(map(len, output.splitlines())) >= 8191:
        raise ValueError("Generated CMD exceeds the Windows command-line limit")
    return output


def check_manifest(commands: list[str]) -> None:
    names = json.loads((ROOT / "manifest.json").read_text(encoding="utf-8-sig"))["files"]
    required = {".gitignore", "manifest.json", "catalog.json", "downloader.ps1",
                "build_downloaders.py", *commands}
    if (not required.issubset(names) or len({name.casefold() for name in names}) != len(names)
            or any(not re.fullmatch(r"[A-Za-z0-9.][A-Za-z0-9._-]*", name)
                   or not (ROOT / name).is_file() for name in names)):
        raise SystemExit("manifest.json must list existing, unique source filenames and all generated CMDs")
    rules = [line for line in (ROOT / ".gitignore").read_text(encoding="utf-8").splitlines()
             if line and not line.startswith("#")]
    if rules != ["/*", *(f"!/{name}" for name in names)]:
        raise SystemExit(".gitignore must allow exactly the files in manifest.json, in the same order")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args(argv)
    catalog = json.loads((ROOT / "catalog.json").read_text(encoding="utf-8-sig"))
    if catalog.get("format") != 1:
        raise ValueError("Unsupported catalog format")
    packages = catalog["packages"]
    commands = [package["command"] for package in packages]
    if len(commands) != len({name.casefold() for name in commands}):
        raise ValueError("Duplicate command name")
    source = powershell_source()
    # Validate and render the entire catalog before replacing any output.
    outputs = [(ROOT / package["command"], build_cmd(package, source)) for package in packages]
    if args.check:
        check_manifest(commands)
    for path, rendered in outputs:
        if args.check:
            if not path.is_file() or path.read_bytes() != rendered:
                raise SystemExit(f"Out of date: {path.name}")
        else:
            path.write_bytes(rendered)
    if args.check:
        print(f"Checked {len(outputs)} standalone CMD downloaders and the software allowlist.")
    else:
        print(f"Generated {len(outputs)} standalone CMD downloaders.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
