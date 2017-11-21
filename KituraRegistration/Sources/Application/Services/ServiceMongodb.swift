import LoggerAPI
import CloudEnvironment
import MongoKitten

func initializeServiceMongodb(cloudEnv: CloudEnv) throws -> Database {
    guard let mongodbCredentials = cloudEnv.getMongoDBCredentials(name: "mongodb") else {
        throw InitializationError("Could not load credentials for MongoDB.")
    }
    let mongodb = try Database(mongodbCredentials.uri)
    Log.info("Found and loaded credentials for MongoDB.")
    return mongodb
}
