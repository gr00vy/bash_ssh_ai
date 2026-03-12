#!/bin/bash

CONTEXT_LINES=20

# Capture last lines from tmux
context=$(tmux capture-pane -pS -$CONTEXT_LINES)

cwd=$(pwd)
host=$(hostname)

# Prompt for task
printf "AI task: "
read -r task

# Build JSON safely using jq
json=$(jq -n \
  --arg model "qwen2.5-coder-7b-instruct" \
  --arg host "$host" \
  --arg cwd "$cwd" \
  --arg context "$context" \
  --arg task "$task" \
  '{
    model: $model,
    messages: [
      {role:"system", content:"You are a Linux assistant. Always return a single shell command. Never execute anything. Do not include explanations unless asked."},
      {role:"user", content:("Host: \($host)\nCurrent directory: \($cwd)\nRecent terminal output:\n\($context)\nTask: \($task)")}
    ],
    temperature:0.2
  }')

# Send request
response=$(curl -s http://localhost:1234/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d "$json")

# Extract command
cmd=$(echo "$response" | jq -r '.choices[0].message.content // .choices[0].text' | tr -d '\n')

# Send to current tmux pane
tmux send-keys "$cmd"