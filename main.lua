---@diagnostic disable: lowercase-global
love = require('love')

function love.load()
  canvas = love.graphics.newCanvas(320, 240)
  canvas:setFilter("nearest", "nearest")

  player = {
    sprite = love.graphics.newImage("sprites/cat.png"),
    speed = 50,
    pos = {
      x = 0,
      y = 0
    },
    prev = {
      x = 0,
      y = 0
    },
    animation = {
      current = "idle",
      frame = 1,
      timer = 1,
      flip = false,
      ["idle"] = {
        frames = {},
        len = 6,
        loop = true
      },
      ["running"] = {
        frames = {},
        len = 8,
        loop = true
      }
    }
  }

  function player:load_sprite()
    local frame_w = 16
    local frame_h = 20

    local offset = 1
    -- idle
    for i = 0, self.animation["running"].len do
      table.insert(self.animation["idle"].frames,
        love.graphics.newQuad(i * frame_w, 0, frame_w, frame_h, player.sprite:getWidth(),
          player.sprite:getHeight()))
    end
    offset = self.animation["idle"].len
    -- running
    for i = 0, self.animation["running"].len do
      table.insert(self.animation["running"].frames,
        love.graphics.newQuad(i * frame_w + offset * frame_w, 0, frame_w, frame_h, player.sprite:getWidth(),
          player.sprite:getHeight()))
    end
  end

  function player:update(dt)
    self.animation.current = "idle"

    self.prev.x = self.pos.x
    if love.keyboard.isDown('d') then
      self.pos.x = self.pos.x + self.speed * dt
      self.animation.current = "running"
      self.animation.flip = false
    end

    self.prev.x = self.pos.x
    if love.keyboard.isDown('a') then
      self.pos.x = self.pos.x - self.speed * dt
      self.animation.current = "running"
      self.animation.flip = true
    end
  end

  function player:animate(dt)
    local current_animation = self.animation[self.animation.current]
    self.animation.timer = self.animation.timer + dt

    if self.animation.timer > 0.2 then
      self.animation.timer = 0.1
      self.animation.frame = self.animation.frame + 1

      if current_animation ~= nil and self.animation.frame > current_animation.len then
        if current_animation.loop then
          self.animation.frame = 1
        else
          self.animation.frame = current_animation.len
        end
      end
    end
  end

  function player:draw()
    local current_animation = self.animation[self.animation.current]
    if current_animation ~= nil then
      if self.animation.flip then
        love.graphics.draw(self.sprite, current_animation.frames[self.animation.frame],
          self.pos.x, self.pos.y, 0, -1, 1, 16, 0)
      else
        love.graphics.draw(self.sprite, current_animation.frames[self.animation.frame],
          self.pos.x, self.pos.y)
      end
    end
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
  player:animate(dt)
end

function love.draw()
  love.graphics.push()
  love.graphics.scale(1.5)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(player.animation.current .. ", " .. player.animation.frame, 0, 0)
  love.graphics.pop()

  love.graphics.setCanvas(canvas)
  love.graphics.clear()
  player:draw()

  love.graphics.setCanvas()
  love.graphics.draw(canvas, 0, 0, 0, 10, 10)
end
