// @format
/* eslint-env jest */

import { NativeModules } from 'react-native';
import KeychainQMock from './jest/keychain-mock.js';

// Mock the native module to allow us to unit test the JavaScript code
NativeModules.KeychainQ = KeychainQMock;

// Reset the mocks before each test
global.beforeEach(() => {
  jest.resetAllMocks();
});
