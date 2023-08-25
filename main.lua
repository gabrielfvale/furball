---@diagnostic disable: lowercase-global, undefined-field
love = require('love')
local anim8 = require('lib.anim8')

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")

  gravity = 1000
  scale_factor = 10

  _G.player = {
    speed = 50 * scale_factor,
    jump = 600,
    dir = 1,
    vel = {
      x = 0,
      y = 0
    },
    pos = {
      x = 0,
      y = love.graphics.getHeight() - 20 * scale_factor
    },
    sprite = love.graphics.newImage("sprites/cat.png"),
    quad_dim = {
      w = 16,
      h = 20
    },
    animation = {
      current = "idle",
    }
  }

  function player:load_sprite()
    self.animation.grid = anim8.newGrid(self.quad_dim.w, self.quad_dim.h, self.sprite:getWidth(), self.sprite:getHeight())
    -- idle
    self.animation.idle = anim8.newAnimation(self.animation.grid('1-6', 1), 0.1)
    -- run
    self.animation.run = anim8.newAnimation(self.animation.grid('7-14', 1), 0.1)
    -- jump
    self.animation.jump = anim8.newAnimation(self.animation.grid('15-17', 1), 0.1, 'pauseAtEnd')
    -- fall
    self.animation.fall = anim8.newAnimation(self.animation.grid('18-20', 1), 0.1, 'pauseAtEnd')
  end

  function player:getAnim()
    return player.animation[player.animation.current]
  end

  function player:update(dt)
    player:getAnim():update(dt)

    if self.vel.x == 0 and self.vel.y == 0 then
      player.animation.current = "idle"
    end

    player.vel.x = 0

    if love.keyboard.isDown('d') then
      player.vel.x = self.speed
      self.dir = 1
    end

    if love.keyboard.isDown('a') then
      player.vel.x = -self.speed
      self.dir = -1
    end

    if love.keyboard.isDown('space') then
      if self.vel.y == 0 then
        self.vel.y = -self.jump
      end
    end

    if self.vel.y == 0 then
      if self.vel.x ~= 0 then
        player.animation.current = "run"
      end
    end

    if self.vel.y < 0 then
      if self.animation.current ~= "jump" then
        player.animation.current = "jump"
        player:getAnim():gotoFrame(1)
        player:getAnim():resume()
      end
    elseif self.vel.y > 0 then
      if self.animation.current ~= "fall" then
        player.animation.current = "fall"
        player:getAnim():gotoFrame(1)
        player:getAnim():resume()
      end
    end

    if self.vel.x ~= 0 then
      self.pos.x = self.pos.x + self.vel.x * dt
    end

    if self.vel.y ~= 0 then
      self.pos.y = self.pos.y + self.vel.y * dt
      self.vel.y = self.vel.y + gravity * dt
    end
    -- hit ground
    if self.pos.y > love.graphics.getHeight() - 20 * scale_factor then
      self.vel.y = 0
      self.pos.y = love.graphics.getHeight() - 20 * scale_factor
    end
  end

  function player:draw()
    player:getAnim():draw(self.sprite, self.pos.x + self.quad_dim.w / 2, self.pos.y, nil, self.dir * scale_factor,
      scale_factor,
      self.quad_dim.w / 2, 0)
  end

  player:load_sprite()
end

function love.keypressed(k)
  if k == 'escape' then
    love.event.push('quit')
  end
end

function love.update(dt)
  player:update(dt)
end

function love.draw()
  love.graphics.push()
  love.graphics.scale(1.5)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(string.format("%s", player.animation.current), 0, 0)
  love.graphics.print(string.format("vel.x %d, vel.y %d", player.vel.x, player.vel.y), 0, 20)
  love.graphics.pop()

  love.graphics.setBackgroundColor(127 / 255, 143 / 255, 166 / 255)

  player:draw()
end
