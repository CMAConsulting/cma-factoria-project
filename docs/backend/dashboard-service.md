# Dashboard Service

## Overview
The Dashboard Service provides read‑only endpoints that expose system metrics and recent activity for the **Dashboard** micro‑frontend. It is implemented in the Quarkus backend (`apps/backend/dashboard-service`).

## Endpoints
| Method | Path | Description |
|--------|------|-------------|
| `GET`  | `/api/dashboard/metrics` | Returns aggregated metrics such as pending, processing, completed and failed command counts. |
| `GET`  | `/api/dashboard/activity` | Returns a list of recent activity items (commands started/completed, errors, notifications). |

## Security
All endpoints require a **Bearer JWT** token (`Authorization: Bearer <token>`). The token is validated by the Quarkus security layer.

## Data Model
The service re‑uses the OpenAPI schemas defined in `contracts/openapi/dashboard.yaml`:
- `DashboardMetrics`
- `DashboardActivity`
- `ActivityItem`

## Integration
The micro‑frontend `mfe-dashboard` consumes these endpoints via the shared API client generated from the OpenAPI contract.
