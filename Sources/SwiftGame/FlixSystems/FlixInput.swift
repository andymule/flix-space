public protocol FlixInput {
    func handleInput()
    func insertIntoInputList()
}

extension FlixInput {
    public func insertIntoInputList() {
        FlixGame.inputList.append(self)
    }
}
