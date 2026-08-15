# TypeScript coding style

## Naming

- Name functions/methods with a verb+object (e.g. `loadSegments`, `savePreds`); avoid vague adjectives like `safe` or `enhanced`. Functions and variables are `camelCase`; types, interfaces, and classes are `PascalCase`.

## Function arguments

- Don't hardcode project-specific values (label strings, tag names, sender/role identifiers like `"SENDER"`, `"ann"`, `"sdr guest"`) inside generic functions. Pass them in — keep the function a generic mechanism, let the caller supply its vocabulary.
- Expose such project-dependent values as **required** parameters (or required options-object fields — never defaulted ones), so every call site states them explicitly. A default that only makes sense for one project is hidden coupling: it makes the function look generic while silently serving one corpus.
  ```typescript
  function findTextIdsWithLabel(project: Project, db: Db, opts: {tag?: string; role?: string; label?: string} = {}) {}  // bad: looks generic, isn't
  function findTextIdsWithLabel(project: Project, tag: string, role: string, label: string, db: Db) {}                   // good: caller passes its own
  ```

## Types

- Annotate the return type of every exported function; let inference handle locals.
- Prefer `unknown` + narrowing over `any`. Reach for `satisfies` to keep a literal's inferred type while checking it against a contract, instead of a cast.
- Prefer modern built-in syntax: `string[]` over `Array<string>`, union/literal types over enums where they suffice, `readonly` where a value must not be mutated.

## Layout

- Write one-liners with arrow functions and ternaries: `const f = (x) => x * 2`, `const z = cond ? a : b`.
- Use destructuring, optional chaining `?.`, and nullish coalescing `??` where they remove noise.
- Align similar logic to emphasise structure:
  ```typescript
  if (cond) x = f(a, b)  // why this branch
  else      x = f(b, a)
  ```
- Use spacing to mirror math or domain conventions: `x = a*b + c`.
- No trailing whitespace.

## Code style

- No unnecessary comments; fit everything in one line when possible.
- Place short `//` comments at the end of the statement they explain.
- Use backticks for parameter names in doc comments.
- Reserve `try/catch` for unstable external interactions (network, subprocess, filesystem). Let internal errors propagate.

## Other principles

- On inconsistency or bug: find the root cause and communicate it. Patching symptoms is not acceptable.
