# Growly Mobile API Contract

Growly exposes a versioned child-safe API for the future Flutter application.

## Local base URLs

- Desktop and iOS simulator: `http://localhost:4000`
- Android emulator: `http://10.0.2.2:4000`

The Android emulator uses `10.0.2.2` to reach the development machine.

## Endpoints

### Health and demo bootstrap

- `GET /api/mobile/v1/health`
- `GET /api/mobile/v1/demo/bootstrap`

The health endpoint reports whether the mobile API process is available. The
demo bootstrap endpoint idempotently ensures the local MVP content exists and
returns the stable demo parent, child, and links for that child. It is intended
only for development and demos. Calling it never resets learning progress and
never returns task answers.

### Curriculum catalog and lesson map

- `GET /api/mobile/v1/catalog`
- `GET /api/mobile/v1/courses/:course_id`
- `GET /api/mobile/v1/courses/:course_id/map`
- `GET /api/mobile/v1/lessons/:lesson_id`
- `GET /api/mobile/v1/children/:child_id/lesson_map`

Only published courses are listed. Lesson task payloads include question,
options, difficulty, and position but never `correct_answer`. Child lesson
statuses are `available`, `in_progress`, `needs_review`, or `completed`.

### Learning session

`GET /api/mobile/v1/children/:child_id/session`

Returns child identity, a child-safe next task, progress summary,
recommendation count, and `session_state`. A task never contains
`correct_answer`, staged hints, or the final explanation.

### Submit a task answer

`POST /api/mobile/v1/children/:child_id/tasks/:task_id/answer`

```json
{
  "answer": {
    "selected_answer": "right",
    "hint_used": false
  }
}
```

The backend grades the answer. Use `feedback.message` as the main child-facing
copy. Show `feedback.hint` only when it is non-null. After
`action: "review_later"`, move to the returned `next_task`; never trap the
child on one difficult question.

### Parent progress

`GET /api/mobile/v1/children/:child_id/progress`

Render progress by skill, status labels, recommendations, and gently highlight
`needs_review`. Recommendation priority is `high`, `medium`, or `low`.

### Diagnostic

- `POST /api/mobile/v1/children/:child_id/diagnostic/start`
- `POST /api/mobile/v1/diagnostic_sessions/:session_id/tasks/:task_id/answer`

Continue until `completed` is true, then use `recommended_starting_area`,
`recommended_starting_skill_id`, and `recommended_message` to choose the first
learning route.

## Child UI rules

- Never expect or display `correct_answer`.
- Do not pre-display hints; use only the hint returned in feedback.
- Use friendly `feedback.message` wording instead of harsh failure states.
- Continue after `review_later`.

## Parent UI rules

- Show progress by concrete skill, not only levels played.
- Show recommendations sorted by priority.
- Present mistakes and review states as support opportunities, not punishment.

## Future authentication and privacy

Parent authentication will be added later. A child profile will be selected
after parent login. Collect the minimum child data required for learning, and
do not add advertising or third-party tracking to child mode.

Workbook QR links currently use the safe browser fallback `/qr/:token`. Future
Flutter builds may register `growly://workbook/:token` after authenticated child
context is available.
