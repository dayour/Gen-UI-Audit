import { test, expect } from '@playwright/test';

/**
 * Comprehensive Playwright test suite for Yumlog Manager HTML interface
 * Tests all UI elements, interactions, and dark mode functionality
 */

test.describe('Yumlog Manager UI', () => {
  // Use the file:// protocol for local HTML file
  const pageUrl = 'file:///C:/Temp/YumlogTest/yumlog-manager.html';

  test.beforeEach(async ({ page }) => {
    // Navigate to the HTML file before each test
    await page.goto(pageUrl);
  });

  test('should load the page and display correct title', async ({ page }) => {
    await expect(page).toHaveTitle('Yumlog Manager');
    await expect(page.getByRole('heading', { name: 'Yumlog Manager', level: 1 })).toBeVisible();
  });

  test.describe('Dark Mode Toggle', () => {
    test('should toggle dark mode on and off', async ({ page }) => {
      const body = page.locator('body');
      const darkModeCheckbox = page.locator('#darkModeToggle');

      // Initially should be in light mode
      await expect(body).not.toHaveClass(/dark-mode/);
      await expect(darkModeCheckbox).not.toBeChecked();

      // Enable dark mode - click the label to trigger the checkbox
      await page.locator('.toggle-switch').click();
      await expect(body).toHaveClass(/dark-mode/);
      await expect(darkModeCheckbox).toBeChecked();

      // Disable dark mode
      await page.locator('.toggle-switch').click();
      await expect(body).not.toHaveClass(/dark-mode/);
      await expect(darkModeCheckbox).not.toBeChecked();
    });

    test('should persist dark mode preference in localStorage', async ({ page }) => {
      const darkModeCheckbox = page.locator('#darkModeToggle');

      // Enable dark mode
      await page.locator('.toggle-switch').click();
      
      // Verify localStorage was set
      const darkModeValue = await page.evaluate(() => localStorage.getItem('darkMode'));
      expect(darkModeValue).toBe('true');

      // Reload page and verify dark mode persists
      await page.reload();
      const body = page.locator('body');
      await expect(body).toHaveClass(/dark-mode/);
      await expect(darkModeCheckbox).toBeChecked();
    });
  });

  test.describe('Quick Start Section', () => {
    test('should have correct default values in input fields', async ({ page }) => {
      const fpsInput = page.getByLabel('FPS (Frames Per Second)');
      const durationInput = page.getByLabel('Duration (Seconds)');
      const outputPathInput = page.getByLabel('Output Path');

      await expect(fpsInput).toHaveValue('30');
      await expect(durationInput).toHaveValue('10');
      await expect(outputPathInput).toHaveValue('./yumlogs/yumlog.mp4');
    });

    test('should update input values correctly', async ({ page }) => {
      const fpsInput = page.getByLabel('FPS (Frames Per Second)');
      const durationInput = page.getByLabel('Duration (Seconds)');
      const outputPathInput = page.getByLabel('Output Path');

      // Update FPS
      await fpsInput.fill('60');
      await expect(fpsInput).toHaveValue('60');

      // Update Duration
      await durationInput.fill('20');
      await expect(durationInput).toHaveValue('20');

      // Update Output Path
      await outputPathInput.fill('./custom/path.mp4');
      await expect(outputPathInput).toHaveValue('./custom/path.mp4');
    });

    test('should generate record command with correct values', async ({ page }) => {
      const fpsInput = page.getByLabel('FPS (Frames Per Second)');
      const durationInput = page.getByLabel('Duration (Seconds)');
      const outputPathInput = page.getByLabel('Output Path');
      const generateButton = page.getByRole('button', { name: 'Generate Record Command' });

      // Set custom values
      await fpsInput.fill('25');
      await durationInput.fill('15');
      await outputPathInput.fill('./test.mp4');

      // Click generate button
      await generateButton.click();

      // Verify command output appears
      const commandOutput = page.locator('#commandOutput');
      await expect(commandOutput).toBeVisible();
      await expect(commandOutput).toContainText('.\\launchers\\record.ps1 -Fps 25 -DurationSec 15 -OutFile "./test.mp4"');
    });

    test('should generate capture command with correct values', async ({ page }) => {
      const fpsInput = page.getByLabel('FPS (Frames Per Second)');
      const durationInput = page.getByLabel('Duration (Seconds)');
      const generateButton = page.getByRole('button', { name: 'Generate Capture Command' });

      // Set custom values
      await fpsInput.fill('5');
      await durationInput.fill('30');

      // Click generate button
      await generateButton.click();

      // Verify command output appears
      const commandOutput = page.locator('#commandOutput');
      await expect(commandOutput).toBeVisible();
      await expect(commandOutput).toContainText('.\\launchers\\capture.ps1 -Fps 5 -DurationSec 30');
    });
  });

  test.describe('Statistics Section', () => {
    test('should display default statistics', async ({ page }) => {
      await expect(page.getByText('Total Recordings').locator('..')).toContainText('0');
      await expect(page.getByText('Total Size').locator('..')).toContainText('0 MB');
      await expect(page.getByText('Latest Recording').locator('..')).toContainText('N/A');
    });

    test('should show alert when clicking Refresh Statistics', async ({ page }) => {
      page.on('dialog', async dialog => {
        expect(dialog.type()).toBe('alert');
        expect(dialog.message()).toContain('yumlog.ps1 count');
        expect(dialog.message()).toContain('yumlog.ps1 size');
        expect(dialog.message()).toContain('yumlog.ps1 get');
        await dialog.accept();
      });

      await page.getByRole('button', { name: 'Refresh Statistics' }).click();
    });

    test('should display PowerShell commands for statistics', async ({ page }) => {
      const statsSection = page.locator('.section').filter({ hasText: 'Statistics' });
      await expect(statsSection).toContainText('.\\launchers\\yumlog.ps1 count');
      await expect(statsSection).toContainText('.\\launchers\\yumlog.ps1 size');
      await expect(statsSection).toContainText('.\\launchers\\yumlog.ps1 get');
    });
  });

  test.describe('Recordings Management Section', () => {
    test('should have default recordings directory', async ({ page }) => {
      const dirInput = page.getByLabel('Recordings Directory');
      await expect(dirInput).toHaveValue('./yumlogs');
    });

    test('should update recordings directory value', async ({ page }) => {
      const dirInput = page.getByLabel('Recordings Directory');
      await dirInput.fill('./custom-recordings');
      await expect(dirInput).toHaveValue('./custom-recordings');
    });

    test('should show info alert when clicking Browse Recordings', async ({ page }) => {
      const dirInput = page.getByLabel('Recordings Directory');
      await dirInput.fill('./my-yumlogs');

      await page.getByRole('button', { name: 'Browse Recordings' }).click();

      // Verify info alert appears with directory path
      const recordingsList = page.locator('#recordingsList');
      await expect(recordingsList).toContainText('To browse recordings:');
      await expect(recordingsList).toContainText('./my-yumlogs');
    });

    test('should show alert when clicking Open Folder', async ({ page }) => {
      const dirInput = page.getByLabel('Recordings Directory');
      await dirInput.fill('./test-folder');

      page.on('dialog', async dialog => {
        expect(dialog.type()).toBe('alert');
        expect(dialog.message()).toContain('explorer');
        expect(dialog.message()).toContain('./test-folder');
        await dialog.accept();
      });

      await page.getByRole('button', { name: 'Open Folder' }).click();
    });
  });

  test.describe('Configuration Section', () => {
    test('should have empty textarea initially', async ({ page }) => {
      const configTextarea = page.locator('#configEditor');
      await expect(configTextarea).toHaveValue('');
    });

    test('should load default configuration when clicking Load Config', async ({ page }) => {
      page.on('dialog', async dialog => {
        expect(dialog.type()).toBe('alert');
        expect(dialog.message()).toContain('yumlog.ps1 config');
        await dialog.accept();
      });

      await page.getByRole('button', { name: 'Load Config' }).click();

      // Verify JSON appears in textarea
      const configTextarea = page.locator('#configEditor');
      const configValue = await configTextarea.inputValue();
      expect(configValue).toContain('"capture"');
      expect(configValue).toContain('"record"');
      expect(configValue).toContain('"defaultFps"');
    });

    test('should generate save command output', async ({ page }) => {
      // Load config first
      page.once('dialog', dialog => dialog.accept());
      await page.getByRole('button', { name: 'Load Config' }).click();

      // Click Generate Save Command
      await page.getByRole('button', { name: 'Generate Save Command' }).click();

      // Verify save command output appears
      const saveCommandOutput = page.locator('#configCommandOutput');
      await expect(saveCommandOutput).toBeVisible();
      await expect(saveCommandOutput).toContainText('To save the configuration:');
      await expect(saveCommandOutput).toContainText('config\\tools.json');
    });

    test('should show alert when Generate Save Command clicked with empty config', async ({ page }) => {
      page.on('dialog', async dialog => {
        expect(dialog.type()).toBe('alert');
        expect(dialog.message()).toContain('Please load or enter configuration first');
        await dialog.accept();
      });

      await page.getByRole('button', { name: 'Generate Save Command' }).click();
    });

    test('should display default configuration structure', async ({ page }) => {
      const configSection = page.locator('.section').filter({ hasText: 'Configuration' });
      await expect(configSection).toContainText('Default Configuration Structure:');
      await expect(configSection).toContainText('"defaultFps": 1');
      await expect(configSection).toContainText('"defaultFps": 30');
    });
  });

  test.describe('PowerShell Commands Reference Section', () => {
    test('should display all command examples', async ({ page }) => {
      const commandsSection = page.locator('.section').filter({ hasText: 'PowerShell Commands Reference' });

      // Verify record command
      await expect(commandsSection).toContainText('# Start a screen recording');
      await expect(commandsSection).toContainText('.\\launchers\\record.ps1 -Fps 30 -DurationSec 10 -OutFile .\\myvideo.mp4');

      // Verify capture command
      await expect(commandsSection).toContainText('# Capture periodic screenshots');
      await expect(commandsSection).toContainText('.\\launchers\\capture.ps1 -Fps 2 -DurationSec 5 -OutDir .\\myscreens');

      // Verify unified CLI commands
      await expect(commandsSection).toContainText('# Using the unified CLI');
      await expect(commandsSection).toContainText('.\\launchers\\yumlog.ps1 start');
      await expect(commandsSection).toContainText('.\\launchers\\yumlog.ps1 get');
      await expect(commandsSection).toContainText('.\\launchers\\yumlog.ps1 count');
      await expect(commandsSection).toContainText('.\\launchers\\yumlog.ps1 size');
      await expect(commandsSection).toContainText('.\\launchers\\yumlog.ps1 config');

      // Verify install command
      await expect(commandsSection).toContainText('# Install FFmpeg (if needed)');
      await expect(commandsSection).toContainText('.\\launchers\\install.ps1');

      // Verify test command
      await expect(commandsSection).toContainText('# Run tests');
      await expect(commandsSection).toContainText('.\\launchers\\run-tests.ps1');
    });
  });

  test.describe('About Section', () => {
    test('should display project information', async ({ page }) => {
      const aboutSection = page.locator('.section').filter({ hasText: 'About Yumlog' });

      await expect(aboutSection).toContainText('Darbot Yumlog');
      await expect(aboutSection).toContainText('lightweight PowerShell-based screen capture');
      await expect(aboutSection).toContainText('vision" for AI');
    });

    test('should display key features', async ({ page }) => {
      const aboutSection = page.locator('.section').filter({ hasText: 'About Yumlog' });

      await expect(aboutSection).toContainText('Key Features:');
      await expect(aboutSection).toContainText('High-performance screen recording using FFmpeg');
      await expect(aboutSection).toContainText('Periodic screenshot capture');
      await expect(aboutSection).toContainText('Simple PowerShell CLI interface');
      await expect(aboutSection).toContainText('No telemetry - 100% local execution');
      await expect(aboutSection).toContainText('Auto-installs FFmpeg');
      await expect(aboutSection).toContainText('Configurable FPS, duration, and output locations');
    });

    test('should display license and repository link', async ({ page }) => {
      const aboutSection = page.locator('.section').filter({ hasText: 'About Yumlog' });

      await expect(aboutSection).toContainText('License: MIT');
      
      const repoLink = page.getByRole('link', { name: 'github.com/darbotlabs/Yumlog' });
      await expect(repoLink).toBeVisible();
      await expect(repoLink).toHaveAttribute('href', 'https://github.com/darbotlabs/Yumlog');
      await expect(repoLink).toHaveAttribute('target', '_blank');
    });
  });

  test.describe('Page Sections', () => {
    test('should display all main section headings', async ({ page }) => {
      await expect(page.getByRole('heading', { name: 'Quick Start', level: 2 })).toBeVisible();
      await expect(page.getByRole('heading', { name: 'Statistics', level: 2 })).toBeVisible();
      await expect(page.getByRole('heading', { name: 'Recordings Management', level: 2 })).toBeVisible();
      await expect(page.getByRole('heading', { name: 'Configuration', level: 2 })).toBeVisible();
      await expect(page.getByRole('heading', { name: 'PowerShell Commands Reference', level: 2 })).toBeVisible();
      await expect(page.getByRole('heading', { name: 'About Yumlog', level: 2 })).toBeVisible();
    });

    test('should display welcome message', async ({ page }) => {
      await expect(page.getByText('Welcome to Yumlog Manager!')).toBeVisible();
      await expect(page.getByText('This interface helps you manage, configure, and use your screen recordings')).toBeVisible();
    });
  });

  test.describe('Scrolling and Layout', () => {
    test('should be able to scroll through entire page', async ({ page }) => {
      // Scroll to bottom
      await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
      
      // Verify About section is visible (last section)
      await expect(page.getByRole('heading', { name: 'About Yumlog', level: 2 })).toBeVisible();
      
      // Scroll back to top
      await page.evaluate(() => window.scrollTo(0, 0));
      
      // Verify header is visible
      await expect(page.getByRole('heading', { name: 'Yumlog Manager', level: 1 })).toBeVisible();
    });
  });

  test.describe('Alert Boxes', () => {
    test('should display info alert box', async ({ page }) => {
      const infoAlert = page.locator('.alert.info').first();
      await expect(infoAlert).toBeVisible();
      await expect(infoAlert).toContainText('Welcome to Yumlog Manager!');
    });

    test('should display warning alert box', async ({ page }) => {
      const warningAlert = page.locator('.alert.warning');
      await expect(warningAlert).toBeVisible();
      await expect(warningAlert).toContainText('Note:');
      await expect(warningAlert).toContainText('File operations require manual access');
    });
  });
});
