module.exports = {
  'ios/*.swift': () => [
    `swiftformat .`,
    `git add ios/*.swift`
  ],
  'src/*.{ts,tsx}': () => [
    `yarn lint`,
    `git add src/*.{ts,tsx}`
  ]
}
