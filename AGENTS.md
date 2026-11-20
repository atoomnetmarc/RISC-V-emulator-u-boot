# Agent Rules Index

## Documentation Map

- **README.md** - General project description.
- **docs/index.md** - Document index with the dependency split and the build notes.

## Core Rules

- **Hobby-grade project** - Be gentle with advice. Be honest if the code smells.
- **Update docs on code change** - Check any `.md` file when the code changes. README.md and the docs/ rule files must stay in sync with the code.
- **Language** - Write everything in English. Reply in the user's language.
- **No doxing** - Never document absolute paths or real network names.
- **Prove calculations** - Validate calculations with GCC or Python. Do not reason manually.
- **X-Y problem?** - Ask the user about X. Do not propose a solution Y first.
- **Ask questions** - Asking the user questions is allowed and encouraged. Prefer the `/grill-me` skill when it is available. Present ALL questions with multiple answer options. Use a table with one row per option and these columns: `Answer | Industry standard | Risk | Reward | Fits test-framework | Notes`. Read the relevant docs or code before you ask. Add a final row labeled "From scratch" to propose a custom alternative. After the table, state the recommended answer and explain why.
- **Answer questions, execute commands** - Answer a question and offer follow-up choices when the user asks one. Act only when the user gives an explicit instruction.
- **Concise completions** - State only the final result in `attempt_completion`. Do not re-explain steps, summarize previous outputs, or repeat information the user already saw.
- **No fancy UTF-8 characters** - Use a simple ASCII character when one exists.
- **RISC-V Instruction Set Manual** - Check every change or addition that touches ISA behaviour against the RISC-V Instruction Set Manual (privileged and unprivileged volumes). If the manual is not available locally, ask the user to download it in ~/Downloads.

## Code Quality Rules

- ASD-STE100
- Readability over cleverness.
- Understand fully before simplifying.
- YAGNI. Do not speculate.
- Use native functionality.
- No dependencies for code that a few lines do.
- DRY.
- Boring over clever.
- One line if possible.
- No scaffolding for later.
- No dead code.
- Deletion over addition.
- Smallest diff.

## Quick Reference

- The wrapper owns the Makefile, the Dockerfile, the Kconfig fragment and the docs. U-Boot is third-party code in the shared cache; do not reformat or patch it without a documented reason.
- Build with `make build`; the container is the build environment.
- No historic references in comments or documentation: do not use "initial", "previously", "no longer", "now", "before", "after", "was", "became", "replaces the old", or "Fase X" markers. Write in the timeless present tense.
- No changelogs, phase markers, or technical decisions in source comments: changelogs belong in git commit messages, "Fase X" markers belong nowhere, and technical decisions belong in the rule files under docs/.
- No hard line-wrapping in markdown: All sentences of a single paragraph belong on one line.
