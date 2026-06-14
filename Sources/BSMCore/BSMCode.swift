/// A BSM Code: the raw lookup string of stroke digits (`0`-`9`) plus the `*`
/// wildcard. It excludes the `.` selection trigger and is at most 6 characters.
public struct BSMCode: Hashable, Sendable, CustomStringConvertible {
    public let raw: String

    public init(_ raw: String) {
        self.raw = raw
    }

    public var description: String { raw }
}
