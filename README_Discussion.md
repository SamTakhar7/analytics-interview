# Analytics Modelling Decisions & Discussion Notes

This document provides additional context for the modelling decisions made in this exercise.
It is intended to support the follow-up discussion and to explain how the gold-layer models align
with the original requirements and discussion prompts.

---

## Overview of the Gold Layer

I produced **three gold models**, each at a different grain, designed to support flexible and
reliable KPI computation in a BI tool without requiring complex downstream logic.

| Model | Grain | Purpose |
|------|------|--------|
| `gold_user_activity_events` | One row per user activity event | Unified, enriched activity layer |
| `gold_user_sessions` | One row per user per session | Centralised sessionisation logic |
| `gold_org_license_utilisation_daily` | One row per org per day | Licence utilisation inputs |

This separation allows each concern (events, sessions, licensing) to be reasoned about
independently while remaining composable in BI.

---

## KPI Support and BI Computation

The gold layer was designed so that **BI tools only need simple aggregations**
(counts, distinct counts, averages), rather than window functions or complex joins.

### Active Users (DAU / WAU / MAU)
- Source: `gold_user_activity_events`
- Logic: `count(distinct user_id)` filtered to `is_billable_user_activity = true`
- Supports arbitrary time windows and slicing by organisation or user.

### Number of Sessions per User
- Source: `gold_user_sessions`
- Logic: `count(*)` per user over `session_start_timestamp`
- Sessionisation logic is fully centralised in dbt.

### Session Length
- Source: `gold_user_sessions.session_length_minutes`
- Defined as `max(event_timestamp) - min(event_timestamp)`
- Assumption documented explicitly to avoid ambiguity.

### Number of Transformations Over Time
- Source: `gold_user_activity_events`
- Logic: count of rows where `event_type = 'transformation'`
- Sliceable by `transformation_type` (toolbar vs research).

### Licence Utilisation %
- Source: `gold_org_license_utilisation_daily`
- Logic: `active_user_count / contracted_licences`
- Calculated in BI rather than dbt to preserve flexibility and surface edge cases.

---

## Sessionisation Design

Sessions are derived using a **30-minute inactivity threshold**, applied across all user activity types.

**Key decisions:**
- Sessions are user-scoped, not device-scoped.
- Gaps ≤ 30 minutes are treated as continuous engagement.
- A new session begins when the inactivity gap exceeds 30 minutes.
- Session length is derived from observed timestamps rather than inferred durations.

---

## Inclusion and Exclusion Logic

The unified activity model retains all activity but introduces an explicit flag:

`is_billable_user_activity`

This allows:
- Internal employee and unlicensed activity to be retained for auditing or debugging.
- Usage KPIs to be cleanly filtered in BI without data duplication.

---

## Licence Utilisation: Assumptions and Edge Cases

This model exposes **inputs**, not a final KPI.

**Assumptions:**
- `contracted_licences` represents the organisation’s current contract state.

**Known limitations:**
- Historical licence changes are not modelled.
- Utilisation may exceed 100% when viewed historically.

**Production approach:**
- Snapshot organisation contracts (SCD / dbt snapshots).
- Join usage to contract state on an as-of basis.

---

## Testing and Validation Approach

Validation focused on:
- Logical inspection of session boundaries
- Reasoned checks of counts and distributions
- Direct inspection of gold table outputs

**dbt tests to add:**
- `not_null` on primary keys and timestamps
- Uniqueness on `(user_id, session_number)`
- Accepted values for event types
- Custom tests for non-negative session lengths and licence counts

---

## Scalability Considerations

Key challenges:
- Cost of window functions for sessionisation
- Growth of event-level data

Mitigations:
- Incremental session models
- Partitioning/clustering by user and date
- Pre-aggregated daily facts

---

## Historical Accuracy for Users and Organisations

Current-state silver tables limit historical reporting.

**Solution:**
- Version users and organisations using SCDs or snapshots.
- Join activity to the correct historical version.

---

## Handling Email and PII

Approach:
- Separate identity from behaviour
- Use surrogate keys or hashed identifiers
- Control access via views or BI permissions

---

## Notes on the Silver Layer

The silver layer was clean and fit for purpose.

Potential improvements:
- Additional documentation of deduplication strategy
- Stronger constraints and tests
- Further conformance of transformation tables

---

## Summary

The modelling approach prioritised:
- Clear grain definitions
- Centralised complexity
- BI-friendly structures
- Explicit assumptions
- Flexibility for future evolution
