const {device, expect, element, by} = require('detox');

describe('Example', () => {
  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('should have welcome screen', async () => {
    await expect(element(by.id('welcome'))).toBeVisible();
  });

  describe('linking inspection', () => {
    const deepLink = 'keychain-q://inspection';
    beforeEach(async () => {
      await device.openURL({url: deepLink});
    });
    it('should have welcome text', async () => {
      await expect(element(by.id('debug-log'))).toHaveText(
        'catch deepLink from ' + deepLink,
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
