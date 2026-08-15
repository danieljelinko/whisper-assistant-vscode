# Package Management with Bun

Use Bun for all JavaScript/TypeScript package and script management. Never use npm, yarn, or pnpm directly.

## Commands

- `bun add <package>` — add a dependency (updates `package.json` + `bun.lock`)
- `bun add -d <package>` — add a dev dependency
- `bun remove <package>` — remove a dependency
- `bun install` — sync `node_modules` to the lockfile after pulling or switching branches
- `bun run <script>` — run a `package.json` script inside the project
- `bunx <tool>` — run a package binary without installing it globally (e.g. `bunx vitest`)

## Running TypeScript directly

Bun executes `.ts` files with no build step — the equivalent of a self-contained script:

```bash
bun run script.ts
```

No transpile, no `ts-node`, no separate config needed for a one-off script.

## Negatives

- Never `npm install` / `yarn` / `pnpm install` — they write a competing lockfile (`package-lock.json` / `yarn.lock` / `pnpm-lock.yaml`) alongside `bun.lock` and silently diverge the dependency graph.
- Never install project dependencies globally.
- Never edit `package.json` dep lists by hand then forget to run `bun install`.
- Commit `bun.lock` — it is the source of truth for reproducible installs.
