local cjson = require "cjson"
local plugin = require "json-to-xml.handler"

describe("plugin:table_to_xml", function()

  it("converts a simple table to XML", function()
    local json_data = { name = "John", age = 30 }
    local xml_data = plugin.table_to_xml(json_data)
    local expected_xml = '<root><name>John</name><age>30</age></root>'
    assert.are.equal(xml_data, expected_xml)
  end)

  it("escapes special characters in XML", function()
    local json_data = { name = "<John>", age = "&30" }
    local xml_data = plugin.table_to_xml(json_data)
    local expected_xml = '<root><name>&lt;John&gt;</name><age>&amp;30</age></root>'
    assert.are.equal(xml_data, expected_xml)
  end)

end)
