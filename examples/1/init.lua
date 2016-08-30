examples[1] = function()
  
  local colors = {
    {255, 255, 255},
    {0, 0, 0}
  }

  function love.load()
    
    music = audio
      :newSource("music.wav", "stream")
      
      :parse()
      
      :setIntensity(20)
      
      :setBPM(120)
      
      :setOffset(100)
      
      :setPitch(0.1)
      :setVolume(0)
      :setTargetPitch(1)
      :setTargetVolume(.5)
      
      :setLooping(true)
      
      :play() --call this when done configuring
      
    music:onBeat(function()
      colors[1], colors[2] = colors[2], colors[1]
    end)
  
  end
  
  function love.unload()
    music:stop()
    music = nil
  end

  function love.update(dt)
    
    music:update(dt)
    
    local dir = (love.keyboard.isDown("left") and -1) or (love.keyboard.isDown("right") and 1) or 0
    music:setTargetPitch(math.min(math.max(music:getTargetPitch() + dt * dir, .1), 2)) --between 0.1 and 2
    
  end

  function love.draw()
    
    love.graphics.setColor(colors[1])
    
    local _width, _height = love.graphics.getDimensions()
    local _energy = music:getEnergy()
    local _beatTime = music:getBeatTime()
    local _side = music:getBeat() % 2 == 1 and 1 or -1
    
    love.graphics.circle("fill", _width*.5, _height*.5, 50+_energy*10)
    
    love.graphics.rectangle("fill", _width*(.5-_side*.35)-20-_energy*5, _height*.5-5-100+_beatTime*200, 40+_energy*10, 10)
    love.graphics.rectangle("fill", _width*(.5+_side*.35)-20-_energy*5, _height*.5-5+100-_beatTime*200, 40+_energy*10, 10)
    
    love.graphics.setBackgroundColor(colors[2])
    
  end
  
  function love.key(key) end
  
end