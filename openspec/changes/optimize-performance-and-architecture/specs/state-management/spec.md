## ADDED Requirements

### Requirement: Request Deduplication for Polling
The advertising live view state management SHALL implement request deduplication to prevent multiple simultaneous API calls when polling timer fires faster than request completion.

#### Scenario: Prevent overlapping requests
- **WHEN** polling timer fires at 10-second intervals
- **AND** previous API request is still pending
- **THEN** new request is queued instead of immediately executed
- **AND** duplicate requests are not sent

#### Scenario: Queue request after completion
- **WHEN** queued request exists and current request completes
- **THEN** single queued request executes (not multiple)
- **AND** most recent state is broadcast to UI

#### Scenario: Request timeout handling
- **WHEN** request exceeds 30-second timeout
- **THEN** pending request is cancelled
- **AND** queued request proceeds (not abandoned)

### Requirement: Provider Memory Management
The application state layer SHALL use `.autoDispose` on providers that cache data without active listeners to prevent memory leaks.

#### Scenario: Dispose unused campaign data
- **WHEN** user navigates away from campaign list and provider has no listeners
- **THEN** provider is automatically disposed after idle timeout
- **AND** cached campaign data is released from memory

#### Scenario: Retain active providers
- **WHEN** provider has active listeners (UI widget mounted)
- **THEN** provider is NOT disposed regardless of idle time
- **AND** state remains in memory while accessed

### Requirement: Efficient State Mutations
The state management layer SHALL update individual items in collections using immutable patterns with index-based operations instead of full list reconstruction via `.map()`.

#### Scenario: Update single alert in large collection
- **WHEN** alert status changes in a list of 1000 items
- **THEN** only affected alert is copied and replaced by index
- **AND** list reconstruction time is under 5ms

#### Scenario: No full list iteration for single change
- **WHEN** user marks one notification as read
- **THEN** system does NOT iterate entire notification list via `.map()`
- **AND** change is applied with `List<T>` copy and index assignment

## ADDED Requirements

### Requirement: Synchronous Permission Requests
The authentication layer SHALL request permissions without artificial delays between sequential requests.

#### Scenario: Rapid permission flow
- **WHEN** multiple permissions are required during app initialization
- **THEN** system requests permissions immediately in sequence
- **AND** no hardcoded `Future.delayed()` pauses are used
- **AND** permission flow completes in under 5 seconds

#### Scenario: Platform callback-driven timing
- **WHEN** user responds to permission dialog
- **THEN** system triggers next permission request via callback
- **AND** timing is determined by user action, not sleep timers

## MODIFIED Requirements

### Requirement: Advertiser Live Campaign State
The advertiser live campaign viewing state SHALL manage polling intervals efficiently, prevent overlapping requests, and update UI without unnecessary list reconstructions.

#### Scenario: Polling with request deduplication
- **WHEN** user views live campaigns with automatic 10-second refresh enabled
- **THEN** system prevents overlapping API calls via deduplication
- **AND** state updates are applied efficiently

#### Scenario: Alert marking without full list iteration
- **WHEN** user marks alert as read
- **THEN** state updates using index-based replacement
- **AND** UI rebuild is minimal

#### Scenario: Memory cleanup
- **WHEN** user navigates away from live view and returns
- **THEN** cached data is appropriately disposed and reloaded
- **AND** memory usage does not increase on repeated visits
