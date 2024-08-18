love = require("love")
utils = require("utils")

GameData = {}
GameData.gravity = 700
GameData.dt = 0

GameObject = {}
function GameObject:new(x, y, w, h, color)
	local o = {}
	o.x = x
	o.y = y
	o.w = w
	o.h = h
	o.color = color

	setmetatable(o, self)
	self.__index = self
	return o
end

function GameObject:collides(object)
	return self.x < object.x + object.w and
	self.x + self.w > object.x   and
	self.y < object.y + object.h and
	self.y + self.h > object.y
end

-- color is gonna be a table of the
-- format { r, g, b }
function GameObject:setColor(color)
	for _, v in pairs(color) do
		if not v or v > 255 then return nil end
	end

	self.color = color
end

function GameObject:applyGravity()
	self.y = self.y + (GameData.gravity * GameData.dt)
end

function GameObject:draw(mode)
	local old_r, old_g, old_b = love.graphics.getColor()

	love.graphics.setColor(self.color)
	love.graphics.rectangle(mode, self.x, self.y, self.w, self.h)
	love.graphics.setColor(old_r, old_g, old_b) -- reset to the old color
end

function love.load()
	-- game objects
	Player = GameObject:new()
	Player.x = love.graphics.getWidth() / 2
	Player.y = love.graphics.getHeight() / 2
	Player.w = 20
	Player.h = 40
	Player.color = { 255, 255, 255 }
	Player.speed = 500

	Platform = GameObject:new()
	Platform.w = love.graphics.getWidth()
	Platform.h = 50
	Platform.y = love.graphics.getHeight() - Platform.h - 20
	Platform.x = 0
	Platform.color = { 255, 255, 255 }

	Gun = GameObject:new(0, 0, 20, 10, { 255, 255, 255 })
	Gun.shoot_cd = 0.1 -- shooting cooldown
	Gun.is_shooting = false

	Bullet = GameObject:new(0, 0, 0, 2, { 255, 255, 255 })
	Bullet.line_angle = 0
end

function love.update(dt)
	GameData.dt = dt

	Gun.x = Player.x + Player.w + 5
	Gun.y = Player.y + 20

	-- cooldown to shooting and the life time of the bullet
	if Gun.is_shooting then
		Gun.shoot_cd = Gun.shoot_cd - GameData.dt

		if Gun.shoot_cd <= 0 then
			Gun.is_shooting = false
			Gun.shoot_cd = 0.1
		end
	end

	if not Player:collides(Platform) then
		Player:applyGravity()
	end
	if Player:collides(Platform) then
		Player.y = Platform.y - Player.h
	end
end

function love.keypressed(key)
	if key == "a" then
		Player.x = Player.x - (Player.speed * GameData.dt)
	end

	if key == "d" then
		Player.x = Player.x + (Player.speed * GameData.dt)
	end
end

function love.mousepressed(mx, my, button)
	if button == 1 and not Gun.is_shooting then
		local dx = mx - Gun.x
		local dy = my - Gun.y

		-- calculate the angle in which the bullet line
		-- has to be in order to go towards the mouse's position
		Bullet.line_angle = math.atan2(dy, dx) + utils.randomfloat(-0.1, 0.1)
		Bullet.w = love.graphics.getWidth()
		Gun.is_shooting = true

		print("shot at angle " .. Bullet.line_angle .. " degrees")
		print("x = " .. Bullet.x, ", y = " .. Bullet.y)
		print("w = " .. Bullet.w, ", h = " .. Bullet.h)
	end
end

function love.draw()
	Player:draw("line")
	Platform:draw("line")
	Gun:draw("line")

	if Gun.is_shooting then
		love.graphics.push()

		love.graphics.translate(Gun.x, Gun.y) -- set the origin point for the angle
		love.graphics.rotate(Bullet.line_angle)
		Bullet:draw("fill")

		love.graphics.pop()
	end
end
