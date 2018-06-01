/// CLI Arguments that come with one or more values
public class MultiOption<A: ArgumentType>: Option<A> {
    private var index: Int = -1
    private var values: [A] = []
    override public var value: A? {
        get {
            guard !values.isEmpty else { return `default` }
            index += 1
            guard index < values.count else { return nil }
            return values[index]
        }
        set {
            guard let val = newValue else { return }
            values.append(val)
        }
    }

    override public var description: String {
        return "\(self.sortedNames) = \(self.values)"
    }

    override public func parse(_ cli: inout [String]) throws {
        value = try A.from(string: cli.remove(at: 0))
    }
}
