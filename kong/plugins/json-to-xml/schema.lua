local typedefs = require "kong.db.schema.typedefs"

return {
  name = "json-to-xml",  -- Name of the plugin
  fields = {
    { config = typedefs.noop },  -- No configuration fields for this plugin
  },
}
