# Copilot Instructions for Gen-UI-Audit

## Project Overview
Portable UI validation framework combining Playwright browser automation with Yumlog screen capture for pixel-perfect testing.

## Architecture
- `Skills/` - Core PowerShell modules
- `launchers/` - User-facing commands (audit-ui, record-session)
- `tests/` - Playwright TypeScript test suite
- `config/` - Framework configuration

## Code Style
- TypeScript for Playwright tests, PowerShell for automation
- Follow Playwright best practices (describe/test blocks)
- Multi-browser: chromium, firefox, webkit
- Portable design, self-contained
