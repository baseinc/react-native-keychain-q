module.exports = {
  'ios/*.swift': () => [
    `swiftformat .`,
    `git add ios/*.swift`
  ],
  '*.podspec': () => `yarn pod:lib:lint`,
  'src/*.{ts,tsx}': () => [
    `yarn lint`,
    `git add src/*.{ts,tsx}`
  ]
}
