import ArgumentParser
import Foundation
import ShellOut
import Yams

public protocol Project {
    init()

    var name: String { get }

    func build() async throws -> Outputs
}

extension Project {
    public var name: String {
        String(describing: type(of: self))
    }
}

extension Project {
    public static func main() async throws {
        let project = Self()
        let command = try Command.parseAsRoot(Command.commandLineArguments())
        switch command {
        case let command as Command.RunCommand:
            try await command.invoke(with: project)
        default:
            let error = ValidationError("Unknown command")
            Command.exit(withError: error)
        }
    }
}
