#!/usr/bin/env ruby
# frozen_string_literal: true

# Rename files and directories so paths agree with the constants and requires
# that `apply` rewrote.
#
# Dry-run by default; `--write` performs the renames. Idempotent: a second run
# over an already-renamed tree reports zero changes.
#
#   script/rebrand/rename_paths            # dry run
#   script/rebrand/rename_paths --write    # rename
#
# Ordering rules, all of which matter:
#
#   * Directories are collected from the deepest path upwards, so a child is
#     renamed before its parent. Renaming the parent first would invalidate
#     every child path we already computed.
#   * Only the *basename* of each segment is rewritten. Rewriting whole paths
#     would let a mapping row consume a separator.
#   * A rename that would collide with an existing path aborts the run unless a
#     `merge` entry says how to combine them. Silently clobbering a file is the
#     one failure mode that loses work irrecoverably.
require_relative "lib"
require "fileutils"

# Paths whose contents the current phase deliberately leaves alone. They are
# still renamed here only if they are inside a renamed tree; their *contents*
# are Phase 6's business.
module RenamePaths
  # Files that the mapping collapses onto one name. Each entry says how to
  # combine them; without it the run aborts.
  #
  # `lib/alchemy.rb`     -> `lib/laiss_cms.rb`   (module LaissCms, core config)
  # `lib/alchemy_cms.rb` -> `lib/laiss_cms.rb`   (requires everything)
  #
  # Both are the public entry point under the new name, so they become one file:
  # the core module body first (it must be defined before the requires that
  # reference it), then the require list, then the engine.
  #
  # The sources are matched by their *pre-rename* filenames, because that is
  # what is on disk when this script runs: `apply` rewrites file *contents*,
  # never filenames. Matching the post-rename name here would find nothing.
  MERGES = {
    "lib/laiss_cms.rb" => {
      candidates: ["lib/alchemy.rb", "lib/alchemy_cms.rb"],
      drop_duplicate_requires: true
    }
  }.freeze

  class << self
    # Ordering is the whole design here, and getting it wrong is how a rename
    # corrupts a tree. Two hard-won rules:
    #
    #  1. Directories are renamed FIRST, deepest-first. Renaming a directory
    #     carries its files with it, so files never need a separate move.
    #  2. Files are renamed only when their own basename still contains a token
    #     after (1) — e.g. app/assets/config/alchemy_manifest.js, whose parent
    #     directory is never renamed.
    #
    # The previous order (files, then directories) produced
    # `laiss_cms/page_layouts/page_layouts`: moving files created the new parent
    # directories, and `mv src dst` into an existing directory nests src inside
    # it rather than renaming. Files must never create a directory that a later
    # directory rename is going to target.
    def plan
      merges = plan_merges
      merged = merges.flat_map { |entry| entry[:sources] }.to_set

      merges + plan_dir_renames + plan_file_renames(merged)
    end

    def plan_merges
      MERGES.filter_map do |target, spec|
        sources = spec[:candidates].select { |path| File.exist?(File.join(Rebrand::ROOT, path)) }
        next if sources.empty?

        {type: :merge, target: target, sources: sources, spec: spec}
      end
    end

    def plan_dir_renames
      all_directories
        .filter_map { |path| dir_entry(path) }
        .sort_by { |entry| -entry[:from].count("/") }
    end

    def dir_entry(path)
      target = rename_path(path)
      return if target == path

      {type: :dir, from: path, to: target}
    end

    # Files whose *basename* still carries a token. Planned against the tree as
    # it exists right now, so this must run after the directory renames: a file
    # carried into `laiss_cms/` by its parent already has its final directory.
    #
    # Deliberately NOT using Rebrand.tracked_files: that list is memoized from
    # the first call, so after a directory rename it names paths that no longer
    # exist and misses files that have only just appeared under a new parent.
    def plan_file_renames(merged = Set.new)
      live_text_files
        .reject { |path| merged.include?(path) }
        .filter_map do |path|
          basename = File.basename(path)
          renamed = Rebrand.transform_segment(basename)
          next if renamed == basename

          {type: :file, from: path, to: File.join(File.dirname(path), renamed)}
        end
        .sort_by { |entry| entry[:from] }
    end

    # Every text file currently on disk, honouring the same exclusions as the
    # content rewrite.
    def live_text_files
      Dir.glob("**/*", File::FNM_DOTMATCH, base: Rebrand::ROOT)
        .select { |path| File.file?(File.join(Rebrand::ROOT, path)) }
        .reject { |path| Rebrand.excluded?(path) }
        .select { |path| Rebrand.text?(path) }
        .sort
    end

    def rename_path(path)
      path.split("/").map { |segment| Rebrand.transform_segment(segment) }.join("/")
    end

    def all_directories
      Dir.glob("**/", base: Rebrand::ROOT)
        .map { |dir| dir.chomp("/") }
        .reject { |dir| Rebrand.excluded?(dir) || Rebrand.excluded?("#{dir}/x") }
        .sort
    end

    # Detect renames that would land on a path that still exists (or on another
    # rename's target) and that no merge entry accounts for.
    def collisions(plan)
      merge_targets = plan.select { |entry| entry[:type] == :merge }.map { |entry| entry[:target] }
      targets = plan.reject { |entry| entry[:type] == :merge }.map { |entry| entry[:to] }
      duplicates = (targets + merge_targets).tally.select { |_, count| count > 1 }.keys
      existing = targets.select { |target| File.exist?(File.join(Rebrand::ROOT, target)) }

      {duplicates: duplicates, existing: existing}
    end
  end
end

def main(argv)
  write = argv.include?("--write")
  unknown = argv - %w[--write]
  unless unknown.empty?
    warn "unknown option(s): #{unknown.join(" ")}"
    warn "usage: script/rebrand/rename_paths [--write]"
    return 2
  end

  plan = RenamePaths.plan
  puts "Mode: #{write ? "WRITE" : "dry-run"}"

  if plan.empty?
    puts "No paths need renaming — tree is already rebranded."
    return 0
  end

  collisions = RenamePaths.collisions(plan)
  unless collisions[:duplicates].empty?
    warn "FAIL — several renames target the same path:"
    collisions[:duplicates].each { |path| warn "  #{path}" }
    return 1
  end
  unless collisions[:existing].empty?
    warn "FAIL — renames would overwrite existing paths:"
    collisions[:existing].each { |path| warn "  #{path}" }
    return 1
  end

  plan.each do |entry|
    case entry[:type]
    when :merge
      puts "merge  #{entry[:sources].join(" + ")}"
      puts "    -> #{entry[:target]}"
    when :file
      puts "file   #{entry[:from]}"
      puts "    -> #{entry[:to]}"
    when :dir
      puts "dir    #{entry[:from]}/"
      puts "    -> #{entry[:to]}/"
    end
  end

  counts = plan.group_by { |entry| entry[:type] }.transform_values(&:size)
  puts
  puts "Total: #{counts.fetch(:file, 0)} file(s), #{counts.fetch(:dir, 0)} director(ies), " \
    "#{counts.fetch(:merge, 0)} merge(s)"

  unless write
    puts "Dry run only — nothing was renamed. Re-run with --write to apply."
    return 0
  end

  # Merges first (they read the original entry points), then directories
  # shallowest-first, then files whose basename still carries a token.
  #
  # The whole sequence repeats until it reaches a fixed point. A single pass is
  # not enough: renaming a directory changes which paths exist, and a file that
  # only appears under its new parent (e.g. `laiss_cms/update_checks/
  # alchemy_app.rb`) is not visible until the pass that moved it has finished.
  # Looping here means `--write` is always one invocation, never "run it twice".
  merges = plan.select { |entry| entry[:type] == :merge }
  merges.each { |entry| merge_files(entry) }

  passes = 0
  loop do
    passes += 1
    changed = 0

    RenamePaths.plan_dir_renames
      .sort_by { |entry| entry[:from].count("/") }
      .each { |entry| changed += 1 if move_dir(entry[:from], entry[:to]) }

    RenamePaths.plan_file_renames(Set.new).each do |entry|
      move(entry[:from], entry[:to])
      changed += 1
    end

    break if changed.zero?
    raise "rename_paths did not converge after 10 passes" if passes >= 10
  end

  remaining = RenamePaths.plan
  puts
  puts "Renamed in #{passes} pass(es). Paths still needing attention: #{remaining.size}"
  remaining
    .sort_by { |entry| entry[:to] || entry[:target] }
    .first(10)
    .each { |entry| puts "  #{entry[:type]}: #{entry[:from] || entry[:sources]} -> #{entry[:to] || entry[:target]}" }
  remaining.empty? ? 0 : 1
end

def merge_files(entry)
  parts = entry[:sources].map { |path| File.read(File.join(Rebrand::ROOT, path)) }

  body =
    if entry[:spec][:drop_duplicate_requires]
      merged_body(parts)
    else
      parts.join("\n")
    end

  File.write(File.join(Rebrand::ROOT, entry[:target]), body)
  entry[:sources].each { |path| File.delete(File.join(Rebrand::ROOT, path)) }
end

# Concatenate the parts while dropping a `require` that an earlier part already
# made, and dropping any part's leading magic comments after the first.
#
# Without both, the merged file keeps the second file's
# `# frozen_string_literal: true` in the middle of the file, where it is ignored
# and standardrb rejects it (Lint/MisplacedMagicComment).
def merged_body(parts)
  seen = Set.new
  kept = parts.each_with_index.flat_map do |part, index|
    part.each_line.with_index do |line, line_index|
      # Drop repeated requires.
      if (match = line.match(/^require(_relative)? ["']([^"']+)["']/))
        key = match[2]
        next false unless seen.add?(key)
      end
      # Drop magic comments from every part but the first.
      next false if index.positive? && line_index < 3 && line.start_with?("# frozen_string_literal:")
      # Drop the self-require the entry point made before the merge.
      next false if index.positive? && line.match?(/^require ["']laiss_cms["']\s*$/)

      true
    end
  end

  # Collapse the runs of blank lines the dropped lines leave behind.
  kept.join.gsub(/\n{3,}/, "\n\n")
end

def move(from, to)
  src = File.join(Rebrand::ROOT, from)
  dst = File.join(Rebrand::ROOT, to)
  raise "missing source #{from}" unless File.exist?(src)
  raise "target already exists #{to}" if File.exist?(dst)

  FileUtils.mkdir_p(File.dirname(dst))
  FileUtils.mv(src, dst)
end

# Rename a directory. `FileUtils.mv` NESTS when the destination exists, which
# silently produces `a/a` — so refuse rather than risk it.
#
# Returns false when this rename was already carried out by a shallower one
# (renaming `a` -> `c` moves `a/b` to `c/b`, so the planned `a/b` -> `c/b`
# entry has nothing left to do).
def move_dir(from, to)
  src = File.join(Rebrand::ROOT, from)
  dst = File.join(Rebrand::ROOT, to)
  return false unless File.directory?(src)

  if File.exist?(dst)
    raise "target directory already exists for #{from} -> #{to}" unless File.directory?(dst) && Dir.empty?(dst)

    FileUtils.rmdir(dst)
  end

  FileUtils.mkdir_p(File.dirname(dst))
  FileUtils.mv(src, dst)
  true
end

exit(main(ARGV)) if $PROGRAM_NAME == __FILE__
