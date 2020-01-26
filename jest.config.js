const { defaults: tsjPreset } = require('ts-jest/presets');

module.exports = {
  ...tsjPreset,
  preset: 'react-native',
  verbose: true,
  transform: {
    ...tsjPreset.transform,
    '\\.js$': '<rootDir>/node_modules/react-native/jest/preprocessor.js',
  },
  testPathIgnorePatterns: [
    '<rootDir>/lib/',
    '<rootDir>/node_modules/',
    '<rootDir>/example/',
  ],
  modulePathIgnorePatterns: ['<rootDir>/lib/', '<rootDir>/example/'],
  globals: {
    'ts-jest': {
      babelConfig: true,
    },
  },
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
};
