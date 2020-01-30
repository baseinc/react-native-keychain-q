module.exports = {
  'ios/*.swift': () => [
    `swiftformat .`,
    `git add`
  ],
  '*.podspec': () => `yarn pod:lib:lint`,
  'src/*.{ts,tsx}': () => [
    `yarn lint`,
    `git add`
  ]
}
