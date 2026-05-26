# Gen.UI.Audit Quick Start Guide

**Gen.UI.Audit** is a portable UI validation framework combining Playwright browser automation with Yumlog screen capture for comprehensive, pixel-perfect UI testing.

## Installation

### Prerequisites
- **PowerShell 5.1+** (Windows built-in) or **PowerShell Core 7+**
- **Node.js 18+** and npm 9+
- **FFmpeg** (auto-installed by Yumlog)

### Setup
```powershell
# 1. Install Node.js dependencies
cd Gen.UI.Audit
npm install

# 2. Install Playwright browsers
npm run install:browsers -- chromium

# 3. (Optional) Install all browsers for cross-browser testing
npx playwright install
```

## Basic Usage

### 1. Audit a Local HTML File
```powershell
# Run Playwright tests on local file
.\launchers\audit-ui.ps1 -Target "file:///C:/path/to/your/app.html"
```

### 2. Audit a Website
```powershell
# Run tests on live website
.\launchers\audit-ui.ps1 -Target "https://example.com"
```

### 3. Record UI Interaction Session
```powershell
# Capture screen while testing manually
.\launchers\yumlog.ps1 start -DurationSec 60 -OutFile ".\audit-results\videos\session.mp4"
```

### 4. Visual Validation with Yumlog
```powershell
# Capture screenshots at intervals during test
.\Skills\Capture-UIState.ps1 -TestName "LoginFlow" -Fps 2 -Duration 10
```

## Project Structure

```
Gen.UI.Audit/
├── Skills/                    # Reusable PowerShell modules
│   ├── Run-PlaywrightTest.ps1     # Execute Playwright tests
│   ├── Capture-UIState.ps1        # Yumlog screen capture integration
│   ├── Capture-Screens.ps1        # Embedded Yumlog screenshot capture
│   ├── Record-Screen.ps1          # Embedded Yumlog recording
│   ├── Run-FFmpeg.ps1             # Portable FFmpeg runner
│   └── Paperboy.ps1               # Half-step frame navigation helper
├── launchers/                 # User-facing commands
│   ├── audit-ui.ps1              # Main audit command
│   ├── yumlog.ps1                # Embedded Yumlog CLI
│   ├── install-yumlog.ps1        # Optional FFmpeg installer
│   └── record-terminals.ps1      # Terminal/window recorder
├── tests/                     # Playwright test templates
│   ├── ui-audit.template.spec.ts  # Base template
│   └── examples/                  # Example tests
│       └── yumlog-manager.spec.ts # Reference implementation
├── config/                    # Configuration
│   ├── audit-config.json          # Default settings
│   └── tools.json                 # Embedded Yumlog defaults
├── docs/                      # Documentation
│   ├── SESSION-AUDIT.md           # Complete session log
│   ├── QUICK-START.md             # This file
│   └── API-REFERENCE.md           # Command reference
├── package.json               # Node.js dependencies
└── playwright.config.ts       # Playwright configuration
```

## Core Commands

### `audit-ui.ps1`
**Main UI audit command** - Runs Playwright tests and generates reports

```powershell
.\launchers\audit-ui.ps1 `
    -Target "https://example.com" `
    -TestFile "tests/smoke-test.spec.ts" `
    -Browser "chromium" `
    -Headed $false `
    -Reporter "html"
```

**Parameters:**
- `-Target` - URL or file path to test
- `-TestFile` - Playwright test file (optional, uses template if not specified)
- `-Browser` - chromium, firefox, webkit, or all
- `-Headed` - Show browser window ($true) or headless ($false)
- `-Reporter` - html, list, json, or junit

### `yumlog.ps1`
**Record UI interaction** - Captures screen with embedded Yumlog

```powershell
.\launchers\yumlog.ps1 start `
    -DurationSec 30 `
    -Fps 10 `
    -OutFile ".\audit-results\videos\session.mp4"
```

**Parameters:**
- `start|get|count|size|config` - Yumlog action
- `-DurationSec` - Recording duration in seconds
- `-Fps` - Frames per second (10-30 recommended)
- `-OutFile` - Output video file path

### `record-terminals.ps1`
**Terminal/window recorder** - Records visible terminal windows and extracts Paperboy frames

```powershell
.\launchers\record-terminals.ps1 `
    -DurationSec 10 `
    -Depth 4 `
    -Fps 15
```

**Parameters:**
- `-DurationSec` - Recording duration in seconds
- `-Depth` - Paperboy extraction depth
- `-Fps` - Recording frames per second
- `-WindowTitle` - Optional window-title filter

## Writing Tests

### Test Template
```typescript
import { test, expect } from '@playwright/test';

test.describe('My App', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('https://example.com');
  });

  test('should load homepage', async ({ page }) => {
    await expect(page).toHaveTitle(/My App/);
    await expect(page.locator('h1')).toBeVisible();
  });

  test('should navigate to about page', async ({ page }) => {
    await page.click('a[href="/about"]');
    await expect(page).toHaveURL(/\/about/);
  });
});
```

### Generate Test from UI Interaction
```powershell
.\launchers\audit-ui.ps1 `
    -Target "https://example.com" `
    -TestFile "tests\ui-audit.template.spec.ts"
```

## Yumlog Integration

### Capture UI State During Test
```typescript
import { test } from '@playwright/test';
import { exec } from 'child_process';

test('user login flow with screen capture', async ({ page }) => {
  // Start Yumlog capture
  exec('pwsh -Command ".\\..\\Skills\\Record-Screen.ps1 -Fps 10 -DurationSec 30 -OutFile .\\audit-results\\videos\\login-flow.mp4"');
  
  // Perform test actions
  await page.goto('https://example.com/login');
  await page.fill('#username', 'testuser');
  await page.fill('#password', 'password123');
  await page.click('button[type="submit"]');
  
  // Verify login
  await expect(page.locator('.welcome-message')).toBeVisible();
  
  // Yumlog recording will complete automatically
});
```

### Visual Regression Testing
```powershell
# Capture baseline screenshots
.\Skills\Capture-UIState.ps1 `
    -TestName "Homepage" `
    -Url "https://example.com" `
    -Baseline $true

# Compare against baseline in future runs
.\Skills\Capture-UIState.ps1 `
    -TestName "Homepage" `
    -Url "https://example.com" `
    -CompareToBaseline $true
```

## Configuration

### `config/audit-config.json`
```json
{
  "playwright": {
    "defaultBrowser": "chromium",
    "headless": true,
    "timeout": 30000,
    "retries": 2
  },
  "yumlog": {
    "defaultFps": 10,
    "videoFormat": "mp4",
    "screenshotFormat": "png",
    "outputDir": "./audit-results"
  },
  "validation": {
    "accessibility": true,
    "performance": true,
    "visualRegression": false
  }
}
```

## Example Workflows

### 1. Quick Smoke Test
```powershell
# Test basic functionality
npx playwright test tests/ui-audit.template.spec.ts --headed
```

### 2. Full Regression Suite
```powershell
# Run all tests across all browsers
npx playwright test --project=chromium --project=firefox --project=webkit
```

### 3. Accessibility Audit
```powershell
# Focus on accessibility testing
.\launchers\audit-ui.ps1 -Target "https://example.com" -TestFile ".\tests\ui-audit.template.spec.ts" -Reporter list
```

### 4. Visual Regression
```powershell
# Capture baseline
.\Skills\Capture-UIState.ps1 -TestName "Dashboard" -Url "https://app.example.com/dashboard" -Baseline $true

# Run tests
npx playwright test

# Compare screenshot set sizes against the saved baseline
.\Skills\Capture-UIState.ps1 -TestName "Dashboard" -CompareToBaseline $true
```

### 5. Record User Session
```powershell
# Record manual testing session
.\launchers\yumlog.ps1 start -DurationSec 120 -Fps 15 -OutFile ".\audit-results\videos\user-session-$(Get-Date -Format 'yyyyMMdd-HHmmss').mp4"
```

## Troubleshooting

### Issue: Tests fail with timeout
**Solution:** Increase timeout in playwright.config.ts
```typescript
export default defineConfig({
  timeout: 60000, // 60 seconds
});
```

### Issue: Can't find Playwright browsers
**Solution:** Reinstall browsers
```powershell
npx playwright install --force
```

### Issue: FFmpeg not found
**Solution:** Run Yumlog install
```powershell
cd ..
.\launchers\install.ps1
cd Gen.UI.Audit
```

### Issue: UNC path errors
**Solution:** Copy Gen.UI.Audit to local drive
```powershell
Copy-Item \\network\path\Gen.UI.Audit C:\Temp\Gen.UI.Audit -Recurse
cd C:\Temp\Gen.UI.Audit
npm install
```

## Advanced Features

### Custom Test Selectors
```typescript
// Use data-testid for reliable selectors
await page.locator('[data-testid="submit-button"]').click();

// Use accessible role selectors
await page.getByRole('button', { name: 'Submit' }).click();

// Use text content
await page.getByText('Welcome back!').isVisible();
```

### Parallel Test Execution
```typescript
// Run tests in parallel (default)
export default defineConfig({
  fullyParallel: true,
  workers: 4, // Use 4 workers
});
```

### Test Fixtures
```typescript
// Create reusable test context
import { test as base } from '@playwright/test';

const test = base.extend({
  authenticatedPage: async ({ page }, use) => {
    await page.goto('https://example.com/login');
    await page.fill('#username', 'testuser');
    await page.fill('#password', 'password');
    await page.click('button[type="submit"]');
    await use(page);
  },
});

test('access protected page', async ({ authenticatedPage }) => {
  await authenticatedPage.goto('https://example.com/dashboard');
  await expect(authenticatedPage.locator('.dashboard')).toBeVisible();
});
```

## Best Practices

1. **Use Semantic Selectors:** Prefer `getByRole()`, `getByLabel()`, `getByText()` over CSS selectors
2. **Wait Automatically:** Playwright auto-waits, avoid explicit `setTimeout()`
3. **Isolate Tests:** Each test should be independent
4. **Capture Evidence:** Use Yumlog to record failing scenarios
5. **Organize Tests:** Group related tests with `test.describe()`
6. **Version Control:** Commit test files and baseline screenshots
7. **CI/CD Integration:** Run tests in your pipeline

## Resources

- [Playwright Documentation](https://playwright.dev)
- [Yumlog README](../README.md)
- [Session Audit Log](./SESSION-AUDIT.md)
- [API Reference](./API-REFERENCE.md)

## Next Steps

1. Copy `tests/ui-audit.template.spec.ts` to create your first test
2. Customize `config/audit-config.json` for your project
3. Run `npm test` to execute tests
4. View HTML report with `npx playwright show-report`
5. Integrate with CI/CD pipeline

---

**Need Help?** Check the [Session Audit](./SESSION-AUDIT.md) for detailed examples and troubleshooting steps.
