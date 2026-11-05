# frozen_string_literal: true

# Shared core for the rebrand tooling: mapping loading, file discovery and
# token matching. Imported by `apply`, `verify` and `self_test` so all three
# agree on exactly what a token is and which files are in scope.
require "yaml"

module Rebrand
  ROOT = File.expand_path("../..", __dir__)

  MAPPING_PATH = File.join(__dir__, "mapping.yml")

  # Files that are allowed to keep the upstream name forever.
  #
  # BSD-3-Clause requires the original copyright notice, the conditions and the
  # disclaimer to be retained in source distributions, and requires that the
  # upstream holder's name not be used to endorse the derived product. Keeping
  # these three licence files byte-identical is what satisfies both.
  LICENSE_ALLOWLIST = %w[
    LICENSE
    i18n/LICENSE
    devise/LICENSE
  ].freeze

  # Upstream names that must survive verbatim because they are not product
  # names: upstream's own domain names and Slack workspace. Rewriting these
  # produces nonsense like `laiss-cms-cms.com`.
  #
  # NOTE: this list exists so `apply` does not mangle them mid-run. It is NOT a
  # licence to keep them: verify() fails on any of these outside a LICENSE file.
  PROTECTED = [
    "alchemy-cms.com",
    "alchemy-cms.slack.com",
    "guides.alchemy-cms.com",
    "app.alchemy-cms.com",
    "slackin.alchemy-cms.com",
    "stackoverflow.com/questions/tagged/alchemy-cms",
    "join.slack.com/t/alchemy-cms"
  ].freeze

  PLACEHOLDER = "\u0000REBRAND_PROTECTED_%d\u0000"

  # Never rewritten or scanned. Build output is regenerated from source, so
  # rewriting it would only create churn that the next build discards.
  #
  # `script/rebrand` is excluded because it is the only place that legitimately
  # contains upstream tokens as data: mapping.yml holds them in its `from`
  # column, and the scripts quote them in comments and self-test fixtures.
  # Without this exclusion the tool rewrites its own mapping table and can never
  # run twice.
  EXCLUDED_DIRS = %w[
    .git
    node_modules
    coverage
    tmp
    log
    .bundle
    script/rebrand
    spec/dummy/storage
    spec/dummy/log
    spec/dummy/tmp
    app/assets/builds
    vendor/javascript
  ].freeze

  EXCLUDED_FILES = %w[
    Gemfile.lock
    pnpm-lock.yaml
  ].freeze

  # Binary or generated formats. Matched by extension.
  BINARY_EXTENSIONS = %w[
    .png .jpg .jpeg .gif .ico .webp .woff .woff2 .ttf .otf .eot
    .dwg .zip .gz .pdf .min.js .min.css .map
    .sqlite3 .db
  ].freeze

  Row = Struct.new(:id, :from, :to, :mode, :kind, :expect, :index) do
    # Build the matcher for this row.
    #
    # "literal" rows have no boundaries at all, "word" rows are anchored on both
    # sides, "prefix" rows only assert the left boundary so a following
    # identifier character is part of the match.
    def regexp
      escaped = Regexp.escape(from)
      case mode
      when "literal"
        Regexp.new(escaped)
      when "word"
        Regexp.new("(?<![A-Za-z0-9_])#{escaped}(?![A-Za-z0-9_])")
      when "prefix"
        Regexp.new("(?<![A-Za-z0-9_])#{escaped}")
      when "filename"
        # Filenames are not identifiers: Rails migration files are named
        # `20230121212637_alchemy_six_point_one.rb` and Rails derives the class
        # name from the part after the timestamp, so the token sits directly
        # after an underscore. The identifier rule correctly refuses to match
        # there (`2023_..._alchemy_six...` is one long identifier), which is why
        # a dedicated mode is needed rather than loosening "prefix".
        Regexp.new(escaped)
      when "embedded"
        # `Alchemy` occurring inside a CamelCase identifier, as in
        # `AddSearchableToAlchemyPages` or `CreateAlchemyUsers`. A boundary-anchored
        # rule cannot see these: the preceding character is a letter and the
        # following one is uppercase. The lookarounds keep this from touching
        # snake_case names, where `alchemy` is always lowercase and never
        # followed by an uppercase letter (`current_alchemy_user`).
        Regexp.new("(?<=[a-z0-9])#{escaped}(?=[A-Z])")
      else
        raise ArgumentError, "row #{id}: unknown mode #{mode.inspect}"
      end
    end
  end

  class << self
    def rows
      @rows ||= load_rows
    end

    # Application order: most specific first.
    #
    # Sorting by descending pattern length is what keeps `AlchemyCMS` from being
    # rewritten by the bare `Alchemy` rule. Rows of equal length keep their
    # mapping.yml order, so the result is deterministic across runs.
    def ordered_rows
      @ordered_rows ||= rows.sort_by { |row| [-row.from.length, row.index] }
    end

    def row_by_id(id)
      rows.find { |row| row.id == id } or raise KeyError, "unknown mapping row #{id.inspect}"
    end

    # Every file the tooling considers, as paths relative to ROOT, sorted so
    # output and dry-run reports are stable between runs.
    def tracked_files
      @tracked_files ||= Dir.glob("**/*", File::FNM_DOTMATCH, base: ROOT)
        .select { |path| File.file?(File.join(ROOT, path)) }
        .reject { |path| excluded?(path) }
        .select { |path| text?(path) }
        .sort
    end

    def excluded?(path)
      return true if EXCLUDED_FILES.include?(path)
      return true if LICENSE_ALLOWLIST.include?(path)
      return true if BINARY_EXTENSIONS.any? { |ext| path.end_with?(ext) }

      EXCLUDED_DIRS.any? do |dir|
        path == dir || path.start_with?("#{dir}/")
      end
    end

    def text?(path)
      sample = File.binread(File.join(ROOT, path), 8192) || ""
      return false if sample.include?("\0")

      sample.dup.force_encoding(Encoding::UTF_8).valid_encoding?
    rescue SystemCallError
      false
    end

    def read(path)
      File.read(File.join(ROOT, path), encoding: "UTF-8")
    end

    def write(path, content)
      File.write(File.join(ROOT, path), content, encoding: "UTF-8")
    end

    # Count matches of every row across all in-scope files.
    #
    # Filename-mode rows are excluded: they only ever apply to path segments
    # (see transform_segment). Counting them against file *content* would report
    # false leftovers for identifiers the prefix rule correctly leaves alone,
    # such as `current_alchemy_user`.
    def tally(content_by_file = nil)
      content_by_file ||= tracked_files.to_h { |path| [path, read(path)] }
      content_rows = rows.reject { |row| row.mode == "filename" }

      content_rows.to_h do |row|
        pattern = row.regexp
        files = Set.new
        count = 0

        content_by_file.each do |path, content|
          hits = content.scan(pattern).size
          next if hits.zero?

          count += hits
          files << path
        end

        [row.id, {count: count, files: files}]
      end
    end

    # Locations of every remaining match, for human-readable failure output.
    def locations(row, limit: 10)
      pattern = row.regexp
      found = []

      tracked_files.each do |path|
        read(path).each_line.with_index(1) do |line, number|
          next unless line.match?(pattern)

          found << "#{path}:#{number}: #{line.strip[0, 120]}"
          return found if found.size >= limit
        end
      end

      found
    end

    # Rewrite one file's content by applying every row in order.
    #
    # Rows in "filename" mode are skipped here: they exist to rename migration
    # files like `20230121212637_alchemy_six_point_one.rb`, whose token sits
    # after a timestamp underscore. Applying them to file *content* would also
    # rewrite identifiers that the stricter "prefix" rule deliberately leaves
    # alone, so content and path rewriting use separate row sets.
    def transform(content)
      shield, restore = shield_protected(content)
      out = ordered_rows.reject { |row| row.mode == "filename" }.reduce(shield) do |acc, row|
        acc.gsub(row.regexp, row.to)
      end
      restore.call(out)
    end

    # Replace protected upstream names with placeholders that no replacement row
    # can match, then put them back. Without this, `alchemy-cms.com` becomes
    # `laiss-cms-cms.com` (the `alchemy_cms` row rewrites the inner slug), and
    # `alchemy-cms.slack.com` breaks the same way.
    def shield_protected(content)
      found = {}
      shielded = PROTECTED.each_with_index.reduce(content) do |acc, (token, index)|
        next acc unless acc.include?(token)

        key = format(PLACEHOLDER, index)
        found[key] = token
        acc.gsub(token, key)
      end

      restorer = ->(text) { found.reduce(text) { |acc, (key, token)| acc.gsub(key, token) } }
      [shielded, restorer]
    end

    # Mask protected names without restoring them. Used by verify so it does not
    # report deliberately-preserved upstream domains as missed renames.
    def mask_protected(content)
      shield_protected(content).first
    end

    # Rewrite a single path segment (a directory name or a file basename).
    # Filename-mode rows participate here, which is the only place they apply.
    def transform_segment(segment)
      ordered_segments.reduce(segment) do |acc, row|
        acc.gsub(row.regexp, row.to)
      end
    end

    # Content rows first, then filename-only rows: a migration file needs both
    # (`alchemy_six_point_one` and the leading `alchemy_` prefix).
    def ordered_segments
      @ordered_segments ||= begin
        content_rows = ordered_rows.reject { |row| row.mode == "filename" }
        file_rows = ordered_rows.select { |row| row.mode == "filename" }
        content_rows + file_rows
      end
    end

    private

    def load_rows
      raw = YAML.safe_load_file(MAPPING_PATH, aliases: false)
      raise "mapping.yml must contain a list of rows" unless raw.is_a?(Array)

      raw.each_with_index.map do |attrs, index|
        Row.new(
          id: attrs.fetch("id"),
          from: attrs.fetch("from"),
          to: attrs.fetch("to"),
          mode: attrs.fetch("mode"),
          kind: attrs.fetch("kind"),
          expect: attrs["expect"],
          index: index
        )
      end.tap { |loaded| validate_rows!(loaded) }
    end

    def validate_rows!(loaded)
      duplicate_ids = loaded.map(&:id).tally.select { |_, n| n > 1 }.keys
      raise "mapping.yml has duplicate ids: #{duplicate_ids.join(", ")}" if duplicate_ids.any?

      # The same token may legitimately appear twice when it applies in
      # different contexts — `alchemy_` is both an identifier prefix and a
      # migration-filename prefix — so uniqueness is per (from, mode).
      duplicate_sources = loaded.map { |row| [row.from, row.mode] }.tally.select { |_, n| n > 1 }.keys
      if duplicate_sources.any?
        raise "mapping.yml has duplicate from+mode tokens: #{duplicate_sources.map { |f, m| "#{f} (#{m})" }.join(", ")}"
      end

      loaded.each do |row|
        raise "row #{row.id}: empty from" if row.from.to_s.empty?
        raise "row #{row.id}: empty to" if row.to.to_s.empty?
        raise "row #{row.id}: from must not contain regex metacharacters" if row.from.match?(/[\\^$.|?*+()\[\]{}]/)
        # A replacement that itself contains an upstream token would make the
        # transform non-idempotent: applying it twice would keep changing the
        # text. Catch that here rather than in a confusing self-test failure.
        other_tokens = loaded.reject { |other| other.id == row.id }.map(&:from)
        collisions = other_tokens.select { |token| row.to.include?(token) }
        next if collisions.empty?

        raise "row #{row.id}: replacement #{row.to.inspect} contains upstream token(s) " \
          "#{collisions.join(", ")} — the transform would not be idempotent"
      end
    end
  end
end
