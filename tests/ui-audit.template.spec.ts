import { test, expect } from '@playwright/test';

/**
 * Gen.UI.Audit Test Template
 * 
 * This template provides a starting point for creating UI audit tests.
 * Copy this file and customize it for your specific application.
 * 
 * Usage:
 * 1. Update the pageUrl with your target URL
 * 2. Customize test.describe() with your app name
 * 3. Add specific test cases for your UI
 * 4. Run with: npx playwright test
 */

test.describe('UI Audit Template', () => {
  // TODO: Update this URL to your target application
  const pageUrl = 'https://example.com';

  test.beforeEach(async ({ page }) => {
    // Navigate to the page before each test
    await page.goto(pageUrl);
  });

  // === BASIC PAGE LOAD TESTS ===
  
  test('should load the page successfully', async ({ page }) => {
    // Verify page loads without errors
    await expect(page).toHaveTitle(/.+/); // Has some title
    
    // Check for common error indicators
    await expect(page.locator('body')).not.toContainText('404');
    await expect(page.locator('body')).not.toContainText('Error');
  });

  test('should have valid page structure', async ({ page }) => {
    // Check for main structural elements
    await expect(page.locator('body')).toBeVisible();
    
    // Add specific structural checks for your app
    // Example: await expect(page.locator('header')).toBeVisible();
    // Example: await expect(page.locator('main')).toBeVisible();
    // Example: await expect(page.locator('footer')).toBeVisible();
  });

  // === NAVIGATION TESTS ===
  
  test('should navigate between pages', async ({ page }) => {
    // TODO: Add navigation tests specific to your application
    // Example:
    // await page.click('a[href="/about"]');
    // await expect(page).toHaveURL(/\/about/);
  });

  // === FORM INTERACTION TESTS ===
  
  test('should handle form inputs correctly', async ({ page }) => {
    // TODO: Test form fields in your application
    // Example:
    // await page.fill('#email', 'test@example.com');
    // await expect(page.locator('#email')).toHaveValue('test@example.com');
  });

  // === BUTTON AND CLICK TESTS ===
  
  test('should handle button clicks', async ({ page }) => {
    // TODO: Test buttons and interactive elements
    // Example:
    // await page.click('button.primary');
    // await expect(page.locator('.success-message')).toBeVisible();
  });

  // === ACCESSIBILITY TESTS ===
  
  test('should have accessible elements', async ({ page }) => {
    // Check for proper heading hierarchy
    const h1Count = await page.locator('h1').count();
    expect(h1Count).toBeGreaterThan(0);
    expect(h1Count).toBeLessThanOrEqual(1); // Should have exactly one H1
    
    // TODO: Add more accessibility checks
    // Example: Check for alt text on images
    // const images = await page.locator('img').all();
    // for (const img of images) {
    //   const alt = await img.getAttribute('alt');
    //   expect(alt).toBeTruthy();
    // }
  });

  test('should have proper ARIA labels', async ({ page }) => {
    // TODO: Check for ARIA labels on interactive elements
    // Example:
    // const buttons = await page.locator('button').all();
    // for (const button of buttons) {
    //   const label = await button.textContent() || await button.getAttribute('aria-label');
    //   expect(label).toBeTruthy();
    // }
  });

  // === RESPONSIVE DESIGN TESTS ===
  
  test('should be responsive on mobile', async ({ page }) => {
    // Set viewport to mobile size
    await page.setViewportSize({ width: 375, height: 667 });
    
    // Reload to trigger responsive layout
    await page.reload();
    
    // TODO: Verify mobile-specific layout
    // Example: Check if mobile menu is visible
  });

  test('should be responsive on tablet', async ({ page }) => {
    // Set viewport to tablet size
    await page.setViewportSize({ width: 768, height: 1024 });
    
    // Reload to trigger responsive layout
    await page.reload();
    
    // TODO: Verify tablet-specific layout
  });

  // === PERFORMANCE TESTS ===
  
  test('should load within acceptable time', async ({ page }) => {
    const startTime = Date.now();
    await page.goto(pageUrl);
    const loadTime = Date.now() - startTime;
    
    // Page should load within 5 seconds
    expect(loadTime).toBeLessThan(5000);
  });

  // === VISUAL REGRESSION TESTS ===
  
  test('should match visual snapshot', async ({ page }) => {
    // Take a screenshot and compare to baseline
    // First run will create baseline, subsequent runs will compare
    await expect(page).toHaveScreenshot('full-page.png', {
      fullPage: true,
      maxDiffPixels: 100 // Allow some tolerance
    });
  });

  // === DARK MODE TESTS (if applicable) ===
  
  test.describe('Dark Mode', () => {
    test.skip('should toggle dark mode', async ({ page }) => {
      // TODO: Implement if your app has dark mode
      // Example:
      // const body = page.locator('body');
      // await expect(body).not.toHaveClass(/dark-mode/);
      // 
      // await page.click('#dark-mode-toggle');
      // await expect(body).toHaveClass(/dark-mode/);
    });
  });

  // === ERROR HANDLING TESTS ===
  
  test('should handle network errors gracefully', async ({ page }) => {
    // TODO: Test error scenarios
    // Example: Navigate to non-existent page
    // await page.goto(pageUrl + '/nonexistent');
    // await expect(page.locator('.error-message')).toBeVisible();
  });

  // === SECURITY TESTS ===
  
  test('should use HTTPS', async ({ page }) => {
    const url = page.url();
    if (!url.startsWith('file://')) {
      expect(url).toMatch(/^https:/);
    }
  });

  test('should have secure headers', async ({ page }) => {
    const response = await page.goto(pageUrl);
    
    if (response && !pageUrl.startsWith('file://')) {
      const headers = response.headers();
      
      // Check for security headers (customize based on your requirements)
      // Example: expect(headers['x-frame-options']).toBeTruthy();
      // Example: expect(headers['x-content-type-options']).toBe('nosniff');
    }
  });

  // === CUSTOM TESTS ===
  // Add your application-specific tests below
  
  test.skip('custom test 1', async ({ page }) => {
    // TODO: Implement your custom test
  });

  test.skip('custom test 2', async ({ page }) => {
    // TODO: Implement your custom test
  });
});

/**
 * BEST PRACTICES:
 * 
 * 1. Use semantic selectors (getByRole, getByLabel, getByText) over CSS selectors
 * 2. Wait automatically - Playwright auto-waits, avoid explicit timeouts
 * 3. Isolate tests - Each test should be independent
 * 4. Group related tests with test.describe()
 * 5. Use test.beforeEach() for common setup
 * 6. Add data-testid attributes for reliable selectors
 * 7. Test user flows, not implementation details
 * 8. Keep tests readable and maintainable
 * 9. Use meaningful test descriptions
 * 10. Capture evidence with screenshots on failures (automatic in Playwright)
 */
