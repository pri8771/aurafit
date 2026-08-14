#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "date"
require "digest"
require "yaml"

ROOT = File.expand_path("..", __dir__)
TASK_DIR = File.join(ROOT, "docs", "testflight", "tasks")
MIRROR_CSV = File.join(ROOT, "docs", "mirrors", "TESTFLIGHT_BACKLOG.csv")

EXPECTED_SUBTASKS = {
  "AURA-OPS-001" => 6,
  "AURA-OPS-009" => 7,
  "AURA-OPS-010" => 7,
  "AURA-OPS-011" => 6,
  "AURA-OPS-005" => 8,
  "AURA-OPS-012A" => 5,
  "AURA-QA-002" => 12,
  "AURA-QA-004" => 7,
  "AURA-QA-005" => 7,
  "AURA-MON-002" => 7,
  "AURA-MON-008" => 9,
  "AURA-QA-010" => 9,
  "AURA-MKT-004" => 7,
  "AURA-LEG-003" => 5,
  "AURA-LEG-004" => 6,
  "AURA-LEG-005" => 7,
  "AURA-OPS-014" => 6,
  "AURA-LEG-008" => 6,
  "AURA-OPS-012B" => 7,
  "AURA-OPS-013" => 6,
  "AURA-QA-006" => 7,
  "AURA-QA-007" => 9,
  "AURA-QA-008" => 5,
  "AURA-QA-009" => 5,
  "AURA-OPS-003" => 7,
  "AURA-OPS-007" => 6
}.freeze

REQUIRED_METADATA = %w[
  id title gate status ownerBoundary dependsOn evidence lastVerified parent
].freeze

REQUIRED_SECTIONS = [
  "## Task description",
  "## Preconditions and inputs",
  "## Subtasks",
  "## Acceptance criteria",
  "## Completion and evidence",
  "## Stop and reverification conditions"
].freeze

def fail_check(errors, message)
  errors << message
end

def parse_task(path, errors)
  content = File.read(path)
  match = content.match(/\A---\n(.*?)\n---\n/m)
  unless match
    fail_check(errors, "#{path}: missing YAML front matter")
    return
  end

  metadata = YAML.safe_load(match[1], permitted_classes: [Date], aliases: false)
  unless metadata.is_a?(Hash)
    fail_check(errors, "#{path}: front matter is not a map")
    return
  end

  REQUIRED_METADATA.each do |key|
    fail_check(errors, "#{path}: missing metadata #{key}") unless metadata.key?(key)
  end

  id = metadata["id"]
  unless EXPECTED_SUBTASKS.key?(id)
    fail_check(errors, "#{path}: unexpected task ID #{id.inspect}")
    return
  end

  expected_path = File.join(TASK_DIR, "#{id}.md")
  fail_check(errors, "#{path}: filename must be #{expected_path}") unless path == expected_path
  expected_evidence = "quality/evidence/testflight/#{id}/README.md"
  if metadata["evidence"] != expected_evidence
    fail_check(errors, "#{path}: evidence must be #{expected_evidence}")
  end

  REQUIRED_SECTIONS.each do |heading|
    fail_check(errors, "#{path}: missing section #{heading}") unless content.include?(heading)
  end

  task_description = content[/## Task description\n\n(.*?)(?=\n## )/m, 1].to_s.strip
  if task_description.length < 140
    fail_check(errors, "#{path}: task description is too short to answer what/why/change/how")
  end

  subtask_matches = content.to_enum(
    :scan,
    /^### (#{Regexp.escape(id)}-ST-(\d{2})) — (.+)$/
  ).map { Regexp.last_match }
  actual_numbers = subtask_matches.map { |item| item[2].to_i }
  expected_numbers = (1..EXPECTED_SUBTASKS.fetch(id)).to_a
  if actual_numbers != expected_numbers
    fail_check(
      errors,
      "#{path}: expected contiguous subtasks #{expected_numbers.inspect}, got #{actual_numbers.inspect}"
    )
  end

  subtask_matches.each_with_index do |item, index|
    start_offset = item.end(0)
    end_offset = subtask_matches[index + 1]&.begin(0) || content.index("\n## Acceptance criteria", start_offset)
    body = content[start_offset...end_offset].to_s
    description = body.split("\n**Execution**", 2).first.to_s.strip
    subtask_id = item[1]
    if description.length < 120
      fail_check(errors, "#{path}: #{subtask_id} description is too short")
    end
    fail_check(errors, "#{path}: #{subtask_id} missing Execution") unless body.include?("**Execution**")
    unless body.include?("**Expected result and evidence:**")
      fail_check(errors, "#{path}: #{subtask_id} missing expected result/evidence")
    end
    unless body.include?("**Failure handling:**")
      fail_check(errors, "#{path}: #{subtask_id} missing failure handling")
    end
  end

  {
    id: id,
    metadata: metadata,
    content: content,
    digest: Digest::SHA256.hexdigest(content),
    subtask_count: subtask_matches.length
  }
end

def load_tasks
  errors = []
  tasks = EXPECTED_SUBTASKS.keys.map do |id|
    path = File.join(TASK_DIR, "#{id}.md")
    unless File.file?(path)
      fail_check(errors, "#{path}: missing canonical task file")
      next
    end
    parse_task(path, errors)
  end.compact

  extra_files = Dir.glob(File.join(TASK_DIR, "AURA-*.md")).reject do |path|
    EXPECTED_SUBTASKS.key?(File.basename(path, ".md"))
  end
  extra_files.each { |path| fail_check(errors, "#{path}: unexpected canonical task file") }

  [tasks, errors]
end

def validate_mirror(tasks, errors)
  unless File.file?(MIRROR_CSV)
    fail_check(errors, "#{MIRROR_CSV}: missing")
    return
  end

  rows = CSV.read(MIRROR_CSV, headers: true)
  ids = rows.map { |row| row["External issue ID"] }
  expected_ids = EXPECTED_SUBTASKS.keys
  fail_check(errors, "#{MIRROR_CSV}: expected 26 rows") unless rows.length == expected_ids.length
  fail_check(errors, "#{MIRROR_CSV}: duplicate task IDs") unless ids.uniq.length == ids.length
  unless ids.sort == expected_ids.sort
    fail_check(errors, "#{MIRROR_CSV}: task IDs do not match canonical plans")
  end

  return unless rows.headers.include?("Canonical source")

  by_id = tasks.to_h { |task| [task[:id], task] }
  rows.each do |row|
    task = by_id[row["External issue ID"]]
    next unless task
    expected_source = "docs/testflight/tasks/#{task[:id]}.md"
    if row["Canonical source"] != expected_source
      fail_check(errors, "#{MIRROR_CSV}: #{task[:id]} source must be #{expected_source}")
    end
    if row["Subtask count"].to_i != task[:subtask_count]
      fail_check(
        errors,
        "#{MIRROR_CSV}: #{task[:id]} subtask count must be #{task[:subtask_count]}"
      )
    end
    if row["Gate"] != task[:metadata]["gate"]
      fail_check(errors, "#{MIRROR_CSV}: #{task[:id]} gate must match canonical metadata")
    end
    if row["Status"] != task[:metadata]["status"]
      fail_check(errors, "#{MIRROR_CSV}: #{task[:id]} status must match canonical metadata")
    end
  end
end

tasks, errors = load_tasks
validate_mirror(tasks, errors) if ARGV.include?("--mirror")

if errors.any?
  warn errors.join("\n")
  warn "TestFlight task-plan validation failed with #{errors.length} error(s)."
  exit 1
end

puts "Validated #{tasks.length} task plans and #{tasks.sum { |task| task[:subtask_count] }} subtasks."
tasks.each do |task|
  puts "#{task[:id]} #{task[:digest][0, 12]} #{task[:subtask_count]}"
end
