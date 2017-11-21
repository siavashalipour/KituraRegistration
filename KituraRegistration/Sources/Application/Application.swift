import Foundation
import Kitura
import LoggerAPI
import Configuration
import CloudEnvironment
import KituraContracts
import Health

// Service imports
import MongoKitten

public let projectPath = ConfigurationManager.BasePath.project.path
public let health = Health()

class ApplicationServices {
    // Service references
    public let mongoDBService: MongoKitten.Database

    public init(cloudEnv: CloudEnv) throws {
        // Run service initializers
        mongoDBService = try initializeServiceMongodb(cloudEnv: cloudEnv)
    }
}

public class App {
    let router = Router()
    let cloudEnv = CloudEnv()
    let services: ApplicationServices

    public init() throws {

        // Services
        services = try ApplicationServices(cloudEnv: cloudEnv)
    }

    func postInit() throws {
        // Capabilities
        initializeMetrics(app: self)

        // Endpoints
        initializeHealthRoutes(app: self)
    }

    public func run() throws {
        try postInit()
        Kitura.addHTTPServer(onPort: cloudEnv.port, with: router)
        Kitura.run()
    }
}
