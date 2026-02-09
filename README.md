# bfm.nvim

Neovim plugin for [Birdcar Flavored Markdown](https://github.com/birdcar/markdown-spec) -- context-aware completions, task state cycling, date insertion, folding, and visual concealing, all driven by tree-sitter.

BFM extends standard markdown with directives (`@callout`, `@embed`), inline modifiers (`//due:2025-03-15`, `//every:weekly`), extended task states (`[ ]`, `[>]`, `[!]`, etc.), and `@mentions`. This plugin makes writing BFM in Neovim feel native: you get completions that know whether you're typing a directive name, a modifier key, a modifier value, or a mention, and the editing tools understand the structure of your document.

## Requirements

- Neovim >= 0.10
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [tree-sitter-bfm](https://github.com/birdcar/tree-sitter-bfm) grammar (provides the `bfm` and `bfm_inline` parsers)
- [blink.cmp](https://github.com/Saghen/blink.cmp) for completions
- [LuaSnip](https://github.com/L3MON4D3/LuaSnip) (optional, for snippet expansion)

## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "birdcar/bfm.nvim",
  ft = "markdown",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {},
}
```

### Registering the blink.cmp source

bfm.nvim provides a completion source for [blink.cmp](https://github.com/Saghen/blink.cmp), not nvim-cmp. Register it in your blink.cmp config:

```lua
{
  "saghen/blink.cmp",
  opts = {
    sources = {
      default = { "lsp", "path", "snippets", "buffer", "bfm" },
      providers = {
        bfm = {
          name = "bfm",
          module = "bfm.source",
          score_offset = 100,
          enabled = function()
            return vim.bo.filetype == "markdown"
          end,
        },
      },
    },
  },
}
```

### Installing the tree-sitter grammar

You need the BFM tree-sitter parsers registered with nvim-treesitter. Add the parser definitions to your treesitter config:

```lua
{
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
    parser_config.bfm = {
      install_info = {
        url = "https://github.com/birdcar/tree-sitter-bfm",
        files = { "src/parser.c" },
        branch = "main",
      },
    }
    parser_config.bfm_inline = {
      install_info = {
        url = "https://github.com/birdcar/tree-sitter-bfm",
        files = { "src/parser.c" },
        branch = "inline",
      },
    }
  end,
}
```

Then run `:TSInstall bfm bfm_inline`.

## What it does

### Context-aware completions

The completion source uses tree-sitter and regex fallbacks to figure out what you're typing and offers the right completions for each context:

- Type `@` at the start of a line and you get directive names (`callout`, `embed`) with full snippet bodies.
- Inside a directive's opening tag, you get parameter completions -- `type=info`, `type=warning`, `title=""`, etc.
- Type `//` anywhere and you get modifier keys (`due`, `around`, `after`, `every`, `cron`, `hard`, `wait`). After the colon, you get value completions: dates for temporal modifiers, recurrence options like `daily`, `weekly`, `weekdays`, or day names for `//every`.
- Type `@` mid-line (not at the start) and you get mention completions pulled from registered providers.

### Task state cycling

BFM defines seven task states: open `[ ]`, done `[x]`, scheduled `[>]`, migrated `[<]`, irrelevant `[-]`, event `[o]`, and priority `[!]`. The cycling commands step through these in order, forward or backward. Works in visual mode to cycle multiple tasks at once.

### Date insertion

The `insert_date` command is context-aware. If your cursor is right after a modifier colon (like `//due:`), it inserts today's date there. If you're on a task line that doesn't have a `//due:` modifier, it appends `//due:2025-03-15` to the end of the line. Otherwise it just inserts the date at the cursor position.

### Folding

Directive blocks fold using tree-sitter's fold expression. The fold text shows the directive name, its parameters, and a line count -- so a folded callout reads something like `@callout type=info title="Note" [5 lines]` instead of a generic fold marker.

### Concealing

Task markers like `[x]` get replaced with icons via extmarks. Directive close tags (`@endcallout`) render as a thin horizontal rule. Callout directives with a `type=` parameter show their type icon at the end of the line. All icons update live as you edit.

### Highlights

Default highlight groups link to standard treesitter captures so task states are visually distinct out of the box. Each state has its own group that you can override.

## Configuration

Here is the full default configuration:

```lua
require("bfm").setup({
  completion = {
    enabled = true,
    trigger_characters = { "@", "/" },
  },
  mentions = {
    git = true,          -- pull authors from git log
    file = true,         -- read .bfm-mentions file
    cache_ttl = 300,     -- git mention cache lifetime in seconds
  },
  snippets = {
    enabled = true,      -- register LuaSnip snippets (if LuaSnip is installed)
  },
  highlights = {
    enabled = true,      -- set up default highlight group links
  },
  cycling = {
    order = { " ", "x", ">", "<", "-", "o", "!" },
  },
  folding = {
    enabled = true,      -- tree-sitter folding for directive blocks
  },
  conceal = {
    enabled = true,
    icons = {},          -- override default icons (see below)
  },
  keymaps = {
    cycle_forward = "<leader>tt",
    cycle_backward = "<leader>tT",
    insert_date = "<leader>td",
  },
})
```

Set any keymap to `false` to disable it. The `cycling.order` table controls which states the cycling commands step through and in what order -- remove states or reorder them to fit your workflow.

### Conceal icons

The default icons for task states and callout types:

```lua
-- Task states
{
  [" "] = "○",   -- open
  ["x"] = "✓",   -- done
  [">"] = "⏩",  -- scheduled
  ["<"] = "⏪",  -- migrated
  ["-"] = "✕",   -- irrelevant
  ["o"] = "◉",   -- event
  ["!"] = "⚠",   -- priority
}

-- Callout types (shown at end of line)
{
  info    = "ℹ",
  warning = "⚠",
  danger  = "✘",
  success = "✓",
  note    = "✎",
}
```

Override any of these through `conceal.icons`:

```lua
require("bfm").setup({
  conceal = {
    icons = {
      task = { ["x"] = "✔" },
      callout_type = { info = "💡" },
    },
  },
})
```

### Highlight groups

All highlight groups are set with `default = true`, so your colorscheme or manual `nvim_set_hl` calls take precedence.

| Group | Default link | Task state |
|---|---|---|
| `@bfm.task.open` | `@comment` | `[ ]` |
| `@bfm.task.done` | `@string` | `[x]` |
| `@bfm.task.scheduled` | `@type` | `[>]` |
| `@bfm.task.migrated` | `@constant` | `[<]` |
| `@bfm.task.irrelevant` | `@comment.note` | `[-]` |
| `@bfm.task.event` | `@function` | `[o]` |
| `@bfm.task.priority` | `@exception` | `[!]` |
| `@bfm.mention` | `@tag` | -- |

## Keymaps

All keymaps are buffer-local to markdown files and support both normal and visual mode where applicable.

| Action | Default | Modes | Description |
|---|---|---|---|
| Cycle forward | `<leader>tt` | n, v | Step task state forward through the cycle order |
| Cycle backward | `<leader>tT` | n, v | Step task state backward through the cycle order |
| Insert date | `<leader>td` | n | Insert today's date (context-aware placement) |

## Mention providers

bfm.nvim ships with two built-in mention providers and an API for adding your own.

### Git log provider

Enabled by default (`mentions.git = true`). Runs `git log --format=%aN --all` asynchronously, deduplicates authors, and converts names to mention IDs by lowercasing and replacing spaces with dots. So "Nick Birdwell" becomes `nick.birdwell`. Results are cached for `cache_ttl` seconds (default 300).

### File provider

Enabled by default (`mentions.file = true`). Reads mention IDs from two locations:

- `<cwd>/.bfm-mentions` -- project-specific mentions
- `~/.config/bfm/mentions` -- global mentions

One ID per line. Lines starting with `#` are ignored. Example `.bfm-mentions`:

```
# Team leads
nick.birdwell
jane.doe
# Stakeholders
bob.smith
```

### Custom providers

Register a custom provider with a function that takes a callback:

```lua
require("bfm").register_mention_source(function(callback)
  -- callback expects a list of { label = string, detail = string }
  callback({
    { label = "alice.jones", detail = "Alice Jones (custom)" },
    { label = "ci.bot", detail = "CI Bot (custom)" },
  })
end)
```

The callback pattern supports both synchronous and async sources. All registered providers run in parallel during mention completion, and results are deduplicated by label.

## Snippets

bfm.nvim includes 6 snippets available in two formats:

| Prefix | Description | Format |
|---|---|---|
| `@callout` | Full callout directive with type and title parameters | LuaSnip + VSCode |
| `@embed` | Embed directive with URL placeholder | LuaSnip + VSCode |
| `task` | Task item with state choice | LuaSnip + VSCode |
| `//due` | Due date modifier with today's date | LuaSnip + VSCode |
| `//every` | Recurrence modifier with frequency choices | LuaSnip + VSCode |
| `//cron` | Cron schedule modifier | LuaSnip + VSCode |

The VSCode-format snippets (`snippets/markdown.json`) are automatically added to the runtime path for any snippet engine that reads VSCode snippet files (including blink.cmp's built-in snippet source). The LuaSnip versions are registered when `snippets.enabled = true` and LuaSnip is installed.

## Health check

Run `:checkhealth bfm` to verify that dependencies are installed and parsers are available. It checks for nvim-treesitter, the BFM tree-sitter parsers, nvim-cmp (legacy), and LuaSnip.

## Tree-sitter injection

bfm.nvim includes injection queries that layer the BFM parsers on top of standard markdown tree-sitter. The `bfm` parser handles block-level structures (directives) injected into markdown `section` nodes, and `bfm_inline` handles inline structures (task markers, modifiers, mentions) injected into `inline` nodes. This is what makes the context-aware completions and folding work -- the tree-sitter tree contains BFM node types alongside the standard markdown ones.

## Related projects

- [Birdcar Flavored Markdown spec](https://github.com/birdcar/markdown-spec) -- the full BFM specification
- [tree-sitter-bfm](https://github.com/birdcar/tree-sitter-bfm) -- tree-sitter grammar for BFM syntax

## License

MIT -- see [LICENSE](LICENSE) for details.
