examples[3] = function()
  
  function love.load()
    
    music = audio
      :newSource("music.wav", "stream")
      
      :setPitch(0.1)
      :setVolume(0)
      :setTargetPitch(1)
      :setTargetVolume(.5)
      
      :setLooping(true)
      
      :play() --call this when done configuring
  
  end
  
  function love.unload()
    music:stop()
    music = nil
  end

  function love.update(dt)
    
    music:update(dt)
    
  end

  function love.draw()
    
    love.graphics.setColor(255, 255, 255)
    
    local string = "left/right to shift key\nlshift + left/right to shift octave\n\npitch: " .. music:getTargetPitch()
    
    love.graphics.printf(string, 24, 240, love.graphics.getWidth(), "left")
    
    love.graphics.setBackgroundColor(0, 0, 0)
    
  end
  
  function love.key(key)
    if not (key == "left" or key == "right") then return true end
    
    local dir = key == "left" and -1 or key == "right" and 1
    if love.keyboard.isDown("lshift") then
      music:setPitch( music:octave(dir), true )
    else
      music:setPitch( music:tone(dir), true )
    end
  end
  
end