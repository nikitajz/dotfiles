# Karabiner-Elements Configuration

This configuration uses [GokuRakuJoudo](https://github.com/yqrashawn/GokuRakuJoudo) to manage Karabiner-Elements in a concise EDN format (267 lines vs 1886 lines JSON).

## Quick Start

```bash
# Install Goku
brew install yqrashawn/goku/goku

# Generate karabiner.json from karabiner.edn
goku

# Watch for changes (auto-regenerate)
gokuw
```

The EDN file should be at `~/.config/karabiner.edn`.

## Hotkeys

### Fn + F-keys → Standard Function Keys
(except in IDEs: Atom, iTerm2, PyCharm, Sublime, VSCode, Zed, Cursor, Xcode)

- `Fn+F1` → F1, `Fn+F2` → F2, etc.

### Caps Lock → Hyper Key / Escape
- **Tap**: Escape
- **Hold**: Hyper modifier (⌘⌃⌥⇧)
- `Hyper+Escape` → **Toggle Caps Lock** (on/off)
- `Hyper+Space` → Language switch
- `Hyper+Cmd+Space` → Emoji picker

### Right Shift → herdr prefix / Shift (built-in keyboard only)
- **Tap**: Ctrl+B (herdr prefix)
- **Hold + key**: normal Shift
- Restricted to the built-in MacBook keyboard (`is_built_in_keyboard`); external keyboards are unaffected

### j+k → Escape
- Press `j` and `k` simultaneously

### Hyper+Cmd Navigation
- `Hyper+Cmd+J` → Left
- `Hyper+Cmd+L` → Right
- `Hyper+Cmd+I` → Up
- `Hyper+Cmd+K` → Down
- `Hyper+Cmd+U` → Page Up
- `Hyper+Cmd+O` → Page Down
- `Hyper+Shift+;` → Backspace
- `Hyper+'` → Escape

### Hyper + Key → Launch Applications
- `Hyper+F` → Finder
- `Hyper+A` → Arc
- `Hyper+S` → Spotify
- `Hyper+W` → Chrome
- `Hyper+E` → Chrome (meet.google.com)
- `Hyper+R` → Preview
- `Hyper+Y` → Msty
- `Hyper+I` → Claude
- `Hyper+H` → Ghostty
- `Hyper+J` → ChatGPT
- `Hyper+T` → iTerm2
- `Hyper+U` → Cursor
- `Hyper+O` → Orion
- `Hyper+Z` → Zed
- `Hyper+X` → Notion
- `Hyper+C` → PyCharm
- `Hyper+V` → VSCode
- `Hyper+N` → Telegram
- `Hyper+M` → Slack

### Desktop Switching
- `Ctrl+Opt+U` → Previous desktop
- `Ctrl+Opt+O` → Next desktop

## Resources

- [Karabiner God Mode](https://medium.com/@nikitavoloboev/karabiner-god-mode-7407a5ddc8f6) - Nikita Voloboev's approach to keyboard mastery
- [Hacking Your Keyboard](https://kau.sh/blog/hacking-your-keyboard/) - Comprehensive Karabiner+Goku guide
- [GokuRakuJoudo Tutorial](https://github.com/yqrashawn/GokuRakuJoudo/blob/master/tutorial.md) - Official Goku documentation
- [Karabiner-Elements Docs](https://karabiner-elements.pqrs.org/docs/)

## Files

- `karabiner.edn` - Source configuration (edit this)
- `CONVERSION_ANALYSIS.md` - Detailed technical analysis
