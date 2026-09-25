# Testing strategy

## What to test where

| Layer | Tool | Test what | Don't |
|---|---|---|---|
| Unit | Vitest / Jest / Pytest | pure logic, services with fakes, edge cases | test framework internals, trivial getters |
| Integration | Jest/Vitest + real Postgres (Docker) | repositories, API endpoints end-to-end through the app, migrations | mock the database |
| E2E | Playwright | critical user journeys only (login, core flow, payment) | cover every edge case — that's unit tests' job |
| LLM evals | eval script + dataset | output quality/format on real inputs | assert exact strings from a model |

## Rules

- Name tests after behaviour, and reference the AC: `it("AC-2: rejects overlapping leave")`.
- Arrange / act / assert; one behaviour per test.
- Tests must be deterministic: fix time (fake timers), seed data, no real external APIs.
- A bug fix starts with a failing test that reproduces it.
- Never delete or skip a failing test to make the suite green. If a test is wrong, say so
  in the decision log and fix it.
- Playwright: use role/label locators (`getByRole`), not CSS selectors; no fixed `waitForTimeout`.
