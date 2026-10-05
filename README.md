# Gym Management Database

A relational database schema for a gym management system, built in MySQL. It models members, trainers, classes, membership packages, payments, workout plans, and class attendance, and includes views, a stored procedure, and role-based access control on top of the core schema.

## Tech Stack

- MySQL

## Schema Overview

| Table | Description | Key Relationships |
|---|---|---|
| `member` | Gym members — ID, contact info, name, date of birth, gender | Referenced by `payment`, `membership`, `attendance` |
| `trainer` | Trainers — ID, name, phone | Referenced by `class`, `workoutplan`, `attendance` |
| `class` | Scheduled group classes — ID, capacity, name, schedule time | FK: `trainerID` → `trainer` |
| `package` | Membership packages — ID, price, duration, name | Referenced by `membership` |
| `membership` | Tracks which package a member is enrolled in and for how long | FK: `memberID` → `member`, FK: `packageID` → `package` |
| `payment` | Payment records — ID, amount, date, method | FK: `memberID` → `member` |
| `workoutplan` | Trainer-assigned workout plans — ID, duration, plan name | FK: `trainerID` → `trainer` |
| `attendance` | Links a member, trainer, and class for a given session | FK: `memberID` → `member`, FK: `trainerID` → `trainer`, FK: `classID` → `class` |

## Views

- **`memberduration`** — active members (membership not yet ended or marked "Until Canceled"), with how many days they've been a member as of the current date.
- **`memberpackages`** — each member's package assignment, joined with the package name.
- **`male_members`** / **`female_members`** — members split out by gender.
- **`memberage`** — each member's current age, calculated from their date of birth.

## Stored Procedure

**`memberpackage(IN package_input VARCHAR)`** — returns every member enrolled in a given package.

```sql
CALL memberpackage('K1');
```

## Access Control

A restricted MySQL user (`gymstaff`) is created with `SELECT`-only privileges on the `member` table, separating day-to-day staff access from full administrative access to the database.

```sql
CREATE USER 'gymstaff'@'localhost' IDENTIFIED BY 'securepass';
GRANT SELECT ON member TO 'gymstaff'@'localhost';
```

## Example Queries

```sql
-- Members currently active, with how long they've been members
SELECT * FROM memberduration;

-- All members over 21
SELECT * FROM memberage WHERE age > 21;

-- Everyone enrolled in a specific package
CALL memberpackage('K1');
```

## Possible Improvements

- Store `date_ofbirth`, `startdate`/`enddate`, and `price` as proper `DATE`/`DECIMAL` types instead of `VARCHAR`, so date math and amount totals don't rely on string comparisons.
- Derive `gender` from a dedicated lookup or input field rather than the first digit of `memberID`, since that ties a business attribute to an identifier's formatting convention.
- Use a non-destructive setup script (so running it doesn't drop tables immediately after creating and populating them), separating schema creation from the exploratory `SELECT`/`DROP` statements used during development.
