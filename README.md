# Growly

Growly is an educational platform for children aged 5–7. The first version
focuses on early math, reading, and logic skills, with a separate progress view
for parents.

## Current backend capabilities

- parent and child profiles;
- skills and learning tasks;
- backend-side answer grading;
- gentle feedback after mistakes: two hints, then deferred repetition;
- selection of the next age-appropriate task.

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

## Run tests

```powershell
cd backend
mix test
```
