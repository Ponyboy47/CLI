/// CLI Arguments that come with one or more values
public class MultiOption<A: ArgumentType>: Option<A>, Collection, IteratorProtocol {
    private var _index: Int? = nil
    public var count: Int {
        return values.count
    }
    public var startIndex: Int {
        return values.startIndex
    }
    public var endIndex: Int {
        return values.endIndex
    }

    private var values: [A] = []
    override public var value: A? {
        get {
            return next()
        }
        set {
            guard let val = newValue else { return }
            values.append(val)
        }
    }

    public func next() -> A? {
        guard !values.isEmpty else {
            return `default`
        }
        if _index != nil {
            _index = index(after: _index!)
        } else {
            _index = values.startIndex
        }

        guard _index! <= endIndex else {
            _index = nil
            return nil
        }

        return values[_index!]
    }

    override public var description: String {
        return "\(self.sortedNames) = \(self.values)"
    }

    override public func parse(_ cli: inout [String]) throws {
        value = try A.from(string: cli.remove(at: 0))
    }

    public subscript(bounds: Range<Int>) -> Slice<[A]> {
        return values[bounds]
    }

    public subscript(position: Int) -> A {
        return values[position]
    }

    public func index(_ i: Int, offsetBy n: Int) -> Int {
        return values.index(i, offsetBy: n)
    }

    public func index(_ i: Int, offsetBy n: Int, limitedBy limit: Int) -> Int? {
        return values.index(i, offsetBy: n, limitedBy: limit)
    }

    public func index(after i: Int) -> Int {
        return values.index(after: i)
    }
}

public extension MultiOption where A: Equatable {
    public func index(of element: A) -> Int? {
        return values.index(of: element)
    }
}
