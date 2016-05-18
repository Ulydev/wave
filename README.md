wave
==============

wave is a LÖVE sound manager with advanced audio parsing functionalities.

<img src="http://s32.postimg.org/8n00sidfn/out.gif" alt="demo" width="420"/>

Setup
----------------

```lua
local audio = require "wave" --require the library
```

Usage
----------------

Create a new source
```lua
local beep = audio:newSource("beep.wav", "static")
```

Play it
```lua
beep:play()
```

Parsing audio
----------------

wave parses audio files to get the "energy" of the song. This allows you to add visual effects that are synchronized with the music.

First, load and parse the audio, then set its intensity
```lua
music = audio:newSource("music.wav", "stream")
music:parse()
music:setIntensity(20)
```

Update it every frame
```lua
function love.update(dt)
  music:update(dt)
end
```

Then, get the current energy of the song
```lua
function love.draw()
  love.graphics.circle(100, 100, 100+music:getEnergy()*10)
end
```

Working with rhythm
----------------

wave lets you set the BPM of your song to add rhythm-based mechanics to your game.

Load the audio and set its BPM
```lua
music = audio:newSource("music.wav", "stream")
music:setBPM(120)
```

Set a beat callback
```lua
music:onBeat(function()
  print("Beat!")
end)
```

Update the music every frame
```lua
function love.update(dt)
  music:update(dt)
end
```

Smooth transitions
----------------

Both **pitch** and **volume** properties of a source can be smoothly transitioned.

Set targets
```lua
source:setPitchTarget(1.2)
source:setVolumeTarget(.5)
```

Update the source every frame
```lua
function love.update(dt)
  source:update(dt)
end
```

Chaining functions
----------------

**Source** objects are passed through most of the methods. This allows you to chain function calls like so:
```lua
dog = audio
  :newSource("dog.wav", "static")
  :setVolume(.5)
  :play()
```

Methods and aliases
----------------

Create a new source
```lua
source = audio:newSource(path, type)
```

Play, pause, resume and stop a source
```lua
source:play(pitched) --if pitched == true, source will play with a slightly random pitch (useful for recurrent sounds)
source:stop()

source:pause()
source:resume()
```

Parse source
```lua
source:parse()
```

Set/get source properties
```lua
source:setBPM(bpm)

source:setOffset(offset) --set beat offset (milliseconds)

source:setIntensity(intensity)

source:setPitch(pitch)
//-> source:getPitch()

source:setVolume(volume)
//-> source:getVolume()

source:setLooping(bool)
```

Set/get source target properties (will transition smoothly)
```lua
source:setTargetPitch(pitch)
//-> source:getTargetPitch()

source:setTargetVolume(volume)
//-> source:getTargetVolume()
```