# Changelog

## Experimental heartbeat discovery

- Added manifest-based heartbeat registration through Memoria Bootstrapper using `m_calm_hb.ncs`.

## 1.2.7

- Restored detailed LOS probes exclusively for targeted manual diagnostics.
- Runs targeted diagnostics in the activating player's area context so `LineOfSightVector` produces valid results.
- Periodic assignment diagnostics retain only the concise object-versus-lock LOS values.

## 1.2.6

- Fixed false-negative LOS for closed doors whose geometry occludes their own object pivot.
- Lock visibility now accepts either normal object LOS or LOS to a point 0.5 or 1 metre in front of the lock toward the player; intervening geometry still blocks the check.
- Removed the temporary multi-probe diagnostic output and retained concise object-versus-lock LOS values.

## 1.2.5

- Added LOS probes to the target diagnostics: object LOS, the door-centre vector and three points shifted from the door centre toward the player.
- Reports the probe vectors and door facing to distinguish self-occlusion by door geometry from unrelated area geometry.

## 1.2.4

- Corrected the periodic eligible-visible-lock count, which previously displayed the unfiltered radius-cache size.
- Replaced the long aggregate target-rejection line with unambiguous per-lock state, visibility and associate-pair diagnostics.

## 1.2.3

- Corrected the debug-only available-locksmith count so it no longer requires an already assignable target.
- Added separate trained, available and assignable counts to assignment diagnostics.
- When no assignment is possible, lists every same-area ally with its rejection reasons and gives target-filter totals for each otherwise available locksmith.

## 1.2.2

- Removed the fixed ten-second failed-target cooldown.
- Rechecks a failed target on the next LOS/task dispatcher cycle, which defaults to one second and remains configurable through the existing interval option.
- Keeps temporarily failed locks in the fast cache so a registry heartbeat cannot postpone that retry by up to six seconds.
- Revalidates LOS and route safety for active tasks on every configured dispatcher cycle, not only during initial assignment.

## 1.2.1

- Changed targeted-power use on an object from opening settings to printing raw object state, every M_CALM filter result, and per-group-member unlock diagnostics to chat.
- Kept targeted-power use on the ground as the settings shortcut.

## 1.2.0

- Removed automatic Detect because NWScript cannot suppress the engine's overhead feedback when `SetActionMode` toggles Detect; old M_CALM-owned Detect state is cleared once when a save is upgraded.
- Removed the stock door-action prefilter and the door usable-flag requirement so every closed pickable door, including plot doors, is eligible.
- Prioritizes the globally nearest available associate-to-lock pair before locksmith skill distribution.
- Rejects direct routes containing a closed door or another detected active trap, observes the engine's blocking-door result, and retains bounded stall retries for paths that cannot be queried ahead of time.
- Releases a M_CALM task when its action is manually cancelled or replaced, preventing the dispatcher from fighting direct familiar control.
- Labels the line-of-sight setting with the `LOS` abbreviation in every language.

## 1.1.3

- Expanded automatic Detect from one directly controlled creature to the bounded registry of the player and all controlled associates with trained Search.
- Tracks movement, stationary time and M_CALM-owned Detect mode independently for every eligible creature.
- Preserves manually enabled Search/Detect and migrates the previous single-creature saved state safely.

## 1.1.2

- Included plot doors in automatic lockpicking because the plot flag prevents destruction rather than lockpicking.
- Removed the premature line-of-sight filter from the six-second radius scan; cached doors and containers now use the configured fast LOS dispatcher.

## 1.1.1

- Hardened all cross-dispatcher object boundaries against destroyed objects and area transitions.
- Revalidates the actor, target, owner and shared area immediately before queuing unlock or retry actions.
- Invalidates reservations when an assignee dies, disappears or leaves the target's area.
- Clears automatic Detect ownership immediately when the controlled creature becomes invalid or changes area.
- Ignores stale cached party members from other areas in combat and action checks.

## 1.1.0

- Replaced the three-second full candidate pass with a six-second bounded registry and configurable cached-object dispatcher, defaulting to one second.
- Changed the default search radius to 15 metres and cached only associates with trained Open Lock.
- Added tagged grey lock highlighting with automatic cleanup.
- Added automatic Detect for the directly controlled trained Search character, with a 0.2-second movement dispatcher and one-second stationary delay.
- Added a second stock unique power and a localized NUI settings window with validated decimal fields.
- Persisted all settings on the player character and disabled diagnostic output by default.
- Split registry, lock, movement and scheduler work into independent scripts to keep execution limits isolated.

## 1.0.4

- Displays a localized floating claim above a companion whenever M_CALM assigns a new lock.
- Keeps the claim out of the chat window to avoid log spam.

## 1.0.3

- Runs the safety and automatic-lock managers every three seconds by scheduling one interim pass between stock player heartbeats.
- Adds an action-completion callback after each unlock attempt, allowing the next eligible lock to be assigned immediately after a successful unlock.

## 1.0.2

- Restores an associate's normal follow behavior after a M_CALM unlock task finishes or is cancelled.
- Clears the completed unlock action so familiars do not remain frozen beside an unlocked object.
- Preserves Stand Ground and the associate's existing combat behavior settings.

## 1.0.1

- Replaced repeated full-area creature scans with a bounded recursive associate cache.
- Added a single-pass cache for visible locked objects to stay below the NWScript instruction limit in large campaign areas.
- Allowed lockpicking on trapped containers while continuing to preserve active trap-disarming actions.
- Added a one-shot scan report after enabling the mode.
- Replaced M_CALM's private `OnActivateItem` dispatcher with an extension of M_LSE's ESI.

## 1.0.0

- Added the always-on anti-bashing safety manager.
- Added automatic, capacity-aware lock assignment for all non-player-controlled associates.
- Added combat, possession and manual-action guards.
- Added path progress monitoring, bounded retries and task cleanup.
- Added a unique-power inventory toggle without custom 2DA rows.
- Added Russian, English, French, Italian, German and Spanish text.
- Added separate M_LSE-compatible and standalone heartbeat bootstraps.
