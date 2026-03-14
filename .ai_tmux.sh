#!/bin/bash

CONTEXT_LINES=20

# Capture last lines from tmux
context=$(tmux capture-pane -pS -$CONTEXT_LINES)

prompt_line=$(tmux capture-pane -p -S -5 -t "$target_pane" | tail -n1)

host=$(echo "$prompt_line" | sed -n 's/.*@\([^:]*\):.*/\1/p')
dir=$(echo "$prompt_line" | sed -n 's/.*:\([^#$]*\)[#$].*/\1/p')

host=${host:-$(hostname)}
dir=${dir:-$(pwd)}

# Prompt for task
printf "AI task: "
read -r task

# Build JSON safely using jq
json=$(jq -n \
  --arg model "qwen2.5-coder-7b-instruct" \
  --arg host "$host" \
  --arg dir "$dir" \
  --arg context "$context" \
  --arg task "$task" \
  '{
    model: $model,
    messages: [
      {role:"system", content:"You are a Linux assistant. Always return a single shell command. Never execute anything. Do not include explanations unless asked."},
      {role:"user", content:("Host: \($host)\nCurrent directory: \($dir)\nRecent terminal output:\n\($context)\nTask: \($task)")}
    ],
    temperature:0.2
  }')

# Send request
response=$(curl -s http://localhost:1234/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d "$json")

# Extract command
cmd=$(echo "$response" | jq -r '.choices[0].message.content // .choices[0].text')

# remove <think> blocks
cmd=$(echo "$cmd" | sed '/<think>/,/<\/think>/d')

# remove markdown code fences
cmd=$(echo "$cmd" | sed 's/```.*//g')

# keep first non-empty line
cmd=$(echo "$cmd" | sed '/^\s*$/d' | head -n1)

# trim whitespace
cmd=$(echo "$cmd" | xargs)

# Send to current tmux pane
tmux send-keys "$cmd"