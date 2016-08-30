io.stdout:setvbuf'no' 

audio = require "wave" --require the library
love.window.setTitle("Press Space to switch examples")

examples = {}
example = 1

require "examples/1"
require "examples/2"
require "examples/3"
require "examples/4"

function love.keypressed(key, scancode, isrepeat)
  
  if key == "space" then
    example = (example < #examples) and example + 1 or 1
    if love.unload then love.unload() end
    love.filedropped = function () end
    love.update = function () end
    love.draw = function () end
    examples[example]()
    love.load()
  else
    if love.key then love.key(key) end
  end
  
end

examples[example]()