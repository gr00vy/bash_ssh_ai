# bash_ssh_ai

A small utility that adds an **AI-powered command generator to tmux**, designed for working with **SSH sessions**.

It allows you to describe a task in natural language and have an AI model generate the appropriate shell command, which is then inserted into your terminal for review before execution.

Unlike many AI terminal tools, this solution:

* Runs **entirely locally**
* Requires **no software on remote servers**
* Works seamlessly with **SSH sessions**
* Uses a **local LLM via LM Studio**

---

## Features

* Generate Linux shell commands from natural language
* Works inside **tmux**
* Compatible with **SSH sessions**
* Commands are **inserted into the prompt but not executed automatically**
* Uses **local LLMs** through LM Studio
* Includes **terminal context** (recent output) to improve command accuracy

Example workflow:

```
Ctrl + B g
AI task: restart pm2 application
```

The generated command appears in your terminal:

```
pm2 restart app-name
```

You review it and press **Enter** if it's correct.

---

## Requirements

The following software must be installed:

* **tmux**
* **curl**
* **jq**
* **LM Studio**

Example installation on Ubuntu:
```
sudo apt install tmux curl jq
```

LM Studio must be running with:

* **Local server enabled**
* A loaded language model (for example `openai/gpt-oss-20b`)

Default API endpoint used:

```
http://localhost:1234/v1/chat/completions
```

---

## Installation

Clone the repository:

```
git clone https://github.com/gr00vy/bash_ssh_ai.git
cd bash_ssh_ai
```

Copy the configuration files:

```
cp .tmux.conf ~/.tmux.conf
cp .ai_tmux.sh ~/.ai_tmux.sh
chmod +x ~/.ai_tmux.sh
```

Reload tmux configuration:

```
tmux source-file ~/.tmux.conf
```

---

## Usage

Start a tmux session:

```
tmux
```

Open an SSH session if needed:

```
ssh user@server
```

Press:

```
Ctrl + B g
```

In tmux, keybindings normally work as a prefix sequence, not a chord. The default prefix is Ctrl+B.

So the correct sequence is:

Press Ctrl+B
release
then press g

You do NOT hold Ctrl+B while pressing g.

A popup will appear asking for a task:

```
AI task:
```

Example:

```
show largest files in /var
```

The AI generates a command and inserts it into your terminal.

You can review and run it manually.

---

## How it works

1. `tmux` captures recent terminal output for context
2. The script sends the prompt and context to **LM Studio**
3. The local LLM generates a shell command
4. tmux inserts the command into the original pane

No commands are executed automatically.

---

## Security

This tool **does not execute commands automatically**.

Always review generated commands before running them.

Since the model runs locally through LM Studio, **no data is sent to external services**.

---

## License

MIT License
