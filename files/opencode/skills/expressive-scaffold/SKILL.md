# Skill: Expressive Code Scaffolding & Self-Cleaning

## Description
Enables an agent to generate highly expressive, production-grade structural skeletons (functional or object-oriented) with complete testing suites, runtime theory notes, and automated cleanup of legacy implementation tags.

## Invocation Rules
Trigger this skill whenever the user asks to "create a structure", "scaffold a component", "build an endpoint", or "write a module boilerplate".

---

## Protocol Steps

### Step 1: State Inversion & Self-Cleaning
Before writing any code, scan the target file path if it exists. 
- If a comment block matching `# TODO(opencode): ...` or `@doc """ TODO(opencode): ... """` exists, evaluate if the surrounding implementation satisfies the requirement.
- If **satisfied**, rewrite the file to **delete the TODO text entirely**, but preserve all neighboring typespecs, docstrings, and architectural metadata.
- If **not satisfied** or the file is **new**, proceed to Step 2.

### Step 2: High-Expressiveness Scaffolding Schema
When outputting code blocks, always enforce the following structure:
1. **The Contract:** Explicit static types and function signatures (`@type`, `@spec`, interfaces, or abstract classes).
2. **The Context:** A dedicated `## Theory & Performance` section in the documentation explaining memory constraints, BEAM/runtime behaviors, or optimization requirements specific to that block.
3. **The Guarded Interface:** Complete defensive pattern matching, input sanitization, or explicit error-tuple results (`{:ok, T}` / `{:error, E}`).
4. **The Implementation Target:** Insert a clear instruction block prefixed with `# TODO(opencode):` explaining the steps the user must execute to complete the inner business logic.

### Step 3: Mirroring Test Suite
Simultaneously generate a separate, runnable test file that hits every requirement, status code, edge case, and validation boundary outlined in the main file's docstrings. Tests must run and fail on the scaffolded code. 
