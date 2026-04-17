# Triple Gate -- Sonnet Edition

Quality enforcement for Claude Code. 6 AI cops review every build before it ships.

Sonnet 4.6 agents provide a balanced cost/quality alternative to the Opus edition -- same protocol, same rigor, lower token cost per review cycle.

## what it does

When you type `/Sonpolice`, Claude reviews its own work through 4 phases:

1. **Self-Drafts** -- writes 3 drafts, each one fixing weakness categories from the last
2. **Security + Quality** -- 2 Sonnet 4.6 agents review in parallel (credential leaks, injection, error handling, edge cases)
3. **Integration + Failure Modes** -- 2 more Sonnet 4.6 agents check for dependency conflicts, race conditions, what breaks when things go wrong
4. **Final Audit** -- 2 Sonnet 4.6 agents verify the implementation matches the plan and check long-term maintainability

Nothing ships until all 6 cops pass. If they reject, Claude fixes and resubmits. Loop until clean.

## install

```bash
mkdir -p ~/.claude/skills/Sonpolice
cp SKILL.md ~/.claude/skills/Sonpolice/SKILL.md
```

That's it. Open Claude Code, type `/Sonpolice`, and it activates on your next build.

## what it catches

- Credential leaks in code
- SQL injection, XSS, command injection
- Missing error handling
- Race conditions
- Broken imports and dependency issues
- Silent failures
- Config conflicts
- Technical debt
- Deviations from the approved plan

## requirements

- Claude Code with Sonnet model access (cops are Sonnet 4.6 agents -- balanced between Opus cost and Haiku speed)
- That's it for basic use

## auto-updates (opt-in, optional)

Get updates automatically when we push improvements. The updater ONLY touches the SKILL.md file — it does not collect data, phone home, or modify anything else. Every update is GPG-signed and verified before applying. Delete the script at any time to stop updates.

```bash
cp update-check.sh ~/.claude/skills/Sonpolice/update-check.sh
cp PUBLIC-KEY.asc ~/.claude/skills/Sonpolice/PUBLIC-KEY.asc
chmod +x ~/.claude/skills/Sonpolice/update-check.sh
(crontab -l 2>/dev/null; echo "0 */6 * * * ~/.claude/skills/Sonpolice/update-check.sh") | crontab -
```

## advanced setup (optional)

The SKILL.md references optional hardening features (GPG emergency override, append-only learning log, credential scrubber, budget gates). These require additional setup described in the file. The core review system works without them.

## all editions

| Edition | Model | Cost | Link |
|---------|-------|------|------|
| **Opus** | Claude Opus 4.6 | Highest quality, highest cost | [triple-gate](https://github.com/coderook520/triple-gate) |
| **Sonnet** | Claude Sonnet 4.6 | Balanced quality/cost | [triple-gate-Sonnet](https://github.com/coderook520/triple-gate-Sonnet) |
| **Haiku** | Claude Haiku 4.5 | Fastest, lowest cost | [triple-gate-Haiku](https://github.com/coderook520/triple-gate-Haiku) |

## license

MIT
