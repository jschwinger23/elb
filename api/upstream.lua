local utils = require "resty.utils"
local string = require 'string'

local function detail()
    local upstream = require "ngx.upstream"
    local get_servers = upstream.get_servers
    local get_upstreams = upstream.get_upstreams
    local upstreams = get_upstreams()
    local result = {}
    for i = 1, #upstreams do
        local upstream = upstreams[i]
        local servers, err = get_servers(upstream)
        if not servers then
            ngx.log(ngx.ERR, "failed to get servers in upstream ", upstream)
        elseif err then
            ngx.log(ngx.ERR, err)
        else
            result[upstream] = servers 
        end
    end
    utils.say_msg_and_exit(ngx.HTTP_OK, result)
end

local function put()
    local data = utils.read_data()
    local upstreams = cjson.decode(data) 
    for backend_name, servers in pairs(upstreams) do
        local servers_str = utils.servers_str(servers)
        if not utils.set_upstream(backend_name, servers_str) then
            ngx.log(ngx.ERR, 'update upstream failed ', err)
        end
    end
    utils.say_msg_and_exit(ngx.HTTP_OK, "OK")
end

if ngx.var.request_method == 'GET' then 
    detail()
elseif ngx.var.request_method == 'PUT' then
    put()
else
    utils.say_msg_and_exit(ngx.HTTP_FORBIDDEN, "")
end