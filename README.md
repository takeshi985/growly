# Growly

Growly is an educational platform for children aged 5–7. The first version
focuses on early math, reading, and logic skills, with a separate progress view
for parents.

## Current backend capabilities

- parent and child profiles;
- skills and learning tasks;
- backend-side answer grading;
- gentle feedback after mistakes: two hints, then deferred repetition;
- selection of the next age-appropriate task;
- browser MVP with child, parent, and diagnostic modes;
- safe reset of the stable demo child's progress.

## Repository layout

```text
backend/  Phoenix and PostgreSQL API
mobile/   Flutter client for Android, iOS, web, and future desktop builds
docs/     Product, API, workbook, privacy, and mobile setup documentation
```

The first Flutter MVP lives in `mobile/` and connects to the child-safe mobile
API. See [`docs/mobile_flutter_mvp.md`](docs/mobile_flutter_mvp.md) for setup,
run commands, safety rules, and current limitations.

## Run the backend locally

Requirements: Elixir, Erlang/OTP, PostgreSQL, and Node.js.

```powershell
cd backend
mix setup
mix phx.server
```

The development server is available at `http://localhost:4000`.

Open the Growly browser prototype at:

```text
http://localhost:4000/demo
```

Open the internal educational content editor at:

```text
http://localhost:4000/admin/content
```

Content Admin lets the team create and maintain skills and tasks before the
Flutter mobile application is built. It is an internal MVP tool and does not
have authentication yet, so it must not be exposed publicly.

Mobile API documentation is available at:

```text
http://localhost:4000/admin/api-docs
```

Product ecosystem demos:

- `http://localhost:4000/demo/curriculum`
- `http://localhost:4000/demo/workbook`
- `http://localhost:4000/qr/:token`

Content Admin now manages courses, units, lessons, skills, tasks, workbooks,
and workbook pages. Current content can be exported from
`http://localhost:4000/admin/content/export`.

The versioned Flutter-ready endpoints live under `/api/mobile/v1`. See
[`docs/mobile_api_contract.md`](docs/mobile_api_contract.md) for request and
response rules, Android emulator setup, child feedback behavior, and privacy
notes.

The demo includes:

- a child flow with math, reading, and logic tasks;
- progressive anti-frustration hints after mistakes;
- a parent dashboard with per-skill progress and recommendations;
- a three-area initial diagnostic;
- a safe reset button that clears only the demo child's progress.

This is the browser MVP used to validate the learning experience before the
Flutter mobile application and QR-linked paper workbooks are built.

## Run tests

```powershell
cd backend
mix test
```
