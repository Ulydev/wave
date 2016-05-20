-- wave.lua v0.1

-- Copyright (c) 2016 Ulysse Ramage
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

local wave, waveObject = {}, {}
setmetatable(wave, wave)

--[[ Private ]]--

local playInstance, stopInstance

local function removeStopped(sources)
	local remove = {}
	for s in pairs(sources) do
		remove[s] = true
	end
	for s in pairs(remove) do
		sources[s] = nil
	end
end

local function lerp(a, b, k) --smooth transitions
  if a == b then
    return a
  else
    if math.abs(a-b) < 0.005 then return b else return a * (1-k) + b * k end
  end
end

--[[ Public - Wave ]]--

function wave:newSource(path, type)
  local _object = {
		_paused   = false,
		path    = path,
		type       = type,
		instances = {},
		looping   = false,
		pitch     = 1,
		volume    = 1
	}
  
  setmetatable(_object, { __index = waveObject })
  
  if _object.type == "static" then
    _object:parse()
  end

  return _object
end

--[[ Public - Source ]]--

function waveObject:play(pitched)
  
  removeStopped(self.instances)
	if self._paused then self:stop() end
	local instance = love.audio.newSource(self.data or self.path, self.type)

	-- overwrite instance:stop() and instance:play()
	if not (playInstance and stopInstance) then
		playInstance = getmetatable(instance).play
		getmetatable(instance).play = error

		stopInstance = getmetatable(instance).stop
		getmetatable(instance).stop = function(this)
			stopInstance(this)
			self.instances[this] = nil
		end
	end

	instance:setLooping(self.looping)
	instance:setPitch(self.pitch+ (pitched and (math.random()-.5)*.1 or 0) )
	instance:setVolume(self.volume)

	self.instances[instance] = instance
	playInstance(instance)
	
  if self:isMusic() or self:isParsed() then
    self.instance = instance
    if self:isMusic() then --start listening to beat
      
      self.duration = self.instance:getDuration()
      self.previousFrame = love.timer.getTime() * 1000
      self.lastTime = 0
      self.time = 0
      self.beat = 0
      self.beatTime = 0
      
    end
    return self
  else
    return instance
  end
  
end

function waveObject:stop()
	for s in pairs(self.instances) do
		s:stop()
	end
	self._paused = false
	self.instances = {}
end

function waveObject:pause()
	if self._paused then return end
	for s in pairs(self.instances) do
		s:pause()
	end
	self._paused = true
end

function waveObject:resume()
	if not self._paused then return end
	for s in pairs(self.instances) do
		s:resume()
	end
	self._paused = false
end

--// Configure music

function waveObject:parse()
  if self.data then return self end
  self.data = love.sound.newSoundData(self.path)
  return self
end

--

function waveObject:setBPM(bpm)
  self.bpm = bpm
  self.bps = 60 / bpm
  return self
end

function waveObject:setOffset(offset)
  self.offset = offset
  return self
end

function waveObject:onBeat(f)
  self.onBeat = f
  return self
end

function waveObject:getBeat()
  return self.beat
end

function waveObject:getBeatTime()
  return self.beatTime-self.beat
end

--

function waveObject:setIntensity(intensity)
  self.intensity = intensity
  self.energy = 0
  return self
end

function waveObject:getEnergy()
  self:isParsed()
  return self.energy
end

--// Get/set properties
for _, property in ipairs{'looping', 'pitch', 'volume'} do
	local name = property:sub(1,1):upper() .. property:sub(2)
  
	waveObject['get' .. name] = function(self)
		return self[property]
	end

	waveObject['set' .. name] = function(self, val)
		self[property] = val
		for s in pairs(self.instances) do
			s['set' .. name](s, val)
		end
    return self
	end
end

for _, property in ipairs{'pitch', 'volume'} do
	local name = 'Target' .. property:sub(1,1):upper() .. property:sub(2)
	waveObject['get' .. name] = function(self)
		return self['target' .. property]
	end

	waveObject['set' .. name] = function(self, val)
		self['target' .. property] = val
    return self
	end
end

--// Update

function waveObject:update(dt)
  if self:isMusic() then self:updateBeat(dt) end
  if self:isParsed() then self:updateEnergy(dt) end
  
  self:updateProperties(dt)
  
  return self
end

function waveObject:updateBeat(dt)
  local _instance = self.instances[self.instance]
  if not _instance then return self end
  
  local _offset = love.timer.getTime() * 1000
  
  local _elapsedBeats = 0
  
  self.time = self.time + _offset - self.previousFrame
  
  self.previousFrame = _offset
  local _position = _instance:tell("seconds") * 1000
  if _position < self.lastTime then --music looped
    self.time = _position
    self.lastTime = _position
    _elapsedBeats = _elapsedBeats + 1
    self.beat = 0
  elseif _position ~= self.lastTime then --Updates music time, but with easing
    self.time = (self.time + (_position))/2
    self.lastTime = _position
  end
  
  self.beatTime = (self.bpm / 60) * ((self.time + (self.offset or 0)) % (self.duration * 1000)) / 1000
  
  local _beat = math.floor(self.beatTime)
  _elapsedBeats = _elapsedBeats + _beat - self.beat
  self.beat = _beat
  
  if self.onBeat then
    for i = 1, _elapsedBeats do
      self.onBeat()
    end
  end
  
  return self
end

function waveObject:updateEnergy(dt)
  local _instance = self.instances[self.instance]
  if not _instance then return self end
  
  local _sample = _instance:tell( "samples" )
  if _sample-1024 > 0 then
    
    local _energy = 0
    for i = _sample, _sample+1024 do
      _energy = _energy + (self.data:getSample(i)^2)/self.intensity
    end
    self.energy = lerp(self.energy, _energy, 10*dt)
     
  end
  return self
end

function waveObject:updateProperties(dt)
  self:setPitch(lerp(self:getPitch(), self:getTargetPitch(), 2*dt))
  self:setVolume(lerp(self:getVolume(), self:getTargetVolume(), 2*dt))
end

--// Checks

function waveObject:isMusic() return self.bpm and true or false end
function waveObject:isParsed() return self.data and true or false end

--[[ Aliases ]]--

waveObject.isLooping = waveObject.getLooping

--[[ End ]]--

return wave