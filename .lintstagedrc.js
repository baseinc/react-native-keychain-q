module.exports = {
  'ios/*.swift': () => [
    `swiftformat .`,
    `git add ios/*.swift`
  ]
}
