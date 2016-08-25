examples[2] = function()
  
  function love.load()
    
    love.graphics.setNewFont(42)
    
    music = audio
      :newSource("music.wav", "stream")
      
      :setPitch(0.1)
      :setVolume(0)
      :setTargetPitch(1)
      :setTargetVolume(.5)
      
      :setLooping(true)
      
      :play() --call this when done configuring
      
    sound = audio:newSource("sound.wav")
    
    fade = "in"
  
  end
  
  function love.unload()
    music:stop()
    music = nil
    sound = nil
  end

  function love.update(dt)
    
    music:update(dt)
    
  end

  function love.draw()
    
    love.graphics.setColor(255, 255, 255)
    
    love.graphics.printf("K to play sound\nF to fade in/out music", 24, 240, love.graphics.getWidth(), "left")
    
    love.graphics.setBackgroundColor(0, 0, 0)
    
  end
  
  function love.key(key)
    if key == "k" then
      sound:play(true) --pitched
    elseif key == "f" then
      fade = fade == "in" and "out" or "in"
      music:fade(fade, fade == "in" and .5)
    end
  end
  
end