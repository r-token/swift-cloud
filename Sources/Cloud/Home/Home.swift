import Foundation

public protocol Home: Sendable {
    func bootstrap(with context: Context) async throws

    func passphrase(with context: Context) async throws -> String

    func putItem<T: Codable>(_ data: T, fileName: String, with context: Context) async throws

    func getItem<T: Codable>(fileName: String, with context: Context) async throws -> T
}

extension Home {
    public func hasItem(fileName: String, with context: Context) async -> Bool {
        do {
            let _: AnyCodable = try await getItem(fileName: fileName, with: context)
            return true
        } catch {
            return false
        }
    }
}

extension Home {
    private func localStatePath(context: Context) -> String {
        "\(Context.cloudDirectory)/.pulumi/stacks/\(tokenize(context.project.name))/\(context.stage).json"
    }

    internal func hasLocalState(context: Context) -> Bool {
        FileManager.default.fileExists(atPath: localStatePath(context: context))
    }

    internal func restoreLocalState(context: Context) async throws {
        let state: AnyCodable = try await getItem(fileName: "state", with: context)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(state)
        try createFile(atPath: localStatePath(context: context), contents: data)
    }

    internal func saveLocalState(context: Context) async throws {
        let data = try readFile(atPath: localStatePath(context: context))
        let state = try JSONDecoder().decode(AnyCodable.self, from: data)
        try await putItem(state, fileName: "state", with: context)
    }
}
