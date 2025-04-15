import Foundation

class TestStore: ObservableObject {
    @Published var tests: [SpermTest] = [] {
        didSet {
            saveTests()
        }
    }

    init() {
        loadTests()
    }

    private func saveTests() {
        if let data = try? JSONEncoder().encode(tests) {
            UserDefaults.standard.set(data, forKey: "spermTests")
        }
    }

    private func loadTests() {
        if let data = UserDefaults.standard.data(forKey: "spermTests"),
           let savedTests = try? JSONDecoder().decode([SpermTest].self, from: data) {
            tests = savedTests
        }
    }
}
