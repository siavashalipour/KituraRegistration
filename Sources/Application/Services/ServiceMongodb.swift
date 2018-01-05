import LoggerAPI
import CloudEnvironment
import MongoKitten

struct EnvironmentValue {
    let mongodbHost: String
    let mongodbPort: String
    let mongodbName: String
    
    func description() {
        print("host: \(mongodbHost) - port: \(mongodbPort) - dbName: \(mongodbName)")
    }
}

func getEnvironmentArguments() -> EnvironmentValue {
    
    let mongodbHostKeyword = "mongodb_host:"
    let mongodbPortKeyword = "mongodb_port:"
    let mongodbDatabaseNameKeyword = "mongodb_name:"
    
    let arguments = CommandLine.arguments
    
    // get mongodb host
    var mongoDbHost = "localhost"
    if let hostElement = arguments.filter({ $0.contains(mongodbHostKeyword)}).first {
        let host = hostElement.replacingOccurrences(of: mongodbHostKeyword, with: "")
        mongoDbHost = host
    }
    // gat mongodb port
    var mongoPort = "27017"
    if let portElement = arguments.filter({$0.contains(mongodbPortKeyword)}).first {
        let port = portElement.replacingOccurrences(of: mongodbPortKeyword, with: "")
        mongoPort = port
    }
    // get mongodb name
    var mongoName = "LocalStore"
    if let nameElement = arguments.filter({$0.contains(mongodbDatabaseNameKeyword)}).first {
        let dbName = nameElement.replacingOccurrences(of: mongodbDatabaseNameKeyword, with: "")
        mongoName = dbName
    }
    
    return EnvironmentValue.init(mongodbHost: mongoDbHost, mongodbPort: mongoPort, mongodbName: mongoName)
}

func initializeServiceMongodb() throws -> Database {
    let myDatabase = try MongoKitten.Database(getMongoDBAddress())
    Log.info("Found and loaded credentials for MongoDB.")
    return myDatabase
}

func getMongoDBAddress() -> String {
    let environment = getEnvironmentArguments()
    return "mongodb://\(environment.mongodbHost):\(environment.mongodbPort)/\(environment.mongodbName)"
}

