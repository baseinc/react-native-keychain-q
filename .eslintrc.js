
const typescriptEslintRecommended = require('@typescript-eslint/eslint-plugin/dist/configs/recommended.json');
const typescriptEslintPrettier = require('eslint-config-prettier/@typescript-eslint');

module.exports = {
  extends: ['@react-native-community'],
  overrides: [
    {
      files: ['*.ts', '*.tsx', 'example/*.js'],
      rules: Object.assign(
        typescriptEslintRecommended.rules,
        typescriptEslintPrettier.rules,
        {
          '@typescript-eslint/explicit-member-accessibility': 'off',
          '@typescript-eslint/explicit-function-return-type': 'off',
          '@typescript-eslint/no-use-before-define': 'off',
          'react-native/no-inline-styles': 'off'
        },
      ),
    },
    {
      files: ['example/*.js'],
      plugins: ['react-hooks'],
      rules: Object.assign(
        {
          'prettier/prettier': 'off',
          "@typescript-eslint/no-var-requires": "off",
          'react-native/no-inline-styles': 'off',
          "react-hooks/rules-of-hooks": "error",
          "react-hooks/exhaustive-deps": "error",
        },
      ),
    }
  ]
}
