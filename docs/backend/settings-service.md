# Settings Service

## Overview
The Settings Service provides CRUD endpoints for managing application configuration, API settings and notification preferences. It is implemented in the Quarkus backend (`apps/backend/settings-service`).

## Endpoints
| Method | Path | Description |
|--------|------|-------------|
| `GET`  | `/api/settings` | Returns the complete settings object (general, API and notifications). |
| `GET`  | `/api/settings/general` | Returns the general settings subsection. |
| `PATCH`| `/api/settings/general` | Updates the general settings. |
| `GET`  | `/api/settings/api` | Returns the API configuration subsection. |
| `PATCH`| `/api/settings/api` | Updates the API configuration. |
| `GET`  | `/api/settings/notifications` | Returns the notification preferences subsection. |
| `PATCH`| `/api/settings/notifications` | Updates the notification preferences. |

## Security
All endpoints require a **Bearer JWT** token (`Authorization: Bearer <token>`). The token is validated by the Quarkus security layer.

## Data Model
The service re‑uses the OpenAPI schemas defined in `contracts/openapi/settings.yaml`:
- `GeneralSettings`
- `ApiSettings`
- `NotificationSettings`
- `SettingsResponse` (aggregates the three sections)

## Integration
The micro‑frontend `mfe-settings` consumes these endpoints via the shared API client generated from the OpenAPI contract.
