#!/usr/bin/env python3
"""Check the editable catalog and the generated runtime .strings resources."""
import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--write", action="store_true", help="regenerate resources after editing the catalog")
args = parser.parse_args()
catalog = json.loads((ROOT / "Localization/Support.xcstrings").read_text())
languages = {"en", "zh-Hans"}
assert catalog["sourceLanguage"] == "en"
outputs = {lang: "/* Generated from Localization/Support.xcstrings. Run Scripts/check-localizations.py --write. */\n" for lang in languages}
for key, entry in sorted(catalog["strings"].items()):
    assert set(entry["localizations"]) == languages, f"{key}: expected English and Simplified Chinese"
    for lang in languages:
        unit = entry["localizations"][lang]["stringUnit"]
        value = unit["value"]
        assert unit["state"] == "translated" and value.strip(), f"{key}/{lang}: missing translation"
        assert re.findall(r"%(?:\d+\$)?[@dfsu]", key) == re.findall(r"%(?:\d+\$)?[@dfsu]", value), f"{key}/{lang}: placeholder mismatch"
        outputs[lang] += json.dumps(key, ensure_ascii=False) + " = " + json.dumps(value, ensure_ascii=False) + ";\n"
for lang, expected in outputs.items():
    resource = ROOT / f"Sources/AppSupportCore/Resources/{lang}.lproj/Localizable.strings"
    if args.write:
        resource.parent.mkdir(parents=True, exist_ok=True)
        resource.write_text(expected)
    else:
        assert resource.read_text() == expected, f"{resource}: stale; run this script with --write"
print(f"Validated {len(catalog['strings'])} keys in {len(languages)} languages.")
