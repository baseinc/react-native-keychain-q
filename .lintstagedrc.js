module.exports = {
  'ios/*.swift': () => [
    `yarn lint`,
    `swiftformat .`,
    `git add`
  ]
}
