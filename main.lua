io.stdout:setvbuf'no' 

audio = require "wave" --require the library
love.window.setTitle("Press Space to switch examples")

examples = {}
example = 1

require "examples/1"
require "examples/2"

function love.keypressed(key, scancode, isrepeat)
  
  if key == "space" then
    example = (example < #examples) and example + 1 or 1
    if love.unload then love.unload() end
    examples[example]()
    love.load()
  else
    if love.key then love.key(key) end
  end
  
end

examples[example]()