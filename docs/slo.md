# SLOs for Uptime Monitor

## Services to monitor
- https://example.com (student org site)
- https://api.github.com (public API)

## SLIs
- Availability SLI: Percentage of successful HTTP 200 responses.
- Latency SLI: 95th percentile response time measured from Prometheus histogram.

## Objectives
- Availability: 99.9% over 30 days
- Latency: p95 < 500 ms over 30 days

## Error budget
- 0.1% unavailability per 30 days (~43.2 minutes)

## Alerting policy (burn rate)
- Page if 2h window burn rate > 14.4 (fast burn)
- Ticket if 24h window burn rate > 6 (slow burn)

## Reporting
- Public status page (last 24h, 7d)
- Postmortems for any fast-burn page

## Out of Scope
- DNS uptime (assumed external).
- Client-side performance (only server-side monitored).