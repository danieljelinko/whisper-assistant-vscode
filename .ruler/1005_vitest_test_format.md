# Vitest test format

Concrete test conventions for TypeScript. The language-agnostic discipline (red/green cycle, real-data-over-mocks, when-TDD-doesn't-apply) lives in `1002_tdd_red_green.md`; this file makes it concrete for vitest.

## Test framework

Use **vitest**. Not jest. Invoke via `bunx vitest` (per `1004_bun_package_management.md`) — `bunx vitest run` for a single non-watch pass in CI.

## File naming and location

- One test file per module: `{module}.test.ts` next to the module, or under a `tests/` directory mirroring `src/`.
- Group with `describe("subjectFn", ...)`; one behaviour per `it(...)`.

## Test name expresses what is tested

Read the `describe` + `it` together as a sentence describing the *behaviour* and the *condition*:

```typescript
describe("isTagCoreRepo", () => {
  it("returns true when package.json lists tag-core", () => { /* ... */ })
})
```

Pattern: `it("{expected_outcome} when {condition}")`. Avoid vague names like `it("works")` or `it("basic")`.

## Given / When / Then inside each test

Three blocks separated by blank lines and `// Given` / `// When` / `// Then` comments, so intent is scannable without reading the assertions:

```typescript
it("returns true when package.json lists tag-core", () => {
  // Given a repo whose package.json declares tag-core as a dependency
  const repo = makeRepo({packageJson: '{"dependencies": {"tag-core": "^0.1"}}'})

  // When we check whether it's a tag-core repo
  const result = isTagCoreRepo(repo)

  // Then the predicate returns true
  expect(result).toBe(true)
})
```

## Shared setup → factory functions (the fixture analog)

When several tests need similar test-data, write a **factory function** that builds the data with parameters — not a shared static object. The factory keeps each test's setup visible at the call site:

```typescript
function makeRepo({packageJson = "", subdirs = []}: {packageJson?: string; subdirs?: string[]} = {}): string {
  const repo = fs.mkdtempSync(path.join(os.tmpdir(), "repo-"))
  if (packageJson) fs.writeFileSync(path.join(repo, "package.json"), packageJson)
  for (const sub of subdirs) fs.mkdirSync(path.join(repo, sub), {recursive: true})
  return repo
}
```

Register cleanup with `onTestFinished(() => fs.rmSync(repo, {recursive: true, force: true}))` so each test owns and disposes its own state. Reach for `test.extend` only when a fixture needs shared lifecycle setup/teardown.

## One assertion per concept

Multiple `expect` lines are fine if they verify one behaviour. If a test verifies two unrelated behaviours, split it into two tests.

## Self-contained, deterministic, ordering-independent

- Use a real temp dir (`fs.mkdtemp` under `os.tmpdir()`) for any filesystem state, cleaned up in `onTestFinished`. Never write to a path the test does not own.
- No reliance on test execution order. A run under `vitest --sequence.shuffle` must pass.

## Real data over mocks — vitest specifics

Follow the philosophy in `1002_tdd_red_green.md`. In vitest that means:

- File operations — real temp dirs, not `vi.mock('fs')`.
- Database operations — in-memory SQLite or a real file-backed db in a temp dir.
- Time-dependent behaviour — `vi.useFakeTimers()` / `vi.setSystemTime()`.
- External boundaries — `vi.spyOn` / `vi.mock` at the boundary only (network — prefer an `msw` server or a stubbed `fetch`; subprocess). Never mock your own modules.

### Example: real filesystem, no mocks needed

```typescript
it("returns parsed object when file is valid JSON", () => {
  // Given a config file containing valid JSON
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "cfg-"))
  onTestFinished(() => fs.rmSync(dir, {recursive: true, force: true}))
  const config = path.join(dir, "config.json")
  fs.writeFileSync(config, '{"name": "foo", "size": 42}')

  // When we load it
  const result = loadConfig(config)

  // Then the parsed object matches the file content
  expect(result).toEqual({name: "foo", size: 42})
})
```

### Example: mock only the external boundary

```typescript
it("returns cached value when network is unreachable", () => {
  // Given a cache with a known user and a fetch that always fails
  const cache = {alice: {id: 1}}
  vi.spyOn(globalThis, "fetch").mockRejectedValue(new Error("ECONNREFUSED"))

  // When we fetch "alice"
  const user = fetchUser("alice", {cache})

  // Then the cached value is returned (no exception, no real network call)
  expect(user).toEqual({id: 1})
})
```
