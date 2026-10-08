# Changelog

## 2.0.0 — 2026-10-08

Breaking redesign for iOS 17+ and macOS 13+, with separate `AppSupportCore` and `AppSupportUI` products.

- Complete resolved copy supports arbitrary host languages; built-in English and Simplified Chinese are selected explicitly.
- Independent plain mail drafts include version, build, system, hardware and optional host fields.
- Composable rows and identity components support custom cards, native navigation, legal groups and host actions.
- URL actions report system acceptance; rejected mail actions provide selectable/copyable support details and an optional support website.
- Semantic accessories, shared icon alignment, multiline labels and LTR version values support RTL and accessibility layouts.
- Standard-backend tests replace the deprecated native-backend workaround.

See [migration](Docs/Migration-2.0.md) for removed APIs and consumer migration instructions, and [validation](Docs/Validation-2.0.md) for verified results and remaining checks.
