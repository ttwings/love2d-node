---
--- Created by fox.
--- DateTime: 2018/3/16 21:22
---

---@type Loader
local Loader = require("node.core.Net.Loader");

local class = require("node.class");

local Utils = require("node.core.Utils.Utils")
local Constant = require("node.core.Utils.Constant")

---@type Component
local Component = require("node.ui.Component")


local newQuad_ = love.graphics.newQuad

---newQuad
---@param quad Quad
---@param x number
---@param y number
---@param w number
---@param h number
---@param width number
---@param height number
---@return Quad
local function newQuad(quad, x, y, w, h, width, height)
    if (w == 0 or h == 0) then
        return nil
    end
    if quad == nil then
        quad = newQuad_(x, y, w, h, width, height)
    else
        quad:setViewport(x, y, w, h)
    end
    return quad
end



---@class Sprite : Component
---@field public sizeGrid string
---@field public skin string
---@field private _sizeGrid string
local Sprite = class(Component)


---@param this Sprite
---@param skin string
function Sprite.ctor(this, skin)
    Component.ctor(this)

    this:setter("skin", function(v)
        this._skin = v;
        Loader:load(this._skin, Loader.IMAGE, true, Utils.call(this._onLoad, this));
    end)
    this:getter("skin", function()
        return this._skin;
    end)

    this._sizeGrid = nil

    this:setter("sizeGrid", function(v)
        this._sizeGrid = v;
        this:_updateSkin();
    end)
    this:getter("sizeGrid", function()
        return this._sizeGrid;
    end )

    this._width = 0
    this:setter("width", function(v)
        if this._width ~= v then
            this._width = v;
            this.autoSize = false;
            this:_onResize()
            this:_changeSize()
        end
    end)
    this:getter("width", function()
        if this._width == nil then
            if this._image then
                return this._image:getWidth()
            end
            return 0
        end
        return this._width;
    end)

    this._height = 0
    this:setter("height", function(v)
        if this._height ~= v then
            this._height = v;
            this.autoSize = false;
            this:_onResize()
            this:_changeSize()
        end
    end)
    this:getter("height", function()
        if this._height == nil then
            if this._image then
                return this._image:getHeight()
            end
            return 0
        end
        return this._height;
    end)


    this:setter("dataSource", function(d)
        if d then
            if type(d) == "string" then
                this.skin = d;
            elseif type(d) == "table" then
                for k, v in pairs(d) do
                    if type(this[k]) == "table" then
                        this[k].dataSource = v;
                    else
                        this[k] = v;
                    end
                end
            end
        end
        this._dataSource = d;
    end)

    this:getter("dataSource", function()
        return this._dataSource;
    end)

    this.skin = skin;

    this._drawMode = nil;

end

---@protected
function Sprite:_onLoad()
    if self._skin then
        self._image = Loader:getRes(self._skin);
        self:_onResize();
    end
end

function Sprite:_onResize()
    Component._onResize(self);
    self:_updateSkin()
end

---@param this Sprite
function Sprite._updateSkin(this)
    if this._skin and this._sizeGrid then
        local grids = Utils.splteText(this._sizeGrid, ",");
        if #grids >= 5 and grids[5] == "1" then
            this._drawMode = 1;
        end
        this:__setGrid(unpack(grids));
    end
end

local function _fill(draw, img, quad, x, y, width, height)
    local bx = x;
    local by = y;
    local qx, qy, qw, qh = quad:getViewport();
    local bh = height
    while bh > 0 do
        local bw = width
        if bh < qh then
            quad:setViewport(qx, qy, bw, bh)
        end
        while bw > 0 do
            if bw < qw then
                quad:setViewport(qx, qy, bw, qh)
            end
            draw(img, quad, bx + width - bw, by + height - bh, 0, 1, 1);
            bw = bw - qw;
        end
        bh = bh - qh;
        quad:setViewport(qx, qy, qw, qh)
    end
end

---@return Sprite
function Sprite:_draw(graphics)
    if self._image ~= nil then
        ---@type Image
        local img = self._image;
        local width = img:getWidth()
        local height = img:getHeight()

        if self._sizeGrid == nil then
            local sx = self.width / width;
            local sy = self.height / height;
            graphics.draw(img, 0, 0, 0, sx, sy, self.pivotX / sx, self.pivotY / sy)
        else
            local gridCenterWidth = width - self._grid[1] - self._grid[3]
            local gridCenterHeight = height - self._grid[2] - self._grid[4]

            local scaleXGroup = { 1, (self.width - self._grid[1] - self._grid[3]) / gridCenterWidth, 1 }
            local scaleYGroup = { 1, (self.height - self._grid[2] - self._grid[4]) / gridCenterHeight, 1 }
            local xGroup = { 0, self._grid[1], self.width - self._grid[3] }
            local yGroup = { self.height - self._grid[4], self._grid[2], 0 }

            local dw, dh;
            if self._drawMode == 1 then
                dw = { self._grid[1], gridCenterWidth, self._grid[3] };
                dh = { self._grid[4], gridCenterHeight, self._grid[2] };
            end

            local j, quad;
            for i = 1, 3 do
                for n = 1, 3 do
                    j = (i - 1) * 3 + n
                    quad = self._grid_quad[j];
                    if (quad) then
                        local bx = (-(self.pivotX * self.scaleX) + (xGroup[n] * self.scaleX));
                        local by = (-(self.pivotY * self.scaleY) + (yGroup[i] * self.scaleY));
                        if self._drawMode == 1 then
                            _fill(graphics.draw, img, quad, bx, by, self.scaleX * scaleXGroup[n] * dw[n], self.scaleY * scaleYGroup[i] * dh[i])
                        else
                            graphics.draw(img, quad, bx, by, 0, self.scaleX * scaleXGroup[n], self.scaleY * scaleYGroup[i])
                        end
                    end
                end
            end
        end
    end
    return self;
end

---grid
---@param this Sprite
---@param left number
---@param top number
---@param right number
---@param bottom number
---@return Sprite
---@protected
function Sprite.__setGrid(this, top, right, bottom, left)
    if this._image == nil then
        return this;
    end

    this._grid = { left, top, right, bottom }
    for k, v in pairs(this._grid) do
        if type(v) ~= "number" then
            this._grid[k] = tonumber(v)
        end
    end

    local left, top, right, bottom = unpack(this._grid);


    local img = this._image;
    local width, height = img:getWidth(), img:getHeight()
    this._grid_quad = this._grid_quad or {}
    this._grid_quad[7] = newQuad(this._grid_quad[7], 0, 0, left, top, width, height) --　左下角
    this._grid_quad[8] = newQuad(this._grid_quad[8], left, 0, width - right - left, top, width, height) --　左下角
    this._grid_quad[9] = newQuad(this._grid_quad[9], width - right, 0, right, top, width, height) --　左下角

    this._grid_quad[4] = newQuad(this._grid_quad[4], 0, top, left, height - top - bottom, width, height) --　左下角
    this._grid_quad[5] = newQuad(this._grid_quad[5], left, top, width - left - right, height - top - bottom, width, height) --　左下角
    this._grid_quad[6] = newQuad(this._grid_quad[6], width - right, top, right, height - top - bottom, width, height) --　左下角

    this._grid_quad[1] = newQuad(this._grid_quad[1], 0, height - bottom, left, bottom, width, height) --　左下角
    this._grid_quad[2] = newQuad(this._grid_quad[2], left, height - bottom, width - left - right, bottom, width, height) --　左下角
    this._grid_quad[3] = newQuad(this._grid_quad[3], width - right, height - bottom, right, bottom, width, height) --　左下角

    return this;
end





return Sprite;