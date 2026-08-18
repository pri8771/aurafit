import Foundation
import OSLog

/// Thin wrapper around `os.Logger` with predefined subsystems/categories.
/// Keeps logging consistent and avoids `print` in production code.
enum AppLog {
    private static let subsystem = "com.aurafit.app"

    static let app = Logger(subsystem: subsystem, category: "app")
    static let analysis = Logger(subsystem: subsystem, category: "analysis")
    static let camera = Logger(subsystem: subsystem, category: "camera")
    static let persistence = Logger(subsystem: subsystem, category: "persistence")
    static let export = Logger(subsystem: subsystem, category: "export")
}
