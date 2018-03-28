---
--- Created by fox.
--- DateTime: 2018/3/14 21:40
---
--[[
    使用这个框架将会注册以下几个全局变量，请注意不要冲突
        class
        import
--]]

class = require("nodeFrame.class");
import = require("nodeFrame.import");

local Node = require("nodeFrame.core.Display.Node");
local Drawable = require("nodeFrame.core.Display.Drawable");
--local Graphics = require("nodeFrame.core.Display.Graphics");

local Loader = require("nodeFrame.core.Net.Loader");

local Timer = require("nodeFrame.core.Utils.Timer");
local Tween = require("nodeFrame.core.Utils.Tween");
local Ease = require("nodeFrame.core.Utils.Ease");

local Label = require("nodeFrame.ui.Label");
local Sprite = require("nodeFrame.ui.Image");

local Stage = require("nodeFrame.core.Display.Stage")
local stage = Stage.new();



local sclaeX, sclaeY = 1, 1
local offsetX, offsetY = 0, 0
local function resize( w, h)
    local minScale = math.min(w / stage.width, h / stage.height)
    sclaeX, sclaeY = minScale, minScale
    offsetX, offsetY = (w - (stage.width * minScale)) / 2, (h - (stage.height * minScale)) / 2;
end

local function touchPoint(x, y)
    x = x - offsetX
    x = x / (sclaeX * stage.width) * stage.width
    if (x < 0) then
        x = 0
    end
    if (x > stage.width) then
        x = stage.width
    end

    y = y - offsetY
    y = y / (sclaeY * stage.height) * stage.height
    if (y < 0) then
        y = 0
    end
    if (y > stage.height) then
        y = stage.height
    end
    return x, y
end

local function load( )

end

local function update(dt)
    Timer._updateAll(dt);
    Tween._update(dt);
end

local function draw()
    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(sclaeX,sclaeY)
    stage:draw()
    love.graphics.pop()
    love.graphics.setShader(unpack({}))
end

local function mouseEvent(type,x,y)
    local _x,_y = touchPoint(x,y)
    stage:event(type,{type,_x,_y})
end

local function wheelmoved( x, y )
end


local function touchmoved( id, x, y, dx, dy, pressure )
    mouseEvent("MOUSE_MOVE",x,y)
end
local function touchpressed( id, x, y, dx, dy, pressure )
    mouseEvent("MOUSE_DOWN",x,y)
end
local function touchreleased( id, x, y, dx, dy, pressure )
    mouseEvent("MOUSE_UP",x,y)
end

local function mousereleased(x, y, button, istouch)
    mouseEvent("MOUSE_UP",x,y)
end
local function mousepressed(x, y, button, istouch)
    mouseEvent("MOUSE_DOWN",x,y)
end
local function mousemoved( x, y, dx, dy, istouch)
    mouseEvent("MOUSE_MOVE",x,y)
end

local function keypressed(key, scancode, isrepeat)
end
local function keyreleased(key, scancode)
end

local function focus(b)
end

local export = {
    version = 0.1,
    versionName = "node",

    Node = Node,
    Drawable = Drawable,
    Loader = Loader,
    Timer = Timer,
    Tween = Tween,
    Ease = Ease,

    Label = Label,
    Sprite = Sprite,

    --@public
    stage = stage,

    --@public
    register = nil,
    load = load,
    update = update,
    draw = draw,
    focus = focus,
    resize = resize,
    keypressed = keypressed,
    keyreleased = keyreleased,
    mousemoved = mousemoved,
    mousepressed = mousepressed,
    mousereleased = mousereleased,
    touchmoved = touchmoved,
    touchpressed = touchpressed,
    touchreleased = touchreleased,
    wheelmoved = wheelmoved,

}

local function init(title,width,height)
    stage.width = width;
    stage.height = height;
    resize(love.graphics.getWidth(),love.graphics.getHeight())
    return export;
end

local function register()
    local funcs = {"load","update","draw","focus","resize","keypressed","keyreleased","wheelmoved"};

    local touchFuncs = {"touchmoved","touchreleased","touchpressed"};
    local system = string.lower(love.system.getOS());
    if system == "windows" or system == "linux" then
        touchFuncs = {"mousemoved","mousepressed","mousereleased"}
    end

    for _, name in pairs(touchFuncs) do
        love[name] = export[name];
    end
    for _, name in pairs(funcs) do
        love[name] = export[name];
    end
    return export;
end

export.register = register;

return init;