local helpers = require "spec.helpers"

describe("Plugin: json-to-xml (integration)", function()

  local client

  setup(function()
    -- Start a test Kong instance with the plugin enabled
    local bp = helpers.get_db_utils()
    local route = bp.routes:insert({
      hosts = { "json-to-xml.test" },
    })
    bp.plugins:insert({
      name = "json-to-xml",
      route = { id = route.id },
    })
    assert(helpers.start_kong())
  end)

  teardown(function()
    helpers.stop_kong()
  end)

  before_each(function()
    client = helpers.http_client()
  end)

  after_each(function()
    client:close()
  end)

  it("should convert JSON to XML in response", function()
    local res = client:post("http://json-to-xml.test", {
      body = cjson.encode({ name = "John", age = 30 }),
      headers = { ["Content-Type"] = "application/json" }
    })

    assert.res_status(200, res)
    local body = assert.response(res).has_body()
    local expected_xml = '<root><name>John</name><age>30</age></root>'
    assert.are.equal(body, expected_xml)
  end)

end)
