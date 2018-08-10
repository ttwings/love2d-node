---
--- Created by fox.
--- DateTime: 2018/4/19 22:19
---

local class = require("node.class");

---@type Box
local Box = require("node.ui.Box")

---@class List : Box
---@field public itemRender Box
local List = class(Box);

---@param this Box
function List.ctor(this)
    Box.ctor(this)

    this._itemRender = nil
    this._array = nil;


    this:set("itemRender", function (v)
        this._itemRender = v;
    end)
    this:get("itemRender", function ()
        return this._itemRender;
    end)


    this:set("array", function (v)
        this._array = v;
    end)
    this:get("array", function ()
        return this._array;
    end)


end

function List:addItem(src)

end

function List:removeItem(src)

end

return List;