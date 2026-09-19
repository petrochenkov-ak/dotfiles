You are an expert Python automation developer. Your task is to write a single-file, production-ready Python CLI script using only standard libraries (`os`, `pathlib`, `sys`). This script scans SQL repositories and syncs a Python package structure based on specific strict mapping rules.

Follow these explicit instructions without any deviation.

### Context & Directory Architecture
The script operates on two parallel directory structures sharing a common template prefix `{project}`.
1. `{project}-sql/` (Source Directory)
2. `{project}-python-packages/` (Target Directory)

### File Discovery Rules (Input)
Scan the `{project}-sql/` structure. A file is considered a valid source `{table}.sql` only if it matches one of these two strict location patterns:

1. `{project}-sql/sql/SCHEMA/{schema}/TABLE/{table}.sql`
   * Requirement: Include ALL files found under this pattern for any `{schema}` name.

2. `{project}-sql/sql/_shared/SCHEMA/{schema}/TABLE/{table}.sql`
   * Requirement: Include files from this shared directory ONLY if the `{schema}` name matches the pattern where it ends with `_repl_tasks` (e.g., `something_repl_tasks` or exactly `_repl_tasks`). Skip all other schemas in the `_shared/` directory.

### Output Target Specifications & Terminal Output
For every valid `{schema}` and `{table}` discovered, perform the following atomic actions inside `{project}-python-packages/`:

1. **Schema Root Package File:**
   Path: `{project}-python-packages/packages/{schema}/{schema}/__init__.py`
   * Requirement: Ensure the parent directories exist.
   * Action: Create as a completely empty file *only* if it does not already exist.
   * Terminal Output: If this file was newly created, print exactly: `touch {project}-python-packages/packages/{schema}/{schema}/__init__.py`

2. **Individual Table Model File:**
   Path: `{project}-python-packages/packages/{schema}/{schema}/models/{table}.py`
   * Requirement: Ensure the parent directories exist.
   * Action: Create as a completely empty file *only* if it does not already exist. Do not modify or overwrite it if it exists.
   * Terminal Output: If this file was newly created, print exactly: `touch {project}-python-packages/packages/{schema}/{schema}/models/{table}.py`

3. **Stale File Deletion:**
   * Action: Scan every existing `{table}.py` file inside `{project}-python-packages/packages/{schema}/{schema}/models/`.
   * Condition: If a `{table}.py` file is found but has NO matching source `{table}.sql` file according to the Discovery Rules, **delete** that `.py` file immediately.
   * Terminal Output: When a file is deleted, print exactly: `rm {project}-python-packages/packages/{schema}/{schema}/models/{table}.py`

4. **Models Directory Aggregator (Execute LAST):**
   Path: `{project}-python-packages/packages/{schema}/{schema}/models/__init__.py`
   * Execution Timing: This file must be generated or updated **at the very end**, strictly *after* all table files have been created and all stale files have been deleted.
   * Action: Completely overwrite this file.
   * Content Format: One single-line import statement per valid model file remaining in that directory, sorted alphabetically. Exactly one line per model:
     `from .{table} import {ModelClassName}`
   * Terminal Output: Do NOT output "touch" or "rm" for this file modification.

### Model Class Name Transformation Algorithm
To transform the raw SQL string `{table}` into `{ModelClassName}`, execute this precise logic:

<rule>
1. Check if the `{table}` string ends with the literal suffix `_queue`.
2. IF IT ENDS WITH `_queue`:
   - Strip the trailing `_queue` substring.
   - Convert the remaining string from snake_case to PascalCase (capitalize the first letter of each underscore-separated word, then remove the underscores).
   - Append the literal string `Task` (Do NOT append `Queue`).

   *Examples:*
   - `word_word_queue` -> `WordWordTask`
   - `word_queue` -> `WordTask`

3. IF IT DOES NOT END WITH `_queue`:
   - Convert the entire `{table}` string from snake_case to PascalCase.

   *Examples:*
   - `users` -> `Users`
   - `user_profiles` -> `UserProfiles`
</rule>

### Execution Constraints, Handling, and Logging
1. **Strict Terminal Logging:** Use `print()` ONLY for the mandatory `touch xxx` and `rm xxx` actions described in the Output Target Specifications. Do not print any other normal execution logs, success status messages, or metadata.
2. **No Exceptions Allowed:** Do NOT use `raise` statements anywhere in the script. Catch all potential environment or filesystem errors (e.g., missing directories, permission errors) gracefully within try-except blocks.
3. **Granular Negative Feedback Only:** Use `print()` to output an error message when a specific action or operation could not be completed, or if absolutely nothing was done by the script.
4. **Isolated Print Statements:** Print each root-cause reason **SEPARATELY** per failure event. Do not group them into general errors or single summaries. If multiple things cannot be done (e.g., failed to write due to permission, invalid path configuration), print a specific descriptive line for each individual failure so it is perfectly clear exactly what went wrong where.

### Expected Deliverable
Provide ONLY the raw, functional Python script enclosed inside standard markdown code blocks. Do not add conversational text or post-script notes before or after the code block.
