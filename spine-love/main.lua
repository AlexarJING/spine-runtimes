-------------------------------------------------------------------------------
-- Spine Runtimes Software License
-- Version 2.3
-- 
-- Copyright (c) 2013-2015, Esoteric Software
-- All rights reserved.
-- 
-- You are granted a perpetual, non-exclusive, non-sublicensable and
-- non-transferable license to use, install, execute and perform the Spine
-- Runtimes Software (the "Software") and derivative works solely for personal
-- or internal use. Without the written permission of Esoteric Software (see
-- Section 2 of the Spine Software License Agreement), you may not (a) modify,
-- translate, adapt or otherwise create derivative works, improvements of the
-- Software or develop new applications using the Software or (b) remove,
-- delete, alter or obscure any trademarks or any copyright, trademark, patent
-- or other intellectual property or proprietary rights notices on or in the
-- Software, including any copy thereof. Redistributions in binary or source
-- form must include this license and terms.
-- 
-- THIS SOFTWARE IS PROVIDED BY ESOTERIC SOFTWARE "AS IS" AND ANY EXPRESS OR
-- IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
-- MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
-- EVENT SHALL ESOTERIC SOFTWARE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
-- SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
-- OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
-- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------------------------------------

local spine = require "spine-love.spine-love"

function love.load(arg)
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  
  image = love.graphics.newImage("data/spineboy.png")
  batcher = spine.PolygonBatcher.new(6)
  
  local atlas = spine.TextureAtlas.new(spine.utils.readFile("data/spineboy.atlas"), 
                                       function (path) return love.graphics.newImage("data/" .. path) end)
  
  local json = spine.SkeletonJson.new(spine.TextureAtlasAttachmentLoader.new(atlas))
  json.scale = 0.6
  local skeletonData = json:readSkeletonDataFile("data/spineboy.json")

  skeleton = spine.Skeleton.new(skeletonData)
  skeleton.x = love.graphics.getWidth() / 2
  skeleton.y = love.graphics.getHeight() / 2 + 250
  skeleton.flipX = false
  skeleton.flipY = true
  -- skeleton.debugBones = true -- Omit or set to false to not draw debug lines on top of the images.
  -- skeleton.debugSlots = true
  skeleton:setToSetupPose()

  -- AnimationStateData defines crossfade durations between animations.
  local stateData = spine.AnimationStateData.new(skeletonData)
  stateData:setMix("walk", "jump", 0.2)
  stateData:setMix("jump", "run", 0.2)

  -- AnimationState has a queue of animations and can apply them with crossfading.
  state = spine.AnimationState.new(stateData)
  -- state:setAnimationByName(0, "test")
  state:setAnimationByName(0, "walk", true)
  state:addAnimationByName(0, "jump", true, 3)
  state:addAnimationByName(0, "run", true, 0)

  state.onStart = function (trackIndex)
    print(trackIndex.." start: "..state:getCurrent(trackIndex).animation.name)
  end
  state.onEnd = function (trackIndex)
    print(trackIndex.." end: "..state:getCurrent(trackIndex).animation.name)
  end
  state.onComplete = function (trackIndex, loopCount)
    print(trackIndex.." complete: "..state:getCurrent(trackIndex).animation.name..", "..loopCount)
  end
  state.onEvent = function (trackIndex, event)
    print(trackIndex.." event: "..state:getCurrent(trackIndex).animation.name..", "..event.data.name..", "..event.intValue..", "..event.floatValue..", '"..(event.stringValue or "").."'")
  end
  
  skeletonRenderer = spine.SkeletonRenderer.new()
end

function love.update (delta)
	-- Update the state with the delta time, apply it, and update the world transforms.
	state:update(delta)
	state:apply(skeleton)
	skeleton:updateWorldTransform()
end

function love.draw ()
  love.graphics.setBackgroundColor(255, 0, 255, 255)
	love.graphics.setColor(255, 255, 255)
  skeletonRenderer:draw(skeleton)
  batcher:begin()
  batcher:draw(image, {
      0, 0, 0, 0, 1, 1, 1, 1,
      100, 0, 1, 0, 1, 1, 1, 1,
      100, 100, 1, 1, 1, 1, 1, 1,
      0, 100, 0, 1, 1, 1, 1, 1,
    }, 
    { 1, 2, 3, 3, 4, 1 })
  batcher:draw(image, {
    100, 0, 0, 0, 1, 1, 1, 1,
    200, 0, 1, 0, 1, 1, 1, 1,
    200, 100, 1, 1, 1, 1, 1, 1,
    100, 100, 0, 1, 1, 1, 1, 1,
  }, 
  { 1, 2, 3, 3, 4, 1 })
  batcher:stop()
end
