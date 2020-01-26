/**
 * @format
 */
/* eslint-env jest */

const KeychainQMock = {
  fetchCanUseDeviceAuthPolicy: jest.fn(),
  fetchSupportedBiometryType: jest.fn(),
  saveInternetPassword: jest.fn(),
  removeInternetPassword: jest.fn(),
  containsAnyInternetPassword: jest.fn(),
  findInternetPassword: jest.fn(),
  resetInternetPasswords: jest.fn(),
  retrieveInternetPasswords: jest.fn(),
};

module.exports = KeychainQMock;
