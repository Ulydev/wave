examples[4] = function()
  
  local colors = {
    {255, 255, 255},
    {0, 0, 0}
  }
  
  function love.load()
    
    music = nil
    
  end
  
  function love.unload()
    
    if music then
      music:stop()
      music = nil
    end
    
  end

  function love.update(dt)
    
    if music then
      music:update(dt)
    end
    
  end

  function love.draw()
    
    love.graphics.setColor(colors[1])
    
    local _width, _height = love.graphics.getDimensions()
    
    local _energy, _beatTime, _side = 0, 0, -1
    if music and music:isMusic() then
      _energy = music:getEnergy()
      _beatTime = music:getBeatTime()
      _side = music:getBeat() % 2 == 1 and 1 or -1
    end
    
    love.graphics.circle("fill", _width*.5, _height*.5, 50+_energy*10)
    
    love.graphics.rectangle("fill", _width*(.5-_side*.35)-20-_energy*5, _height*.5-5-100+_beatTime*200, 40+_energy*10, 10)
    love.graphics.rectangle("fill", _width*(.5+_side*.35)-20-_energy*5, _height*.5-5+100-_beatTime*200, 40+_energy*10, 10)
    
    love.graphics.printf("drop song to load", 0, _height-140, _width, "center")
    if music and music:isMusic() then
      love.graphics.printf("bpm: " .. music.bpm, 0, _height-80, _width, "center")
    end
    
    love.graphics.setBackgroundColor(colors[2])
    
  end
  
  function love.key(key) end
  
  function love.filedropped(file)
    
    if music then
      music:stop()
      music = nil
    end
    
    music = audio
      :newSource(file, "stream")
      
      :parse()
      
      :setIntensity(20)

      :setOffset(100)
      
      :setPitch(0.1)
      :setVolume(0)
      :setTargetPitch(1)
      :setTargetVolume(.5)
      
      :setLooping(true)
      
    if music:isParsed() then
      music:detectBPM()
    end
      
    music:play() --call this when done configuring
      
    music:onBeat(function()
      colors[1], colors[2] = colors[2], colors[1]
    end)
    
  end
  
end