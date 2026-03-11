# Safety Rules

- NEVER run `rm -rf`, `rm -fr`, or any recursive forced deletion
- NEVER use `sudo`
- NEVER modify `.env`, credentials, secrets, or key files
- NEVER force push or `git reset --hard` or `git clean -f`
- NEVER push directly to main or master
- NEVER run `drop table`, `truncate`, or bulk `delete` without WHERE clause
- ALWAYS run tests before committing changes
- ALWAYS create new commits rather than amending existing ones
