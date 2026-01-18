# GuildRecruiter Locales

This folder contains the language files for GuildRecruiter. Strings are provided via [AceLocale-3.0](https://www.wowace.com/projects/ace3/pages/api/ace-locale-3-0) and loaded by `Locales.xml`.

## How It Works
- `enUS.lua` is the default (fallback) locale. It passes `true` as the third parameter to `NewLocale`, so English strings will be used when a translation is missing in other locales.
- Other locale files (e.g., `deDE.lua`, `frFR.lua`) define the same keys without the `true` flag.
- `Locales.xml` defines the load order and includes each locale file.

## Conventions
- **Keys**: Use UPPER_SNAKE_CASE. Keep keys unique; do not reuse a key for different messages.
- **Grouping**: Group strings by feature/module using `#region` / `#endregion` comments.
- **Placeholders**: Use these literal placeholders where appropriate:
  - `PLAYERNAME`: replaced with the invited player's name
  - `GUILDNAME`: replaced with your guild name
  - `GUILDLINK`: replaced with a clickable guild link
- **Labels vs Messages**: Short UI labels (e.g., `ENABLED`, `DISABLED`) should remain concise. Longer sentences belong in message keys (e.g., `NOT_IN_A_GUILD`).

## Adding a New String
1. Add the key and English string to `enUS.lua` in a relevant `#region`.
2. Search for the key to avoid duplicates.
3. Add translations for the same key in the other locale files.
4. If the string includes placeholders, keep them identical across languages.

## Using Strings In Code
```lua
local addonName = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
-- Example: print a status
ns.code:fOut(L['TITLE']..' '..GR.versionOut..' '..L['ENABLED'])
-- Example: message with placeholders
local msg = L['DEFAULT_GUILD_WELCOME']:gsub('PLAYERNAME', player):gsub('GUILDNAME', guild)
```

## Tips
- Prefer creating a new, specific key instead of overloading an existing one.
- Keep a consistent tone and punctuation across strings.
- When removing or renaming keys, update usages in code.
