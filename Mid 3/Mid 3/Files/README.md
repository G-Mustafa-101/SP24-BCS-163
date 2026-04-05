# Task Sprint Pro

Task Sprint Pro is a Flutter task manager with due dates, repeating tasks,
subtask progress tracking, local notifications, and export options.

## Features

- Create, edit, complete, and delete tasks
- Add subtasks and track completion progress
- Support daily and weekly repeating tasks
- Schedule local notifications at the exact task due time
- Export tasks as CSV, PDF, or shareable email text

## Notifications

- Task reminders are scheduled for the task's selected due time
- Completed tasks and past-due tasks are not scheduled
- The app requests notification permissions during initialization and again
  before scheduling reminders
- Local timezone detection is used before scheduling notifications so reminders
  fire at the correct local time when available

Relevant implementation:
- [notification_service.dart](./lib/services/notification_service.dart)
- [task_editor_sheet.dart](./lib/widgets/task_editor_sheet.dart)

## PDF Export

The PDF export includes:

- Task title
- Description, or `No description` when empty
- Due date and time
- Repeat summary
- Progress percentage

Relevant implementation:
- [export_service.dart](./lib/services/export_service.dart)

## Verification Status

The following checks are already in place:

- Analyzer passes with `flutter analyze`
- Notification scheduling tests were added for the add-task flow and service logic

The following still need full runtime verification on device:

- End-to-end notification delivery on Android
- End-to-end PDF export and share flow

## Disk Space Note

Android builds in this project can fail when the `C:` drive is nearly full.
Common symptoms include Gradle, CMake, or Flutter compiler errors such as
`There is not enough space on the disk`.

Recommended cleanup commands:

```powershell
Remove-Item -Recurse -Force .\build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .\.dart_tool -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .\.gradle-user\caches -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .\.gradle-user\wrapper -ErrorAction SilentlyContinue
flutter clean
flutter pub get
```

If the drive is still low on space, also clear `%LOCALAPPDATA%\Temp` before
running `flutter run` again.

## Getting Started

```powershell
flutter pub get
flutter run
```
