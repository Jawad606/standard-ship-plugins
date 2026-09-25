---
name: spec
description: Write a structured feature spec (goal, user stories, acceptance criteria, scope, data and API changes) in the repo's specs folder before any code is written. Use when the user runs /spec, asks to "plan a feature", "write requirements", "spec this out", or asks to build a new feature in a repo using ship-standards and no spec exists yet.
---

# Spec

A spec is the contract the build, tests, and merge-critique are checked against. Keep it
short enough that the user will actually read and correct it.

## Steps

1. Read `.ship-standards.json` for `specsDir` (default `specs/`). Find the next number
   (`001`, `002`, …) and slug the feature name: `specs/004-leave-approval.md`.
2. Gather what's needed. Use the user's request, linked tickets, and the codebase. Ask at
   most 3 questions, and only about things that would change the design (who uses it,
   edge cases with real consequences, constraints). Don't ask what the code already answers.
3. Look at the codebase for the modules this will touch, so the "Affected areas" section
   names real files, not guesses.
4. Write the spec using `references/spec-template.md`.
5. Give every acceptance criterion an ID (`AC-1`, `AC-2`, …). Each must be testable: a
   reviewer should be able to say pass or fail without judgment.
6. Show the spec to the user and get confirmation before building. Update `Status` to
   `approved` once they confirm.

## Rules

- Mark anything you assumed with **(assumption)** so the user can correct it.
- Put deliberately excluded work in "Out of scope" — this is what stops scope creep later.
- If the feature is too big for one PR, split it into numbered specs and say so.
