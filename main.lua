function love.load()
  canvas = love.graphics.newCanvas(320,240)
  canvas:setFilter("nearest", "nearest")

  bagas = love.graphics.newImage("sprites/bagas.png")
  frames = {}
  local frame_w = 16
  local frame_h = 20
  for i=0,8 do
    table.insert(frames, love.graphics.newQuad(i * frame_w + 6*frame_w, 0, frame_w, frame_h, bagas:getWidth(), bagas:getHeight()))
  end

  currentFrame = 1
  timer = 0.1

end

function love.keypressed(k)
	if k == 'escape' then
		love.event.push('quit')
	end	
end

function love.update(dt)
  timer = timer + dt

  if timer > 0.18 then
    timer = 0.1
    currentFrame = currentFrame + 1
    if currentFrame > 8 then
      currentFrame = 1
    end
  end

end

function love.draw()
  love.graphics.setCanvas(canvas)
  love.graphics.clear()
  love.graphics.draw(bagas, frames[math.floor(currentFrame)], 100, 100)
  love.graphics.setCanvas()
  love.graphics.draw(canvas, 0, 0, 0, 8, 8)
end
