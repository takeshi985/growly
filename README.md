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
```

The future mobile client, content, and product documentation will live beside
`backend/` as the product grows.

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
