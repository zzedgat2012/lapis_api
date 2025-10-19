local migrations = {}

migrations[1] = require("migrations.20251019_000001_create_users")
migrations[2] = require("migrations.20251019_000002_seed_admin_user")

return migrations
