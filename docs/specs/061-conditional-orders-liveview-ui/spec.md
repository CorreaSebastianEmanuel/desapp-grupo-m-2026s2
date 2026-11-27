# Conditional orders LiveView UI

## Outcome

Authenticated users can create, cancel, and inspect their conditional buy orders in the LiveView workspace. Connected views reflect committed order changes, and reconnects recover the authoritative persisted state.

## Acceptance

- [x] `/conditional-orders` loads only the authenticated user's orders and presents a creation form for player UUID, whole-token quantity, positive maximum unit price, and explicit UTC expiry. It does not choose an expiry automatically or reserve funds or inventory.
- [x] A valid submission creates an order through the conditional-order domain context. Invalid submissions retain safe, user-readable feedback and do not create an order.
- [x] The list shows each order's player ID, requested quantity, maximum unit price, creation and expiry times, persisted lifecycle state, and `expiry_reached` when true. Executed orders show actual unit price and total; rejected orders show the rejection reason.
- [x] Pending, unexpired orders can be cancelled by their owner. The view shows the authoritative result, including if evaluation or expiry wins a cancellation race. Terminal orders have no cancel action.
- [x] On a connected view, a PubSub order-change message causes an owner-scoped domain reload; event payload data is never treated as state. Initial mount after reconnect reloads from PostgreSQL so missed messages do not hide committed outcomes.
- [x] Authenticated users cannot see or change another user's order. The UI does not expose internal exceptions or storage diagnostics.

## Scope

- Implement the authenticated conditional-orders LiveView page, its create/cancel events and presentation, owner-scoped reloads, and focused LiveView tests.
- Use the existing order domain context and existing catalog records; keep lifecycle, validation, persistence, and notification rules in their current domain boundaries.

## Non-goals

- Changes to order lifecycle or purchase rules, API contracts, workers, quote evaluation, portfolio charts, player catalog features, push notifications, or responsive workspace redesign.
- Automatic expiry defaults, fund/inventory reservations, partial fills, or execution-time guarantees.

## Risk

- High: authenticated financial instructions and owner-scoped order details are presented in a new web surface. The changed application and test paths select ThinFlow's high tier; domain authorization and atomicity remain authoritative, and the UI must not trust PubSub payloads.

## Decisions

- Collect an explicit ISO-8601 UTC expiry and pass it to the domain unchanged; this follows TASK-059's no-default rule and avoids inventing browser-local timezone semantics.
- Accept a player UUID in the form and display that ID in the order list. Catalog selection/search is outside this task; the domain remains authoritative for player validity and initialization.
- Treat PubSub messages as owner-topic reload hints and always fetch current order state through `ConditionalOrders`; reconnect recovery comes from normal initial list loading.
