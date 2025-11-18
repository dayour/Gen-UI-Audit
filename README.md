# Gen.UI.Audit

**Portable UI Validation Framework** - Combining Playwright browser automation with Yumlog screen capture for comprehensive, pixel-perfect UI testing.

## Overview

Gen.UI.Audit is a self-contained, portable framework for auditing, validating, and testing any web UI. It combines:

- **Playwright** - Industry-standard browser automation and testing
- **Yumlog** - High-fidelity screen capture and recording
- **AI Integration** - Visual analysis and reasoning over UI state
- **PowerShell** - Cross-platform scripting and automation

## Features

✅ **Automated Browser Testing** - Full Playwright test suite with 28+ test patterns
✅ **Visual Validation** - Pixel-perfect screenshot capture and comparison
✅ **Session Recording** - Record entire UI interaction sessions
✅ **Multi-Browser** - Test on Chromium, Firefox, and WebKit
✅ **Dark Mode Support** - Validated with theme switching tests
✅ **Accessibility Auditing** - WCAG compliance checks
✅ **Portable** - Self-contained, works anywhere
✅ **AI-Ready** - Structured output for AI analysis

## Quick Start

### Installation
```powershell
# 1. Clone or copy Gen.UI.Audit to your machine
cd Gen.UI.Audit

# 2. Install Node.js dependencies
npm install

# 3. Install Playwright browsers
npx playwright install chromium

# Done! Ready to audit UIs
```

### Basic Usage
```powershell
# Audit a website
.\launchers\audit-ui.ps1 -Target "https://example.com"

# Audit a local HTML file
.\launchers\audit-ui.ps1 -Target "file:///C:/path/to/app.html" -Headed

# Run with screen recording
.\launchers\audit-ui.ps1 -Target "https://example.com" -RecordVideo
```

## Project Structure

```
Gen.UI.Audit/
├── Skills/                      # Core functionality modules
│   ├── Run-PlaywrightTest.ps1       # Execute Playwright tests
│   ├── Capture-UIState.ps1          # Yumlog screenshot integration
│   └── (more modules)
├── launchers/                   # User-facing commands
│   ├── audit-ui.ps1                 # Main audit command
│   ├── record-session.ps1           # Record UI sessions
│   └── validate-ui.ps1              # Run validation suite
├── tests/                       # Playwright test suite
│   ├── ui-audit.template.spec.ts    # Test template
│   ├── examples/                    # Example tests
│   │   └── yumlog-manager.spec.ts   # Reference implementation (28 tests)
│   └── README.md
├── config/                      # Configuration
│   └── audit-config.json            # Framework settings
├── docs/                        # Documentation
│   ├── SESSION-AUDIT.md             # Complete session log & learnings
│   ├── QUICK-START.md               # Getting started guide
│   └── API-REFERENCE.md             # Command reference
├── package.json                 # Node.js dependencies
├── playwright.config.ts         # Playwright configuration
└── README.md                    # This file
```

## Commands

### Main Commands

```powershell
# UI Audit (main command)
.\launchers\audit-ui.ps1 -Target <url> [-Browser chromium|firefox|webkit|all] [-Headed] [-RecordVideo]

# Record UI Session
.\launchers\record-session.ps1 -Url <url> -Duration <seconds>

# Run Validation Suite
.\launchers\validate-ui.ps1 -Target <url> -Checks @('accessibility', 'performance')
```

### Test Commands

```powershell
# Run all tests
npm test

# Run tests with visible browser
npm run test:headed

# Run tests in UI mode
npm run test:ui

# Run tests in debug mode
npm run test:debug

# Run specific browser
npx playwright test --project=chromium

# Generate HTML report
npx playwright test --reporter=html
npx playwright show-report
```

## Example Workflow

### 1. Create Baseline Screenshots
```powershell
.\Skills\Capture-UIState.ps1 `
    -TestName "Homepage" `
    -Url "https://example.com" `
    -Baseline $true `
    -Fps 2 `
    -Duration 10
```

### 2. Run Automated Tests
```powershell
.\launchers\audit-ui.ps1 `
    -Target "https://example.com" `
    -Browser all `
    -Headed $false
```

### 3. Compare Visual Changes
```powershell
.\Skills\Capture-UIState.ps1 `
    -TestName "Homepage" `
    -CompareToBaseline $true
```

### 4. Record Session for Review
```powershell
.\launchers\record-session.ps1 `
    -Url "https://example.com" `
    -Duration 60 `
    -Fps 15 `
    -OutFile ".\audit-results\session.mp4"
```

## Test Results

The framework includes a complete reference implementation:

**Yumlog Manager UI Test Suite**
- ✅ 28/28 tests passing
- ⏱️ 3.4 seconds execution time
- 🔄 12 parallel workers
- 🌐 Multi-browser support
- 🎨 Dark mode validation
- ♿ Accessibility checks

Test categories:
- Page loading & navigation
- Dark mode toggle & persistence
- Input field validation
- Button click handlers
- Alert/dialog handling
- Section visibility
- Scrolling & responsiveness
- Configuration management
- PowerShell command reference
- About & documentation sections

## Configuration

Edit `config/audit-config.json` to customize:

```json
{
  "playwright": {
    "defaultBrowser": "chromium",
    "timeout": 30000,
    "retries": 2
  },
  "yumlog": {
    "defaultFps": 10,
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

## Writing Custom Tests

Create a new test file in `tests/`:

```typescript
import { test, expect } from '@playwright/test';

test.describe('My Custom Audit', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('https://example.com');
  });

  test('should validate homepage', async ({ page }) => {
    await expect(page).toHaveTitle(/Example/);
    await expect(page.locator('h1')).toBeVisible();
  });
});
```

Run your test:
```powershell
.\Skills\Run-PlaywrightTest.ps1 -TestFile "tests/my-custom-audit.spec.ts" -Headed
```

## Integration with Yumlog

Gen.UI.Audit is built on top of Yumlog and has access to all its capabilities:

```powershell
# Screen Recording
& "$yumlogRoot\launchers\record.ps1" -Fps 30 -DurationSec 60 -OutFile "recording.mp4"

# Screenshot Capture
& "$yumlogRoot\launchers\capture.ps1" -Fps 2 -DurationSec 10 -OutDir "screenshots"

# CLI Operations
& "$yumlogRoot\launchers\yumlog.ps1" count
& "$yumlogRoot\launchers\yumlog.ps1" size
& "$yumlogRoot\launchers\yumlog.ps1" config
```

## Portability

Gen.UI.Audit is designed to be fully portable:

1. **Self-Contained:** All dependencies in node_modules
2. **No Installation:** Copy folder and run
3. **UNC Path Support:** Works on network shares (with workarounds)
4. **Cross-Platform:** PowerShell Core on Windows, macOS, Linux
5. **Browser Included:** Playwright downloads browsers automatically

### Moving Gen.UI.Audit

```powershell
# Copy entire folder
Copy-Item Gen.UI.Audit C:\MyProjects\ProjectX\audit -Recurse

# Or use from network share
\\fileserver\share\Gen.UI.Audit\launchers\audit-ui.ps1 -Target "https://myapp.com"
```

## Advanced Features

### Visual Regression Testing
```powershell
# Capture baseline
.\Skills\Capture-UIState.ps1 -TestName "LoginPage" -Url "https://app.com/login" -Baseline

# Run tests
npm test

# Compare changes
.\Skills\Capture-UIState.ps1 -TestName "LoginPage" -CompareToBaseline
```

### Multi-Browser Testing
```powershell
# Test across all browsers
.\launchers\audit-ui.ps1 -Target "https://example.com" -Browser all
```

### CI/CD Integration
```yaml
# .github/workflows/ui-audit.yml
- name: Run UI Audit
  run: |
    cd Gen.UI.Audit
    npm install
    npx playwright install --with-deps chromium
    npm test
```

## Troubleshooting

### Issue: UNC path not supported
**Solution:** Copy to local drive or use mapped drive

### Issue: Playwright browsers not found
**Solution:** Run `npx playwright install`

### Issue: Tests timeout
**Solution:** Increase timeout in `playwright.config.ts`

### Issue: FFmpeg not found
**Solution:** Run parent Yumlog `.\launchers\install.ps1`

## Documentation

- 📘 [Quick Start Guide](./docs/QUICK-START.md) - Get started in minutes
- 📋 [Session Audit Log](./docs/SESSION-AUDIT.md) - Complete development history
- 📖 [API Reference](./docs/API-REFERENCE.md) - Detailed command reference
- 🧪 [Test README](./tests/README.md) - Test suite documentation

## Dependencies

### Required
- **Node.js 16+** and npm
- **PowerShell 5.1+** or PowerShell Core 7+

### Included
- **@playwright/test 1.40.0** - Browser automation
- **FFmpeg 7.1.1** - Screen capture (via Yumlog)
- **Chromium** - Test browser (auto-installed)

## Use Cases

- ✅ **Pre-Deployment Validation** - Catch UI issues before release
- ✅ **Regression Testing** - Ensure changes don't break existing UI
- ✅ **Accessibility Audits** - WCAG compliance validation
- ✅ **Cross-Browser Testing** - Verify UI works everywhere
- ✅ **Visual Documentation** - Record UI interactions for demos
- ✅ **Bug Reproduction** - Capture exact steps that cause issues
- ✅ **AI Training Data** - Generate labeled UI interaction datasets

## Roadmap

- [ ] AI visual analysis integration
- [ ] Automated test generation from recordings
- [ ] Performance metrics collection
- [ ] Mobile device emulation
- [ ] API endpoint validation
- [ ] Screenshot diff visualization
- [ ] Natural language test descriptions

## License

MIT License - Same as Yumlog parent project

## Credits

Built on top of **Darbot Yumlog** - PowerShell-based screen capture and recording utility.

Powered by:
- **Playwright** - Microsoft
- **FFmpeg** - FFmpeg team
- **PowerShell** - Microsoft

---

**Gen.UI.Audit** - Because every pixel matters. 🎨🔍
