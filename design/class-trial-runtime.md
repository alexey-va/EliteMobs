# Class trial ownership

The current implementation uses ordinary custom-boss YAML and ordinary Lua powers.
The source contract and editable example are in
[the Guild content README](../content/adventurers_guild/README.md).

The old private trial runtime, actor registry, projectile receipts, damage budgets,
pose/equipment adapters and dialogue dispatcher were removed. Do not restore those
mechanisms or relocate them into a shared Lua encounter framework. No migration or
compatibility reader exists for their unreleased configuration fields.

## Responsibilities

- `ClassTrialDefinition` resolves the enabled ordinary boss associated with a class.
- `ClassChallengeInstance` owns admission, fees/refunds, the existing exclusive arena
  reservation, completion/progression and return to the player's earlier location.
  It observes whether the instructor and its normal Lua powers remain available.
- The normal boss loader creates the instructor and attaches its `powers:` entries.
- `LuaElitePower` and MagmaCore `ScriptInstance` own hook dispatch, tasks and closure.
- Each power owns its authored mechanics and messages. Shared includes implement
  specific reused abilities or small drawing helpers, not another encounter engine.
- Normal parent reinforcement ownership removes companions, props, mounts and
  tracked projectiles. A timed lifetime alone is insufficient for early exit.

The only added Lua operations approved for this work were the ordinary
reinforcement-damage hook and already-normalized damage transfer. Mechanics that
needed the rejected runtime were redesigned around existing operations. Any further
API request needs a concrete reusable mechanic that existing features cannot
reasonably express, followed by approval before implementation.

## Acceptance still required

Compilation is source evidence. Gameplay and balance remain unverified until the
approved test or manual run actually occurs. Cover every relevant exit: victory,
defeat, disconnect, explicit leave, reload, missing content, script failure and
cancelled admission. Check fees/refunds and class activation exactly once, return
location, arena release, and removal of all owned entities and scheduled effects.

Use a real client to inspect aim locking, native arrows hitting walls and intervening
entities, reachable navigation, mount teardown, guard directions, interrupt windows,
finite sustain, telegraphs and UI. Transfer tests must distinguish issuing a transfer
from its recipient accepting damage. Do not claim final damage conservation across
later third-party handlers.

Each instructor's YAML and Lua are the final mechanical specification. The older
family documents preserve design intent only, and include mechanics deliberately
changed during the ordinary-power conversion.
