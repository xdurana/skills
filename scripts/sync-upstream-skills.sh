#!/bin/sh

set -eu

state_directory=".upstream-skill-sources"
mkdir -p "$state_directory"

temporary_directory="$(mktemp -d)"
matt_workspace="$temporary_directory/matt-workspace"
matt_state="$state_directory/mattpocock.txt"
matt_current_state="$temporary_directory/matt-current-state"
matt_skill_files="$temporary_directory/matt-skill-files"
mkdir -p "$matt_workspace"

cleanup() {
  rm -rf "$temporary_directory"
}
trap cleanup EXIT

(
  cd "$matt_workspace"
  npx --yes skills@latest add mattpocock/skills --agent opencode --copy --yes \
    --skill ask-matt \
    --skill code-review \
    --skill codebase-design \
    --skill diagnosing-bugs \
    --skill domain-modeling \
    --skill grill-with-docs \
    --skill implement \
    --skill improve-codebase-architecture \
    --skill prototype \
    --skill research \
    --skill resolving-merge-conflicts \
    --skill setup-matt-pocock-skills \
    --skill tdd \
    --skill to-spec \
    --skill to-tickets \
    --skill triage \
    --skill wayfinder \
    --skill wizard \
    --skill grill-me \
    --skill grilling \
    --skill handoff \
    --skill teach \
    --skill to-questionnaire \
    --skill wait-what \
    --skill writing-for-agents
)

find "$matt_workspace/.agents/skills" -mindepth 2 -maxdepth 2 -type f -name SKILL.md -print > "$matt_skill_files"
: > "$matt_current_state"
while IFS= read -r skill_file; do
  skill_directory="$(dirname "$skill_file")"
  skill_name="$(basename "$skill_directory")"
  destination_directory="$skill_name"
  rm -rf "$destination_directory"
  mkdir -p "$destination_directory"
  cp -R "$skill_directory/." "$destination_directory/"
  printf '%s\n' "$destination_directory" >> "$matt_current_state"
done < "$matt_skill_files"
sort -u "$matt_current_state" -o "$matt_current_state"

if [ -f "$matt_state" ]; then
  while IFS= read -r previous_directory; do
    if ! grep -Fxq "$previous_directory" "$matt_current_state"; then
      rm -rf "$previous_directory"
    fi
  done < "$matt_state"
fi

mv "$matt_current_state" "$matt_state"

sources="$temporary_directory/sources"
jq -c '.[]' upstream-skill-sources.json > "$sources"
while IFS= read -r source; do
  name="$(printf '%s' "$source" | jq -r '.name')"
  repository="$(printf '%s' "$source" | jq -r '.repository')"
  source_path="$(printf '%s' "$source" | jq -r '.sourcePath')"
  destination_path="$(printf '%s' "$source" | jq -r '.destinationPath')"
  checkout="$temporary_directory/$name-checkout"
  current_state="$temporary_directory/$name-current-state"
  skill_files="$temporary_directory/$name-skill-files"
  previous_state="$state_directory/$name.txt"

  git clone --depth 1 "$repository" "$checkout"
  source_directory="$checkout/$source_path"
  test -d "$source_directory"

  find "$source_directory" -type f -name SKILL.md -print > "$skill_files"
  : > "$current_state"
  while IFS= read -r skill_file; do
    skill_source_directory="$(dirname "$skill_file")"
    relative_directory="${skill_source_directory#"$source_directory"/}"
    if [ "$skill_source_directory" = "$source_directory" ]; then
      skill_destination_directory="$destination_path"
    else
      skill_destination_directory="$destination_path/$relative_directory"
    fi
    rm -rf "$skill_destination_directory"
    mkdir -p "$skill_destination_directory"
    cp -R "$skill_source_directory/." "$skill_destination_directory/"
    printf '%s\n' "$skill_destination_directory" >> "$current_state"
  done < "$skill_files"
  sort -u "$current_state" -o "$current_state"

  if [ -f "$previous_state" ]; then
    while IFS= read -r previous_directory; do
      if ! grep -Fxq "$previous_directory" "$current_state"; then
        rm -rf "$previous_directory"
      fi
    done < "$previous_state"
  fi

  mv "$current_state" "$previous_state"
done < "$sources"
