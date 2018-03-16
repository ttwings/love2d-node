---
--- Created by fox.
--- DateTime: 2018/3/16 21:53
---

local import = require("Import");
local class = import("..class");

---@type Message
local Message = import(".Message");


---@class Loader : Message
local Loader = class(Message);

---@param this Loader
function Loader.ctor(this)
    this.loads = {};
end


---@field public images <string,table>[]
---@param type string
---@param path string
---@param cache boolean
---@return Loader
function Loader.load(this,path,type,cache)
    type = type or "IMAGE";
    cache = cache or true;

    if type == "IMAGE" then
        this.images[path] = love.graphics.newImage(path);
    elseif type == "FONT" then
        -- 这里做缓存
    elseif type == "IMAGEPACK" then
        -- 这里做切图
    else
        print( string.format("error ; unknown type resource(不可识别的资源) type:%s path:%s",type ,path));
    end

    if not this:isExist(path) then
        table.insert(this.loads,path)
    end

    return this;
end


---@param this Loader
---@param path string
---@return boolean
function Loader.isExist(this, path)
    for _, p in ipairs(this.loads) do
        if p == path then
            return true;
        end
    end
    return false;
end


---@param this Loader
---@param skin string
function Loader.getImage(this,skin)
    return this.images and this.images[path] or nil;
end

return Loader;