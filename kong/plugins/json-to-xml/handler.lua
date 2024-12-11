local cjson = require "cjson"
local xml = require "resty.xml" -- Ensure a suitable XML library is installed.

local plugin = {
  PRIORITY = 1000, -- Priority determines the plugin execution order
  VERSION = "0.1", -- Plugin version
}

-- Convert a table (JSON object) to XML format
local function table_to_xml(t)
    local function escape_xml(str)
        return (str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
    end

    local function build_xml(t, name)
        local xml = ""
        for k, v in pairs(t) do
            local key = escape_xml(k)
            if type(v) == "table" then
                xml = xml .. "<" .. key .. ">" .. build_xml(v, key) .. "</" .. key .. ">"
            else
                local value = escape_xml(tostring(v))
                xml = xml .. "<" .. key .. ">" .. value .. "</" .. key .. ">"
            end
        end
        return xml
    end

    return "<" .. (name or "root") .. ">" .. build_xml(t) .. "</" .. (name or "root") .. ">"
end

-- Handle the request in the access phase
function plugin:access(plugin_conf)
    -- Log the incoming request for inspection
    kong.log.inspect(plugin_conf)

    -- Read the body of the incoming JSON request
    local body = kong.request.get_body()
    if body then
        local json_data, err = cjson.decode(body)
        if not json_data then
            kong.log.err("Failed to decode JSON: " .. err)
            return kong.response.exit(400, "Invalid JSON")
        end

        -- Convert the JSON data into XML
        local xml_data = table_to_xml(json_data)

        -- Set the new body as XML
        kong.service.request.set_body(xml_data)
        kong.service.request.set_header("Content-Type", "application/xml")
    else
        kong.log.err("Request body is empty")
        return kong.response.exit(400, "Empty request body")
    end
end

-- Return our plugin object
return plugin



