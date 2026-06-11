# Workflow Template

A reusable agentic workflow + feature-driven development scaffold for new projects.

## Works with

Both [Claude Code](https://claude.com/claude-code) and [opencode](https://opencode.ai/). The prompt content (skills, agents, rules) is mirrored under each tool's directory; the project memory (`CLAUDE.md`) is shared — opencode reads it natively, and it's also registered in `opencode.json`'s `instructions` array.

## What's in here

```
workflow-template/
├── setup.sh                        installer — copies the right files per agent into a new project
├── CLAUDE.md                       project memory, shared by Claude Code and opencode
├── opencode.json                   opencode config — instructions + permission defaults
├── .claude/
│   ├── agents/
│   │   ├── architecture-reviewer.md   challenges plans on architecture grounds
│   │   └── security-reviewer.md       challenges plans on security grounds
│   ├── rules/
│   │   └── security.md                path-triggered pointer to docs/SECURITY-RULES.md
│   ├── skills/
│   │   ├── requirements/SKILL.md      /requirements   — writes feature specs
│   │   ├── technical-design/SKILL.md  /technical-design PROJ-X — designs implementation
│   │   ├── frontend-architecture/SKILL.md  /frontend-architecture — UI design review
│   │   └── write-tests/SKILL.md       /write-tests    — unit + integration tests
│   └── settings.local.json            Claude Code permissions allowlist
├── .opencode/
│   ├── agents/
│   │   ├── architecture-reviewer.md   subagent mirror of the Claude Code agent
│   │   └── security-reviewer.md       subagent mirror of the Claude Code agent
│   └── commands/
│       ├── requirements.md            /requirements
│       ├── technical-design.md        /technical-design PROJ-X
│       ├── frontend-architecture.md   /frontend-architecture
│       └── write-tests.md             /write-tests
├── features/
│   ├── README.md                   how feature specs are organized
│   ├── INDEX.md                    central tracking table (empty)
│   └── template.md                 blank feature-spec template
└── docs/
    ├── PRD.md                      blank Product Requirements Document
    └── SECURITY-RULES.md           security rules (single source of truth)
```

## How to use it for a new project

1. Run `setup.sh` from this template directory, pointing it at your new project root and choosing which agent you use:
   ```bash
   ./setup.sh ~/work/my-new-project --claude        # Claude Code only
   ./setup.sh ~/work/my-new-project --opencode      # opencode only
   ./setup.sh ~/work/my-new-project --both          # install both
   ```
   The script copies only what the chosen agent needs plus the shared files (`CLAUDE.md`, `docs/`, `features/`). It skips template-repo cruft — `.git`, `LICENSE`, `README.md`, and `setup.sh` itself — as well as the other agent's files (`.claude/` for opencode, `.opencode/`+`opencode.json` for Claude Code).

   Pass `--name "My App"` to fill in `{{PROJECT_NAME}}` non-interactively, or omit the agent/name flags to be prompted. The script also creates an empty `ARCHITECTURE.md`. Run `./setup.sh --help` for all options.

2. Edit `CLAUDE.md`: fill in the **About the Project** section (and `{{PROJECT_NAME}}` if you didn't pass `--name`). Keep the Plan Review Workflow and Feature-Driven Development Workflow as-is unless you have a reason to change them.
3. Fill out `ARCHITECTURE.md` as the project takes shape — the skills look for it and gracefully handle its absence.
4. (Optional) Create `docs/CorporateDesign.md` if the project has any frontend — the `frontend-architecture` skill expects this document for visual / UX constraints.
5. Run `/requirements <your-project-idea>` inside Claude Code or opencode. The command detects that the PRD is still empty and switches into **Init Mode**, asks you discovery questions, fills out the PRD, and creates the first batch of feature specs. The same four slash commands (`/requirements`, `/technical-design`, `/frontend-architecture`, `/write-tests`) are available in both tools.
6. For each feature, run:
   ```
   /technical-design PROJ-X
   ```
   The skill appends a Tech Design section to the feature file. Before that design is presented, the Plan Review Workflow in `CLAUDE.md` should run (Round 1 + Refinement + Round 2 with the two reviewer agents).
7. Implement the feature against the Tech Design. Use `/write-tests PROJ-X` to add unit + integration tests.

## What's intentionally generic

- The skills don't assume a particular language, framework, or database. They describe **principles** (e.g., "use real DB in integration tests, not mocks") and ask Claude to **discover the project's actual patterns** before applying them.
- `features/template.md` user stories are in English ("As a … I want to … so that …").
- `docs/PRD.md` is a blank shell, not a filled example.
- `features/INDEX.md` starts with no entries; the next available ID is `PROJ-1`.

## What you'll need to add per project

- `ARCHITECTURE.md` — service boundaries, security invariants, data model overview
- `docs/CorporateDesign.md` — visual language & design tokens (frontend projects only)
- Project-specific test patterns — once you have a few tests in place, the `write-tests` skill discovers them automatically; before then, point Claude at the closest reference

## Updating the template

When you find a pattern that worked well in a real project, port it back here in **generic form** — strip names of services, frameworks, table columns, ID prefixes, etc., and re-express it as a principle plus a discovery step.
