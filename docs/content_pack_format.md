# Growly Content Pack Format

Content Admin exports the current pack from `GET /admin/content/export`.

```json
{
  "version": 1,
  "courses": [{"title": "Подготовка к школе 5–7", "slug": "school-readiness-5-7"}],
  "units": [{"course_id": 1, "title": "Счёт", "slug": "math", "area": "math"}],
  "lessons": [{"unit_id": 1, "skill_id": 1, "title": "Счёт до 10", "slug": "count-to-10"}],
  "skills": [{"title": "Считает предметы до 10", "area": "math", "age_min": 5, "age_max": 7}],
  "tasks": [{"lesson_id": 1, "skill_id": 1, "question": "Где больше?", "options": {"left": "3", "right": "5"}}],
  "workbooks": [{"title": "Growly: первые шаги", "slug": "growly-first-steps"}],
  "workbook_pages": [{"workbook_id": 1, "lesson_id": 1, "page_number": 1, "qr_code_token": "growly-math-page-1"}]
}
```

IDs in the current export are repository-local references. A future importer
should resolve relationships through stable course/unit/lesson/workbook slugs,
skill titles, and task questions. Import must upsert and never delete content
unless an explicit destructive mode is introduced.
