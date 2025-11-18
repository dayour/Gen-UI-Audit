# Gen.UI.Audit API Reference

Complete command reference for all Skills modules and launcher scripts.

## Table of Contents

- [Launcher Scripts](#launcher-scripts)
  - [audit-ui.ps1](#audit-uips1)
- [Skills Modules](#skills-modules)
  - [Capture-UIState.ps1](#capture-uistateps1)
  - [Run-PlaywrightTest.ps1](#run-playwrighttestps1)
- [Configuration Files](#configuration-files)
  - [audit-config.json](#audit-configjson)
- [Test Templates](#test-templates)
  - [ui-audit.template.spec.ts](#ui-audittemplatespects)

---

## Launcher Scripts

### audit-ui.ps1

Main orchestrator for UI audit workflows. Combines Playwright testing with optional Yumlog screen recording.

**Location:** `launchers/audit-ui.ps1`

#### Syntax

```powershell
.\launchers\audit-ui.ps1 [-TargetUrl] <String> [[-Browser] <String>] [-Record] [-Headed] [-Debug]
```

#### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| TargetUrl | String | Yes | - | The URL or file path to test |
| Browser | String | No | chromium | Browser to use (chromium, firefox, webkit, all) |
| Record | Switch | No | false | Enable Yumlog screen recording during tests |
| Headed | Switch | No | false | Run browser in headed mode (visible) |
| Debug | Switch | No | false | Enable Playwright debug mode |

#### Returns

- Exit code 0 on success
- Exit code 1 on failure
- Creates audit results in timestamped directory

#### Examples

```powershell
# Basic audit of local HTML file
.\launchers\audit-ui.ps1 -TargetUrl ".\yumlog-manager.html"

# Audit with screen recording
.\launchers\audit-ui.ps1 -TargetUrl ".\yumlog-manager.html" -Record

# Test across all browsers in headed mode
.\launchers\audit-ui.ps1 -TargetUrl "https://example.com" -Browser all -Headed

# Debug mode with Firefox
.\launchers\audit-ui.ps1 -TargetUrl ".\app.html" -Browser firefox -Debug
```

#### Output Structure

```
audit-results/
  audit-<timestamp>/
    playwright-report/       # HTML test report
    test-results/           # Test artifacts and screenshots
    yumlog-recording.mp4    # Screen recording (if -Record used)
    baseline-screenshots/   # UI state captures
```

#### Workflow Steps

1. **Validate** - Check Playwright installation
2. **Prepare** - Create output directories
3. **Capture** - Take baseline screenshots with Yumlog
4. **Test** - Run Playwright tests
5. **Finalize** - Stop recording, open reports

---

## Skills Modules

### Capture-UIState.ps1

Integrates Yumlog screenshot capture for UI state baseline and comparison.

**Location:** `Skills/Capture-UIState.ps1`

#### Syntax

```powershell
. .\Skills\Capture-UIState.ps1
Capture-UIState [-OutputDir] <String> [-Duration] <Int32> [[-Fps] <Int32>] [-Baseline]
```

#### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| OutputDir | String | Yes | - | Directory to save screenshots |
| Duration | Int32 | Yes | - | How long to capture (seconds) |
| Fps | Int32 | No | 1 | Screenshots per second |
| Baseline | Switch | No | false | Mark as baseline capture |

#### Returns

- Hashtable with:
  - `Success` (Boolean)
  - `ScreenshotCount` (Int32)
  - `OutputDir` (String)
  - `ComparisonResult` (String) - "baseline", "match", or "changed"

#### Examples

```powershell
# Capture baseline (first run)
. .\Skills\Capture-UIState.ps1
$result = Capture-UIState -OutputDir ".\baseline" -Duration 5 -Fps 1 -Baseline

# Capture for comparison
$result = Capture-UIState -OutputDir ".\comparison" -Duration 5 -Fps 1

# High-frequency capture
$result = Capture-UIState -OutputDir ".\detailed" -Duration 10 -Fps 2
```

#### Visual Comparison Logic

The function compares screenshots by file size:
- **Match**: Within 5% size difference from baseline
- **Changed**: Greater than 5% size difference
- **Baseline**: First capture, nothing to compare

#### Dependencies

- Yumlog `Skills/Capture-Screens.ps1`
- FFmpeg (installed via Yumlog)

---

### Run-PlaywrightTest.ps1

Execute Playwright tests with configurable options.

**Location:** `Skills/Run-PlaywrightTest.ps1`

#### Syntax

```powershell
. .\Skills\Run-PlaywrightTest.ps1
Run-PlaywrightTest [-TestFile] <String> [[-Browser] <String>] [-Headed] [-Debug] [-UI]
```

#### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| TestFile | String | Yes | - | Path to test file or directory |
| Browser | String | No | chromium | Browser(s): chromium, firefox, webkit, all |
| Headed | Switch | No | false | Run in headed mode (visible browser) |
| Debug | Switch | No | false | Enable debug mode (pauses execution) |
| UI | Switch | No | false | Launch Playwright UI mode |

#### Returns

- Hashtable with:
  - `Success` (Boolean)
  - `ExitCode` (Int32)
  - `ReportPath` (String)
  - `Browser` (String)

#### Examples

```powershell
# Run all tests in chromium (headless)
. .\Skills\Run-PlaywrightTest.ps1
$result = Run-PlaywrightTest -TestFile ".\tests"

# Run specific test file in Firefox (headed)
$result = Run-PlaywrightTest -TestFile ".\tests\login.spec.ts" -Browser firefox -Headed

# Debug mode for troubleshooting
$result = Run-PlaywrightTest -TestFile ".\tests\failing.spec.ts" -Debug

# Interactive UI mode
$result = Run-PlaywrightTest -TestFile ".\tests" -UI

# Test all browsers
$result = Run-PlaywrightTest -TestFile ".\tests" -Browser all
```

#### Test Execution Modes

| Mode | Flag | Use Case |
|------|------|----------|
| Headless | (default) | CI/CD, automated testing |
| Headed | -Headed | Visual debugging, development |
| Debug | -Debug | Step through tests, inspect failures |
| UI | -UI | Interactive test development |

#### Output

- Console output with test results
- HTML report at `playwright-report/index.html`
- Test artifacts in `test-results/`
- Screenshots on failures (automatic)

---

## Configuration Files

### audit-config.json

Central configuration file for Gen.UI.Audit framework.

**Location:** `config/audit-config.json`

#### Structure

```json
{
  "playwright": {
    "browser": "chromium",
    "timeout": 30000,
    "retries": 2
  },
  "yumlog": {
    "fps": 1,
    "formats": ["png"],
    "output": "audit-results"
  },
  "validation": {
    "accessibility": true,
    "performance": true
  },
  "reports": {
    "html": true,
    "json": true
  }
}
```

#### Sections

**playwright**
- `browser` (String): Default browser (chromium, firefox, webkit)
- `timeout` (Int32): Default timeout in milliseconds
- `retries` (Int32): Test retry count on failure

**yumlog**
- `fps` (Int32): Screenshots per second
- `formats` (Array): Image formats (png, jpg)
- `output` (String): Output directory for captures

**validation**
- `accessibility` (Boolean): Enable accessibility checks
- `performance` (Boolean): Enable performance metrics

**reports**
- `html` (Boolean): Generate HTML report
- `json` (Boolean): Generate JSON report

#### Usage

```powershell
# Read configuration
$config = Get-Content ".\config\audit-config.json" | ConvertFrom-Json

# Use in scripts
$browser = $config.playwright.browser
$fps = $config.yumlog.fps
```

---

## Test Templates

### ui-audit.template.spec.ts

Base template for creating UI audit tests.

**Location:** `tests/ui-audit.template.spec.ts`

#### Structure

The template includes test sections for:

1. **Basic Page Load Tests**
   - Page loads successfully
   - Valid page structure

2. **Navigation Tests**
   - Page transitions
   - URL routing

3. **Form Interaction Tests**
   - Input fields
   - Form validation

4. **Button and Click Tests**
   - Interactive elements
   - Event handling

5. **Accessibility Tests**
   - Heading hierarchy
   - ARIA labels

6. **Responsive Design Tests**
   - Mobile viewport
   - Tablet viewport

7. **Performance Tests**
   - Load time
   - Resource metrics

8. **Visual Regression Tests**
   - Screenshot comparison
   - Pixel diff tolerance

9. **Dark Mode Tests** (optional)
   - Theme toggling
   - Persistence

10. **Error Handling Tests**
    - Network errors
    - Edge cases

11. **Security Tests**
    - HTTPS enforcement
    - Secure headers

#### Usage

```powershell
# Copy template for new project
Copy-Item ".\tests\ui-audit.template.spec.ts" ".\tests\myapp.spec.ts"

# Edit myapp.spec.ts:
# 1. Update pageUrl
# 2. Customize test.describe()
# 3. Enable/modify tests for your app
# 4. Remove test.skip() from relevant tests

# Run your tests
npx playwright test myapp.spec.ts
```

#### Best Practices (from template)

1. Use semantic selectors (`getByRole`, `getByLabel`, `getByText`)
2. Rely on auto-waiting (avoid explicit timeouts)
3. Isolate tests (each should be independent)
4. Group with `test.describe()`
5. Use `test.beforeEach()` for setup
6. Add `data-testid` for reliable selectors
7. Test user flows, not implementation
8. Keep tests readable
9. Use meaningful descriptions
10. Leverage automatic screenshots on failures

---

## Common Workflows

### Complete UI Audit

```powershell
# 1. Run full audit with recording
.\launchers\audit-ui.ps1 -TargetUrl ".\app.html" -Record -Browser all

# 2. Review results
# - Open playwright-report/index.html
# - Check yumlog-recording.mp4
# - Compare baseline screenshots
```

### Test Development

```powershell
# 1. Create test from template
Copy-Item ".\tests\ui-audit.template.spec.ts" ".\tests\newapp.spec.ts"

# 2. Run in UI mode for development
. .\Skills\Run-PlaywrightTest.ps1
Run-PlaywrightTest -TestFile ".\tests\newapp.spec.ts" -UI

# 3. Debug failing tests
Run-PlaywrightTest -TestFile ".\tests\newapp.spec.ts" -Debug -Headed
```

### CI/CD Integration

```powershell
# Headless run for automated pipeline
.\launchers\audit-ui.ps1 -TargetUrl $env:TEST_URL -Browser chromium

# Exit code indicates pass/fail
if ($LASTEXITCODE -ne 0) {
    throw "UI audit failed"
}
```

### Visual Regression Testing

```powershell
# 1. Capture baseline
. .\Skills\Capture-UIState.ps1
Capture-UIState -OutputDir ".\baseline" -Duration 5 -Baseline

# 2. Make UI changes
# ... modify your UI ...

# 3. Compare against baseline
Capture-UIState -OutputDir ".\comparison" -Duration 5

# 4. Check ComparisonResult
# "match" or "changed"
```

---

## Environment Variables

Gen.UI.Audit respects these environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| PLAYWRIGHT_BROWSERS_PATH | Playwright browser install location | System default |
| TEST_URL | Default URL for testing | None |
| AUDIT_OUTPUT | Output directory override | audit-results |

---

## Troubleshooting

### Common Issues

**"Cannot find module '@playwright/test'"**
```powershell
# Install dependencies
npm install
```

**"No tests found"**
```powershell
# Check test file path
Get-ChildItem ".\tests\*.spec.ts"
```

**"FFmpeg not found"**
```powershell
# Install via Yumlog
..\..\launchers\install.ps1
```

**"Browser not installed"**
```powershell
# Install Playwright browsers
npx playwright install
```

### Debug Tips

1. Use `-Debug` flag to step through tests
2. Use `-Headed` to see browser actions
3. Check `test-results/` for failure screenshots
4. Review console output for error messages
5. Increase timeout in `playwright.config.ts` for slow pages

---

## Advanced Usage

### Custom Reporters

Edit `playwright.config.ts`:

```typescript
reporter: [
  ['html'],
  ['json', { outputFile: 'test-results.json' }],
  ['junit', { outputFile: 'test-results.xml' }]
]
```

### Parallel Execution

```powershell
# Control workers in playwright.config.ts
workers: process.env.CI ? 1 : 4
```

### Screenshot Options

```typescript
// In tests
await expect(page).toHaveScreenshot('name.png', {
  fullPage: true,
  maxDiffPixels: 100,
  threshold: 0.2
});
```

### Global Setup

Create `tests/global-setup.ts`:

```typescript
import { chromium } from '@playwright/test';

async function globalSetup() {
  // Runs once before all tests
  console.log('Global setup...');
}

export default globalSetup;
```

---

## Version Compatibility

- **PowerShell**: 5.1+ or PowerShell Core 7+
- **Node.js**: 16+
- **Playwright**: 1.40+
- **FFmpeg**: 7.0+

---

## See Also

- [README.md](../README.md) - Overview and getting started
- [QUICK-START.md](docs/QUICK-START.md) - Quick start guide
- [SESSION-AUDIT.md](docs/SESSION-AUDIT.md) - Development history
- [Playwright Documentation](https://playwright.dev/docs/intro) - Official Playwright docs
- [Yumlog README](../../README.md) - Parent Yumlog project

---

*Last Updated: [Auto-generated from Gen.UI.Audit framework]*
