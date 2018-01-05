import Foundation
import Kitura
import LoggerAPI
import Configuration
import CloudEnvironment
import KituraContracts
import Health
import Meow
import MongoKitten

public let health = Health()

class ApplicationServices {
    // Service references
    public let mongoDBService: MongoKitten.Database
    
    public init() throws {
        // Run service initializers
        mongoDBService = try initializeServiceMongodb()
    }
}

public class App {
    let router = Router()
    let services: ApplicationServices
    
    public init() throws {
        // Services
        services = try ApplicationServices()
        try Meow.init(getMongoDBAddress())
    }
    
    func postInit() throws {
        // Capabilities
        initializeMetrics(app: self)
        
        // Endpoints
        initializeHealthRoutes(app: self)
        
        let accountCollection = Meow.database["Account"]
        
        // register
        router.post("/register", handler: { request, response, _ in
            if let email = request.queryParameters[AccountObjectKey.email] {
                if let pwd = request.queryParameters[AccountObjectKey.pwd] {
                    let document: Document = [AccountObjectKey.email: email, AccountObjectKey.pwd: pwd]
                    do {
                        _ = try accountCollection.insert(document)
                    } catch _ {
                        try response.send(status: .badRequest).end()
                    }
                }
            }
        })
        
        // login
        router.get("/login", handler: { request, response, _ in
            if let email = request.queryParameters[AccountObjectKey.email] {
                if let pwd = request.queryParameters[AccountObjectKey.pwd] {
                    if let account: Document = try accountCollection.findOne(AccountObjectKey.email == email && AccountObjectKey.pwd == pwd) {
                        let accountObj = Account.init(with: account)
                        try response.send(accountObj).end()
                    } else {
                        try response.send(status: .notFound).end()
                    }
                } else {
                    try response.send(status: .badRequest).end()
                }
            } else {
                try response.send(status: .badRequest).end()
            }
        })
    }
    
    public func run() throws {
        try postInit()
        Kitura.addHTTPServer(onPort: 8080, with: router)
        Kitura.run()
    }
    
}

