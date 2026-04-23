# RULES.md - Experiment Safety Protocol

## Golden Rules

1. **NEVER** delete files outside `/experiments/`
2. **ALWAYS** ask before running: `npm install`, `pip install`, `apt install`, or any executable
3. **NEVER** run `rm -rf /` or similar destructive commands
4. **ALWAYS** work inside `/experiments/` folder only
5. **NEVER** commit secrets, API keys, or tokens to git
6. **ALWAYS** test in isolation before integrating
7. **NEVER** modify system files without explicit approval

## Allowed Operations (No Approval Needed)

- Reading files
- Writing to `/experiments/` 
- `ls`, `cat`, `grep`, `find` (read-only)
- `git status`, `git diff`, `git log`
- Creating directories in `/experiments/`
- Running safe interpreters: `python3 -c "..."`, `node -e "..."`

## Requires Approval

- `npm install`, `pip install`, `yarn add`
- `./script.sh`, `python script.py`, `node script.js` (executing files)
- `apt`, `brew`, `snap` installs
- `docker` commands
- `git push`, `git commit` (confirm message first)
- Any network requests to external APIs (except Brave Search, Notion)
- File operations outside `/experiments/`

## Emergency Stop

If you see anything suspicious, run:
```bash
# Kill all experiment processes
pkill -f experiments
```

## Wiki Updates

After each experiment, update `/experiments/wiki/lessons-learned.md` with:
- What worked
- What failed
- Time-saving tricks discovered
- Dependencies that caused issues
