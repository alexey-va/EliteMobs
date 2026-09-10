# Guild introduction and first class

Casus offers `ag_welcome_quest_1.yml`, followed by
`ag_adventurer_training.yml`. The latter requires the existing completion marker
`elitequest.ag_welcome_quest_1.yml`. Both use the normal one-time quest lockout.
The existing administrative quest bypass still bypasses prerequisite and lockout
checks.

## Guild NPC coverage

The source-defined guild NPCs were compared with the introduction's objectives.
Dungeon destinations and the Goblin Kingdom patrol are excluded. The story-mode
quest giver is explicitly included.

| NPCs | Introduction decision |
| --- | --- |
| Hermes, Bartley, Greg, Charles, Gillian, Qel'Thuzad, Eden, Reggie, Kelly, Grog, Ulfric | Retain the existing eleven visits. |
| Robin | Add ammunition shop introduction for bows and crossbows. |
| Scotty | Add Elite Scroll conversion introduction. |
| Gladius | Add Wood League arena introduction. |
| Manager Wallitz | Add the requested story-mode quest-chain introduction. |
| Rowan, Adventurer Instructor | Visit in the follow-up, after the tour. |
| Aldric, Ragna, Rowan the Ranger, Seren, Orin | Defer other class instructors; Adventurer is the starter prerequisite. |
| The Baron, Vincent, Ace Morgan, Lucky Pete, Spinner Sam | Optional gambling services, not required onboarding. |
| Casus | Gives and receives the quests. |
| Saint Nick | Disabled seasonal NPC, excluded from the required tour. |

The first quest also requires one kill of `training_dummy_lv1.yml`. Its identity,
level and guild spawn were checked against the locally retained guild package.
The package itself is unchanged. Existing first-quest rewards are retained.

## Adventurer training

The follow-up requires dialogue with `class_trainer_adventurer.yml` and the
actual Adventurer unlock. The dialogue distinguishes the Adventurer instructor
from the Ranger instructor, who is also named Rowan. Players then use Rowan's
normal one-coin class trial and return to Casus.

`CLASS_UNLOCK` is an ordinary quest objective. Its `class` field names the class
form; `filename` names the NPC used for tracking. It reads the existing class
profile, refreshes on acceptance, successful trial completion, profile loading
and NPC interaction, and checks the profile again at turn-in. Already-unlocked
classes count. Missing class data cannot grant completion, and invalid objective
definitions remain blocked rather than being omitted. It adds no unlock path,
database table or background task.

## Fixed rewards

Four diamond armor pieces and ten weapons use ordinary `UNIQUE`, `FIXED`,
level-1 custom items named `ag_adventurer_<item>.yml`. Each is awarded once with
100% chance. They do not enter random drops or shops and do not scale to the
player's level. Inventory overflow follows the existing quest-loot delivery.

The authored enchantments represent possible rolls from the bundled HARD/BOSS
profiles using their 50% native-enchantment budget. Each chosen enchantment is
within that family's ceiling; the armor uses the DPS family. These are fixed
authored stats, not a live dependency on edits to ClassLootSettings.

| Item | Fixed enchantments |
| --- | --- |
| Helmet, chestplate | Sharpness IV, Protection II, Unbreaking II |
| Leggings | Sharpness IV, Protection II, Unbreaking I |
| Boots | Sharpness IV, Protection II, Unbreaking II, Feather Falling II |
| Sword | Sharpness IV, Unbreaking II, Fire Aspect I |
| Axe, mace, spear | Sharpness III, Unbreaking II, Fire Aspect I |
| Bow | Power III, Unbreaking I, Flame I, Infinity I |
| Crossbow | Power III, Unbreaking II, Quick Charge II, Piercing I |
| Trident | Sharpness IV, Unbreaking II, Loyalty I |
| Scythe | Sharpness III, Unbreaking III, Fire Aspect I |
| Staff | Power III, Unbreaking II, Blast Radius II, Ignition II |
| Wand | Power III, Unbreaking II, Multicast II |

Staff and wand use the existing FMM default weapon IDs. The complete reward set
requires those models and a server version supporting mace and spear materials.

## Verification and deployment limits

The changed Java sources compile against the existing EliteMobs jar and compile
dependencies. A static audit confirmed sixteen introduction targets, fourteen
reward definitions, their HARD/BOSS enchantment ceilings and the follow-up's
completion prerequisite.

A full `shadowJar` build is blocked by the unrelated FMM API mismatch in the
current weapon changes. The Maven dependency lacks `MagicWeaponModifiers`; the
existing locally built FMM jar lacks newer `isWeapon`, `applyWeaponData` and
`weaponKind` methods. No replacement deployable jar or live gameplay result is
claimed. No test suite or server was run.

These are plugin defaults. Existing administrator-authored NPC and quest YAML
is not migrated or overwritten by this change. Existing quest instances keep
their saved objectives; new defaults require the appropriate NPC/quest config
update before accepting new quests on an existing installation.
