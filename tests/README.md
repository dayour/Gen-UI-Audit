# Yumlog Manager UI Tests

Comprehensive Playwright test suite for the Yumlog Manager HTML interface.

## Prerequisites

- Node.js (v16 or higher)
- npm or yarn

## Installation

```powershell
# Install dependencies
npm install

# Install Playwright browsers
npx playwright install
```

## Running Tests

```powershell
# Run all tests
npm test

# Run tests with UI mode
npm run test:ui

# Run tests in headed mode (see browser)
npm run test:headed

# Run tests in debug mode
npm run test:debug

# Run specific test file
npx playwright test tests/yumlog-manager.spec.ts

# Run tests in a specific browser
npx playwright test --project=chromium
npx playwright test --project=firefox
npx playwright test --project=webkit
```

## Test Coverage

The test suite covers:

### Dark Mode Toggle
- Toggle functionality
- localStorage persistence
- State verification

### Quick Start Section
- Default input values
- Input value updates
- Record command generation
- Capture command generation

### Statistics Section
- Default statistics display
- Refresh statistics functionality
- PowerShell command reference

### Recordings Management
- Directory input functionality
- Browse recordings
- Open folder alerts
- File management guidance

### Configuration Section
- Config textarea
- Load configuration
- Generate save commands
- Default configuration display

### PowerShell Commands Reference
- All command examples
- Correct syntax verification

### About Section
- Project information
- Key features list
- License and repository links

### UI/UX
- All section headings present
- Welcome messages
- Alert boxes (info, warning)
- Page scrolling
- Responsive layout

## Test File Structure

```
tests/
└── yumlog-manager.spec.ts  # Main UI test suite
```

## CI/CD Integration

The tests are configured to run in CI environments with:
- Automatic retries on failure
- HTML reporter for results
- Trace collection on first retry
- Support for multiple browsers

## Debugging Tests

To debug a specific test:

```powershell
npx playwright test tests/yumlog-manager.spec.ts --debug
```

This will open Playwright Inspector for step-by-step debugging.

## Notes

- Tests use the local file:// protocol to test the HTML file
- Update the `pageUrl` in the test file if the file path changes
- Dark mode tests verify localStorage persistence across page reloads
- Alert and dialog interactions are properly handled with event listeners
