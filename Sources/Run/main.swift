import App
import PostgreSQLProvider

let config = try Config()
try config.setup()

try config.addProvider(PostgreSQLProvider.Provider.self)
config.addConfigurable(middleware: CORSMiddleware(), name: "cors")

let drop = try Droplet(config)
try drop.setup()


try drop.run()
