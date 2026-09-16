# Changelog

## 0.7.0

- Disabled action selection until a rule condition is selected.
- Replaced the separate familiar action with a character-ability picker containing every usable feat available to the character.
- Made the action editor and its ability, spell, or item picker mutually exclusive so window stacking cannot hide the active window.
- Enumerated all owned active feats from actionable feat metadata, excluding passive feats while retaining temporarily exhausted abilities, and reordered action-source buttons consistently.
- Removed duplicated picker tooltip names and unsupported newline separators.
- Applied summon-presence checks to feat-based familiar and animal-companion abilities as well as summon spells.
- Added action-, rule-, and tactic-level target priorities with action-to-global fallback.
- Replaced separate friendly-fire controls with a single four-mode policy shown only for relevant hostile area spells.
- Removed the radius field from enemy-rating conditions; all visible applicable enemies are filtered.
- Added automatic pre-equipping for item powers and a standalone equipment action.
- Corrected inventory item icon fallback for scrolls and other model-icon gaps.
- Completed unique-power activation before opening the editor, preventing a stuck targeting cursor and action-queue icon.
- Added manifest-based heartbeat registration through Memoria Bootstrapper.
