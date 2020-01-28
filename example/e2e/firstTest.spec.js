const { device, expect, element, by } = require('detox');

describe('Example', () => {
  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('should have components', async () => {
    await expect(element(by.id('welcome'))).toBeVisible();
    await expect(element(by.id('input-account')).atIndex(0)).toBeVisible();
  });

  describe('linking inspection', () => {
    const deepLink = 'keychain-q://inspection?foo=bar';
    beforeEach(async () => {
      await device.openURL({ url: deepLink });
    });
    it('should have welcome text', async () => {
      await expect(element(by.id('debug-log'))).toHaveText(
        'catch deepLink ' + deepLink,
      );

      await expect(element(by.id('welcome-text'))).toBeVisible();
    });
  });

  // it('should show hello screen after tap', async () => {
  //   await element(by.id('hello_button')).tap();
  //   await expect(element(by.text('Hello!!!'))).toBeVisible();
  // });

  // it('should show world screen after tap', async () => {
  //   await element(by.id('world_button')).tap();
  //   await expect(element(by.text('World!!!'))).toBeVisible();
  // });
});
