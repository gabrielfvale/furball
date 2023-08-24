---@diagnostic disable: lowercase-global
love = require('love')

function love.load()
  canvas = love.graphics.newCanvas(320, 240)
  canvas:setFilter("nearest", "nearest")

  gravity = 200

  _G.player = {
    sprite = love.graphics.newImage("sprites/cat.png"),
    speed = 50,
    jump = 100,
    x_vel = 0,
    y_vel = 0,
    pos = {
      x = 0,
      y = 88
    },
    animation = {
      current = "idle",
      prev = "idle",
      frame = 1,
      timer = 1,
      flip = false,
      ["idle"] = {
        frames = {},
        len = 6,
        loop = true
      },
      ["run"] = {
        frames = {},
        len = 8,
        loop = true
      },
      ["jump"] = {
        frames = {},
        len = 6,
        loop = false
      },
      ["fall"] = {
        frames = {},
        len = 2,
        loop = false
      }
    }
  }

  function player:load_sprite()
    local frame_w = 16
    local frame_h = 20

    local offset = 1
    -- idle
    for i = 0, self.animation["run"].len do
      table.insert(self.animation["idle"].frames,
        love.graphics.newQuad(i * frame_w, 0, frame_w, frame_h, player.sprite:getWidth(),
          player.sprite:getHeight()))
    end
    offset = self.animation["idle"].len
    -- run
    for i = 0, self.animation["run"].len do
      table.insert(self.animation["run"].frames,
        love.graphics.newQuad(i * frame_w + offset * frame_w, 0, frame_w, frame_h, player.sprite:getWidth(),
          player.sprite:getHeight()))
    end
    offset = offset + self.animation["run"].len
    -- jump
    for i = 0, self.animation["jump"].len do
      table.insert(self.animation["jump"].frames,
        love.graphics.newQuad(i * frame_w + offset * frame_w, 0, frame_w, frame_h, player.sprite:getWidth(),
          player.sprite:getHeight()))
    end
    offset = offset + self.animation["jump"].len
    -- fall
    for i = 0, self.animation["fall"].len do
      table.insert(self.animation["fall"].frames,
        love.graphics.newQuad(i * frame_w + offset * frame_w, 0, frame_w, frame_h, player.sprite:getWidth(),
          player.sprite:getHeight()))
    end
  end

  function player:change_anim(animation, flip)
    self.animation.prev = self.animation.current
    self.animation.current = animation

    if flip ~= nil then
      self.animation.flip = flip
    end
    if self.animation.prev ~= animation then -- reset animation
      self.animation.frame = 1
      self.animation.timer = 1
    end
  end

  function player:update(dt)
    if self.x_vel == 0 and self.y_vel == 0 then
      player:change_anim("idle")
    end

    player.x_vel = 0

    if love.keyboard.isDown('d') then
      player.x_vel = self.speed
    end

    if love.keyboard.isDown('a') then
      player.x_vel = -self.speed
    end

    if love.keyboard.isDown('space') then
      if self.y_vel == 0 then
        self.y_vel = -1 * self.jump
      end
    end

    if self.x_vel > 0 then
      player:change_anim("run", false)
    elseif self.x_vel < 0 then
      player:change_anim("run", true)
    end

    if self.y_vel < 0 then
      player:change_anim("jump")
    elseif self.y_vel > 0 then
      player:change_anim("fall")
    end

    if self.x_vel ~= 0 then
      self.pos.x = self.pos.x + self.x_vel * dt
    end

    if self.y_vel ~= 0 then
      self.pos.y = self.pos.y + self.y_vel * dt
      self.y_vel = self.y_vel + gravity * dt
    end
    -- hit ground
    if self.pos.y > 88 then
      self.y_vel = 0
      self.pos.y = 88
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
  love.graphics.print(string.format("%s %s", player.animation.current, player.animation[player.animation.current].len), 0,
    0)
  love.graphics.print(string.format("x_vel %d, y_vel %d", player.x_vel, player.y_vel), 0, 20)
  love.graphics.pop()

  love.graphics.setCanvas(canvas)
  love.graphics.clear()
  player:draw()

  love.graphics.setCanvas()
  love.graphics.draw(canvas, 0, 0, 0, 10, 10)
end
