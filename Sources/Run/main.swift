import App
import PostgreSQLProvider

let config = try Config()
try config.setup()

try config.addProvider(PostgreSQLProvider.Provider.self)

let drop = try Droplet(config)
try drop.setup()

try drop.run()
