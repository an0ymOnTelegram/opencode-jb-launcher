# OpenCode JB Launcher

**Give each instruction set its own workspace. Start OpenCode with a few clicks.**

A lightweight launcher for **macOS and Windows** that lets you paste a prompt or select an existing `AGENTS.md`, name your workspace, and open it in OpenCode v2. No manual folder setup is required.

> Requires **OpenCode v2**, installed and configured separately. This project is an independent launcher and is not affiliated with OpenCode.

## Features

- **Two input methods:** paste your instructions or select an existing `AGENTS.md`.
- **Large prompt editor:** resize the window and scroll through long, formatted prompts using a fixed-width font.
- **Named workspaces:** choose a name such as `Writing JB` or `Coding JB`.
- **Formatting preservation:** retains Markdown, indentation, tabs, and blank lines. Pasted text is saved as UTF-8.
- **Automatic backups:** preserves an existing `AGENTS.md` before replacing it.
- **Version check:** verifies OpenCode v2 before opening the setup dialogs.

## Download and start

Download this repository using **Code → Download ZIP**, then **extract the entire archive** before running a launcher.

| Platform | Open this folder | Run this file |
| --- | --- | --- |
| macOS | `mac/` | `OpenCode-jb.command` |
| Windows | `windows/` | `OpenCode-jb.bat` |

Keep all files within your platform folder together, including the `jb-banner` subfolder. Individual launcher files are not standalone downloads.

### Requirements

- OpenCode **v2**, available to the launcher through `PATH` or one of its supported installation directories.
- A configured OpenCode model/provider. Any provider charges are separate from this launcher.
- macOS with its built-in zsh and AppleScript/JavaScript automation runtime, or Windows with Windows PowerShell and a graphical desktop.

Install and configure OpenCode using its [official website](https://opencode.ai). OpenCode v1 and Linux are not supported by this package.

### macOS

1. Open the extracted `mac` folder.
2. Double-click **OpenCode-jb.command**.
3. If execute permission was lost during download, open Terminal and type `chmod +x `, drag the `.command` file into Terminal, then press Enter.
4. Start the launcher again.

Downloaded scripts may be subject to macOS security checks. Review the source before allowing execution through your normal system security workflow.

### Windows

1. Open the extracted `windows` folder.
2. Double-click **OpenCode-jb.bat**.
3. Keep `OpenCode-jb.start` and the `jb-banner` folder beside it.

The `.bat` file starts the PowerShell helper. Its execution-policy option applies only to that process; it does not permanently change the Windows execution policy. Organization-managed restrictions may still prevent execution.

## Setup workflow

### 1. Verify OpenCode

The launcher checks that OpenCode is available and reports a v2 version. Missing, unsupported, or unreadable versions stop setup with an English installation message. Nothing is installed automatically.

### 2. Choose your instructions

- **Paste system prompt:** opens a large plain-text editor. Paste or edit your instructions, then choose **Continue**.
- **Select AGENTS.md:** opens a file picker. The selected filename must be `agents.md`, with any capitalization.

Pasted text becomes **project instructions in `AGENTS.md`**. It does not replace the model provider's system prompt or change the provider's rules. Rich-text fonts, colors, and embedded images are not part of this Markdown format.

### 3. Name the workspace

Enter a folder name, such as `Writing JB`. The default is `jb`.

The launcher uses your system's Desktop location and creates:

```text
Desktop/
└── Writing JB/
    └── AGENTS.md
```

Names must be 1–80 characters and cannot contain path separators, reserved filename characters, leading dots or whitespace, trailing dots or whitespace, or Windows device names such as `CON`. Invalid names prompt you to try again.

This names the **workspace folder**, not the individual OpenCode conversation title. An existing workspace can be reused.

### 4. Start OpenCode

The launcher saves or copies `AGENTS.md`, installs the banner plugin, and starts OpenCode in the chosen folder. Your original selected file is preserved. An existing destination file is backed up before replacement, unless you selected that exact file.

Canceling an input dialog, or submitting an empty prompt or workspace name, exits before workspace files are created.

## Persistent rainbow banner

The bundled plugin displays:

**Need a JB? [https://t.me/jailbreakall](https://t.me/jailbreakall)**

The text uses a moving rainbow gradient, and the link is underlined. Link activation depends on your terminal's hyperlink support.

The plugin is installed into:

```text
<OpenCode config>/plugins/jb-launcher-banner/tui.tsx
```

The configuration directory is discovered using `opencode debug paths`. Because installation is **global**, the banner loads in other workspaces and subsequent OpenCode starts as well. Restart already-running instances to load changes.

The plugin registers a home-screen banner and a banner above the session composer. It is a UI component: it does not send a chat prompt, make model requests, or open Telegram automatically. Animation timers are cleared when the component is removed.

### Remove the banner

1. Run `opencode debug paths` to locate the configuration directory.
2. Remove only `plugins/jb-launcher-banner` from that directory.
3. Restart OpenCode.

Running a launcher again reinstalls the banner. Existing differing plugin files are backed up before replacement. A matching older project-local copy is retired outside the plugin discovery directory to avoid duplication.

## Files and privacy

The launcher writes the selected instructions and backups into your named Desktop workspace, and installs the global banner plugin. It does not upload files to GitHub or Telegram and contains no bundled model credentials or personal instruction files.

OpenCode itself uses your existing configuration and provider settings. Your project instructions may be included in model requests when you use OpenCode. Review the instructions you paste or select before starting.

This repository deliberately includes the public Telegram link shown in the banner. Publishing or using this repository does not make that link anonymous.

## Repository layout

```text
.
├── README.md
├── LICENSE
├── mac/
│   ├── OpenCode-jb.command
│   ├── prompt-editor.js
│   └── jb-banner/
│       └── tui.tsx
└── windows/
    ├── OpenCode-jb.bat
    ├── OpenCode-jb.start
    └── jb-banner/
        └── tui.tsx
```

## Troubleshooting

| Problem | What to check |
| --- | --- |
| OpenCode not found | Install OpenCode v2 and make sure `opencode --version` works in your terminal. Restart the terminal after installation. |
| Version rejected | This launcher requires a recognizable v2 version. v1 is intentionally rejected. |
| Missing helper or plugin | Extract the complete repository ZIP and keep the platform folder intact. |
| Banner missing or still using old colors | Close and restart OpenCode after running the updated launcher. Check whether plugins have been disabled in your configuration. |
| Link is not clickable | Terminal hyperlink support and modifier-key behavior vary. The visible URL can also be copied manually. |
| Prompt looks too wide | Use the horizontal scrollbar or enlarge the editor. Long lines are not rewritten or wrapped into new lines in the saved file. |
| Windows script is blocked | Follow your organization's script-execution policy. The launcher cannot override managed restrictions. |

## Validation and limitations

Verified on macOS:

- zsh syntax and v2 version-detection cases;
- workspace-name validation;
- instruction copying and backup behavior;
- literal saving of multiline text, Unicode, tabs, and trailing blank lines;
- native editor construction and preservation of a long prompt;
- home-screen banner rendering in OpenCode **2.0.28**;
- changing colors on the same banner character across successive terminal frames.

**Windows execution has not yet been tested on a Windows machine.** The complete interactive editor workflow and session-composer placement still need manual validation. Compatibility with every future OpenCode version is not guaranteed.

## License

Released under the [MIT License](LICENSE). You may use, modify, and redistribute this launcher, including commercially, under that license. OpenCode and any model providers have their own licenses and terms.
