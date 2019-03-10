import Foundation
import Kitura
import LoggerAPI
import Configuration
import CloudEnvironment
import KituraContracts
import Health
import Meow
import MongoKitten
import SwiftyJSON

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
    
    
    // register
    try registerRouter()
    
    // login
    try loginRouter()
    
    // add a thing to the user
    try addThingRouter()
    
    // fetch User
    
    // add an object to the user
  }
  func registerRouter() throws {
    let accountCollection = Meow.database["Account"]
    router.all("/register", middleware: BodyParser())
    router.post("/register") { request, response, next in
      guard let parsedBody = request.body else {
        next()
        return
      }
      switch parsedBody {
      case .json(let jsonBody):
        if let email = jsonBody[AccountObjectKey.email] as? String {
          if let pwd = jsonBody[AccountObjectKey.pwd] as? String {
            let document: Document = [AccountObjectKey.email: email, AccountObjectKey.pwd: pwd, AccountObjectKey.things: []]
            do {
              let _ = try accountCollection.insert(document)
              let decoder = BSONDecoder()
              let accountObj: Account = try decoder.decode(Account.self, from: document)
              try response.send(accountObj).end()
            } catch let error {
              print("!!! \(error)")
              try response.send(status: .badRequest).end()
            }
          }
        }
        
      default:
        break
      }
      next()
    }
  }
  func addThingRouter() throws {
    let accountCollection = Meow.database["Account"]
    router.all("/add", middleware: BodyParser())
    router.post("/add") { request, response, next in
      guard let parsedBody = request.body else {
        next()
        return
      }
      switch parsedBody {
      case .json(let jsonBody):
        do {
          let data = try JSONSerialization.data(withJSONObject: jsonBody, options: JSONSerialization.WritingOptions.prettyPrinted)
          let decoder = JSONDecoder()
          var updatedAccount = try decoder.decode(Account.self, from: data)
          let docQuery = Query.init([AccountObjectKey.email: updatedAccount.email, AccountObjectKey.pwd: updatedAccount.password])
          if let currentAccountDoc = try accountCollection.findOne(docQuery) {
            let bsonDecoder = BSONDecoder()
            let currentAccount: Account = try bsonDecoder.decode(Account.self, from: currentAccountDoc)
            var currentAccountthings = currentAccount.things
            for thing in updatedAccount.things {
              currentAccountthings.append(thing)
            }
            updatedAccount.things = currentAccountthings
            
            try accountCollection.update(to: BSONEncoder().encode(updatedAccount))
            try response.send(updatedAccount).end()
          }
        }
        catch let error {
          print("!!! \(error)")
          try response.send(status: .badRequest).end()
        }
      default:
        break
      }
      next()
    }
  }
  func loginRouter() throws {
    let accountCollection = Meow.database["Account"]
    router.get("/login", handler: { request, response, _ in
      if let email = request.queryParameters[AccountObjectKey.email] {
        if let pwd = request.queryParameters[AccountObjectKey.pwd] {
          if let account: Document = try accountCollection.findOne(AccountObjectKey.email == email && AccountObjectKey.pwd == pwd) {
            let decoder = BSONDecoder()
            let accountObj: Account = try decoder.decode(Account.self, from: account)
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
struct AccountObjectKey {
  
  static let email: String = "email"
  static let pwd: String = "password"
  static let things: String = "things"
}
struct Account: Codable {
  var email: String
  var password: String
  var things: [Thing]
}

struct Thing: Codable {
  let uuid: String = NSUUID.init().uuidString
}
