--[[ fnaf 2 port psych engine port fnf code !!!!!!!!!!!!!!!!!!
	(this took me several months)

	so uhh
	basics

	camera system in hscript (i spent like 2 days to get that shit working thanks laztrix for giving me the idea)
	sound system in hscript that supports playback rates (yes this port supports playback rates lmfao)
	
	and alotta wacky shit that took me hours of pain to make so have fun looking through this shithole

	oh yea also
	no animatronics
	that shit took way too much time out of my lifespan

	credits:
	mayo78 - originally gave me code for the mask and the looking around the room shit but i ended up rewriting both of them so gfdjfhjgdjfhg
	laztrix - gave me the idea for seperate cameras (even though i had this idea for months i just didn't know how to make it work until they did it in hscript somehow fkhjggfkjgfhjgf)
]]

-- mask shit --
mouseOverlapMask = false -- mouse overlapping the mask button
maskCooldown = 0 -- mask put on cooldown thing
maskActive = false -- the mask being active or not

-- camera shit --
mouseOverlapCamera = false --these 3 are basically the same thing as the mask
cameraCooldown = 0
cameraActive = false

canWind = false -- if you can wind or not
isWinding = false -- if you are winding or not

lastCam = 9 -- last camera you were on
curCam = 9 -- current camera you are on
cameraButtons = { -- camera button positions need i say less
	-- [cam] = {x, y}
	
	[1] = {800, 490},
	[2] = {935, 490},
	[3] = {800, 430},
	[4] = {935, 430},
	[5] = {810, 583},
	[6] = {925, 583},
	[7] = {958, 365},
	[8] = {805, 355},
	[9] = {1115, 325},
	[10] = {1047, 443},
	[11] = {1150, 400},
	[12] = {1135, 490}
}

cameras = { -- camera sprites
    default = {
		[1] = function() return 'Off' end,
		[2] = function() return 'DefaultOff' end,
		[3] = function() return 'DefaultOff' end,
		[4] = function() return 'DefaultOff' end,
		[5] = function() return 'Off' end,
		[6] = function() return 'Off' end,
		[7] = function() return 'DefaultOff' end,
		[8] = function() return 'Off' end,
		[9] = function() return 'AllOff' end,
		[10] = function() return 'DefaultOff' end,
		[11] = function() return 'Off' end,
		[12] = function() return 'Off' end,
	},
	on = {
		[1] = function() return 'DefaultOn' end,
		[2] = function() return 'DefaultOn' end,
		[3] = function() return 'DefaultOn' end,
		[4] = function() return 'DefaultOn' end,
		[5] = function() return 'On' end,
		[6] = function() return 'On' end,
		[7] = function() return 'DefaultOn' end,
		[8] = function() return 'AllOn' end,
		[9] = function() return 'AllOn' end,
		[10] = function() return 'DefaultOn' end,
		[11] = function() return 'On' end,
		[12] = function() return 'DefaultOn' end
	}
}

--light shit --
flashlightHealth = 100
usingMainLight = false
usingLeftVent = false
usingRightVent = false
usingLight = false

-- time shit --
lastTimeCheck = 0
curTimeCheck = 0
curTime = nil

-- extra script shit --
timers = {
	['clock'] = function() restartSong() end, -- when the clock hits 6 it restarts the song
	['redCircleVisible'] = function() -- the red circle thingie on the cams
		setProperty('redCircle.visible', (not getProperty('redCircle.visible'))) 
		runTimer('redCircleVisible', 1 / playbackRate)
	end
}
tweens = {
	['troll'] = function() if not usingLight then os.exit() end end
}

function onCreate() -- basic script shit you don't need to worry abt
	addHaxeLibrary('FlxSound', 'flixel.system')
	addHaxeLibrary('MusicBeatState')
	setPropertyFromClass('openfl.Lib', 'application.window.title', 'Five Nights at Freddy\'s 2')
	setPropertyFromClass('flixel.FlxG', 'mouse.visible', true)
end

function onCreatePost()
	luaDebugMode = true
	setProperty('camGame.visible', false) -- because it's still being called every frame
	setProperty('camHUD.visible', false)

	makeCamera('visuals') -- office camera - was originally supposed to be both the office and cams but it broke so cams are in items now
	makeCamera('items') -- shit like the mask and the cams and the camera monitor
	makeCamera('ui') -- shit like the batteries and the cam buttons and the item buttons and the night and the time

	makeLuaSprite('office', 'gameplay/office/officeLightOff') -- office
	setGraphicSize('office', 1600, screenHeight)
	addLuaSprite('office')
	setLuaCamera('office', 'visuals')

	makeLuaSprite('officeButtonLeft', nil, 90, 325) -- left light button
	loadGraphic('officeButtonLeft', 'gameplay/office/lightButtonLeft', 100, 150)
	addAnimation('officeButtonLeft', 'a', {0,1}, 0, false)
	addLuaSprite('officeButtonLeft')
	setLuaCamera('officeButtonLeft', 'visuals')

	makeLuaSprite('officeButtonRight', nil, 1415, 325) -- right light button
	loadGraphic('officeButtonRight', 'gameplay/office/lightButtonRight', 100, 150)
	addAnimation('officeButtonRight', 'a', {0,1}, 0, false)
	addLuaSprite('officeButtonRight')
	setLuaCamera('officeButtonRight', 'visuals')

	makeLuaSprite('shadowBonnie', 'gameplay/office/shadowBonnie', 250, 0)
	addLuaSprite('shadowBonnie')
	setLuaCamera('shadowBonnie', 'visuals')
	setProperty('shadowBonnie.alpha', 0)

	makeAnimatedLuaSprite('desk', 'gameplay/office/desk/desk', 450, 300) -- desk
	addAnimationByPrefix('desk', 'a', 'desk', 60)
	addLuaSprite('desk')
	setLuaCamera('desk', 'visuals')

	makeLuaSprite('freddyNose', nil, 141, 177) -- the nose
	makeGraphic('freddyNose', 10, 10, 'FFFFFF')
	setLuaCamera('freddyNose', 'visuals')
	
	makeLuaSprite('scroll', nil, 640, 359) -- the scroll thing that makes you go left and right
	setLuaCamera('scroll', 'visuals')

	makeAnimatedLuaSprite('mask', 'gameplay/mask/mask', 0, 0) -- the mask anim
	addAnimationByPrefix('mask', 'a', 'mask', 48, false)
	addAnimationByIndices('mask', 'b', 'mask', '7,6,5,4,3,2,1,0', 48)
	setGraphicSize('mask', screenWidth, screenHeight)
	addLuaSprite('mask')
	setLuaCamera('mask', 'items')
	setProperty('mask.visible', false)

	makeLuaSprite('stillMask', 'gameplay/mask/stillMask', 0, 0) -- the mask itself
	scaleObject('stillMask', 1.2, 1.2)
	screenCenter('stillMask', 'xy')
	addLuaSprite('stillMask')
	setLuaCamera('stillMask', 'items')
	setProperty('stillMask.visible', false)

	makeLuaSprite('maskButton', 'gameplay/ui/maskButton', 20, 650) -- the mask button
	scaleObject('maskButton', 1.2, 1.2)
	addLuaSprite('maskButton', true)
	setLuaCamera('maskButton', 'ui')

	makeLuaSprite('maskHitbox', nil, getProperty('maskButton.x'), getProperty('maskButton.y')) -- mask button's hitbox
	makeGraphic('maskHitbox', getProperty('maskButton.width'), screenHeight - getProperty('maskButton.height'), '000000')
	setLuaCamera('maskHitbox', 'ui')

	makeAnimatedLuaSprite('camera', 'gameplay/camera/camMonitor', 0, 0) -- camera monitor
	addAnimationByPrefix('camera', 'a', 'camMonitor', 48, false)
	addAnimationByIndices('camera', 'b', 'camMonitor', '10,9,8,7,6,5,4,3,2,1,0', 24)
	setGraphicSize('camera', screenWidth, screenHeight)
	addLuaSprite('camera')
	setLuaCamera('camera', 'items')
	setProperty('camera.visible', false)

	makeLuaSprite('curCamSpr', nil) -- the current camera's sprite

	makeAnimatedLuaSprite('cam6Wires', 'gameplay/camera/cam6/cam6Wires', 150, 0) -- camera 6's wires
	addAnimationByPrefix('cam6Wires', 'a', 'wires')

	makeAnimatedLuaSprite('camStatic', 'other/static') -- the static on the cameras
	addAnimationByPrefix('camStatic', 'a', 'static')
	setGraphicSize('camStatic', screenWidth, screenHeight)
	setProperty('camStatic.alpha', 0.5)

	makeLuaSprite('camBorder', 'gameplay/ui/camera/camBorder', 0, 0) -- the border on the cameras
	setGraphicSize('camBorder', screenWidth, screenHeight)

	makeLuaSprite('map', 'gameplay/ui/camera/map', 775, 300) -- the map on the cameras

	for i = 1, #cameraButtons do -- all of the camera buttons
		makeLuaSprite('cam' .. i .. 'ButtonSpr', 'gameplay/ui/camera/camBox', cameraButtons[i][1], cameraButtons[i][2])
		makeLuaSprite('cam' .. i .. 'ButtonTxt', 'gameplay/ui/camera/cams/cam' .. i, getProperty('cam' .. i .. 'ButtonSpr.x') + 5, getProperty('cam' .. i .. 'ButtonSpr.y') + 7)
	end

	makeLuaSprite('curCamTxt', nil, 800, 260) -- the current camera in text

	-- music box sprite shit
	makeLuaSprite('musicBoxButton', 'gameplay/ui/camera/musicBoxButton', 585, 525)
	makeLuaSprite('windMusic', 'gameplay/ui/camera/musicBoxButtonTxt', getProperty('musicBoxButton.x') + 7, getProperty('musicBoxButton.y') + 10)
	makeLuaSprite('musicBoxInstructions', 'gameplay/camera/cam11/clickAndHold', 585, 595)

	makeLuaSprite('musicBoxCircle', nil, 520, 530)
	loadGraphic('musicBoxCircle', 'gameplay/ui/camera/musicBoxWindUp', 53, 54)
	addAnimation('musicBoxCircle', 'a', {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20}, 0, false)

	makeLuaSprite('redCircle', 'gameplay/ui/camera/camCircle', 35, 90) -- the red circle thingie on cams again

	makeLuaSprite('cameraButton', 'gameplay/ui/camButton', 660, 650) -- the camera monitor's button
	scaleObject('cameraButton', 1.2, 1.2)
	addLuaSprite('cameraButton', true)
	setLuaCamera('cameraButton', 'ui')

	makeLuaSprite('cameraHitbox', nil, getProperty('cameraButton.x'), getProperty('cameraButton.y')) -- the camera monitor's button's hitbox
	makeGraphic('cameraHitbox', getProperty('cameraButton.width'), screenHeight - getProperty('cameraButton.height'), '000000')
	setLuaCamera('cameraHitbox', 'ui')

	makeLuaSprite('flashlightTxt', 'gameplay/ui/flashlightTxt', 35, 20) -- flashlight text
	addLuaSprite('flashlightTxt', true)
	setLuaCamera('flashlightTxt', 'ui')

	makeLuaSprite('batteries', nil, getProperty('flashlightTxt.x') - 12, getProperty('flashlightTxt.y') + 15) -- your batteries
	loadGraphic('batteries', 'gameplay/ui/batteries', 106, 50)
	addAnimation('batteries', 'a', {4,3,2,1,0}, 0, false)
	addLuaSprite('batteries', true)
	setLuaCamera('batteries', 'ui')

	makeLuaSprite('nightSpr', 'gameplay/ui/night', 1135, 23) -- night text
	addLuaSprite('nightSpr', true)
	setLuaCamera('nightSpr', 'ui')

	makeLuaText('nightNum', '1', 500, 760, 14) -- what night you're on
	setTextAlignment('nightNum', 'right')
	setTextSize('nightNum', 25)
	setTextFont('nightNum', 'fnafFont.ttf')
	setTextBorder('nightNum', 0.5, 'FFFFFF')
	addLuaText('nightNum')
	setLuaCamera('nightNum', 'ui')

	makeLuaText('timeNum', '12', 500, 710, 45) -- what time you're on
	setTextAlignment('timeNum', 'right')
	setTextSize('timeNum', 25)
	setTextFont('timeNum', 'fnafFont.ttf')
	setTextBorder('timeNum', 0.5, 'FFFFFF')
	addLuaText('timeNum')
	setLuaCamera('timeNum', 'ui')

	makeLuaSprite('uiAm', 'gameplay/ui/uiAm', 1215, 53) -- AM text
	addLuaSprite('uiAm', true)
	setLuaCamera('uiAm', 'ui')

	makeAnimatedLuaSprite('camChangeAnim', 'gameplay/ui/camera/camChange') -- the white static animation thing that plays when you change cameras
	addAnimationByPrefix('camChangeAnim', 'a', 'camChange', 30, false)
	setGraphicSize('camChangeAnim', screenWidth, screenHeight)

	-- all of the sounds
	soundLoad('desk', 'deskSound', true) -- desk sound
	soundPlay('desk', false, 0.4)

	soundLoad('breathing', 'mask/breathing', true)
	soundLoad('putOn', 'mask/putOn')
	soundLoad('takeOff', 'mask/takeOff')

	soundLoad('open', 'camera/open')
	soundLoad('close', 'camera/close')
	soundLoad('camAmbience', 'camera/cameraAmbience', true)
	soundLoad('camChange', 'camera/changeCam')
	soundLoad('windUp', 'camera/windUp')
	soundLoad('musicBoxSong', 'camera/musicBoxSong', true)
	soundPlay('musicBoxSong', false, 0)

	soundLoad('mangle', 'mangle', true)
	soundPlay('mangle', false, 0)
	soundLoad('enemyAmbience', 'enemyAmbience', true)
	soundPlay('enemyAmbience', false, 0)

	soundLoad('lightOn', 'lightOn')
	soundLoad('lightFail', 'lightFail')
	soundLoad('freddyNose', 'freddyNose')

	--timers
	runTimer('clock', 420 / playbackRate)
	runTimer('redCircleVisible', 1 / playbackRate)
end

function onUpdate(elapsed)
	-- look left and right system thingie that was originally from mayo but i rewrote it
	local mousePos = getMouseX('other') / getProperty('visuals.scaleX')
    local camVelocity = 0
    if not cameraActive then
        if mousePos <= 240 then camVelocity = -14
        elseif mousePos <= 350 then camVelocity = -4 
        elseif mousePos >= 748 then camVelocity = 14
        elseif mousePos >= 702 then camVelocity = 4
        end
		camVelocity = camVelocity * (elapsed * 45)
    end

	-- most wacky ass code ever (this is aLOT of math how the fuck did i even rewrite this)
	if (camVelocity > 0 and getProperty('scroll.x') + 1024 / 2 + camVelocity <= 1464) or 
	(camVelocity < 0 and getProperty('scroll.x') >= 640) then setProperty('scroll.x', (getProperty('scroll.x') + camVelocity)) end
	if (getProperty('scroll.x') <= 640) or ((getProperty('scroll.x') + 1024 / 2 + camVelocity) >= 1464) then
		setProperty('scroll.x', (getProperty('scroll.x') <= 640 and 639) or ((getProperty('scroll.x') + 1024 / 2 + camVelocity) >= 1464 and 950))
	end
	runHaxeCode('getVar("visuals").follow(game.getLuaObject("scroll", false));')

	-- mask system
	mouseOverlapMask = luaSpriteExists('maskHitbox') and mouseOverlap('maskHitbox', 'other')
	if not mouseOverlapMask and maskCooldown >= 0 then maskCooldown = ((maskCooldown / playbackRate) - elapsed) end
	if mouseOverlapMask and not cameraActive and maskCooldown <= 0 then 
		maskCooldown = 0.1
		maskActive = not maskActive

		setProperty('mask.visible', true)
		playAnim('mask', maskActive and 'a' or 'b', true)
		if not maskActive then setProperty('stillMask.visible', false) end
		soundPlay(maskActive and 'putOn' or 'takeOff', true)

		runHaxeCode([[
			var mask = game.getLuaObject('mask', false);
			var stillMask = game.getLuaObject('stillMask', false);
			var breathing = game.modchartSounds.get('breathing');

			game.getLuaObject('cameraButton', false).visible = !]] .. tostring(maskActive) .. [[;
			game.getLuaObject('maskButton', false).visible = !]] .. tostring(maskActive) .. [[;
			]] .. tostring(maskActive) .. [[ ? breathing.play() : breathing.stop();

			mask.animation.finishCallback = _ -> {
				mask.visible = false;
				stillMask.visible = ]] .. tostring(maskActive) .. [[;
			};
		]])
	end

	-- cam opening system
	mouseOverlapCamera = luaSpriteExists('cameraHitbox') and mouseOverlap('cameraHitbox', 'other')
	if not mouseOverlapCamera and cameraCooldown >= 0 then cameraCooldown = ((cameraCooldown / playbackRate) - elapsed) end
	if mouseOverlapCamera and not maskActive and cameraCooldown <= 0 then
		cameraCooldown = 0.1
		cameraActive = not cameraActive

		setProperty('camera.visible', true)
		playAnim('camera', cameraActive and 'a' or 'b', true)
		soundPlay(cameraActive and 'open' or 'close', true)

		runHaxeCode([[
			var camera = game.getLuaObject('camera', false);
			
			game.getLuaObject('maskButton', false).visible = !]] .. tostring(cameraActive) .. [[;
			camera.animation.finishCallback = _ -> {
				camera.visible = false;
				if(]] .. tostring(cameraActive) .. [[) game.callOnLuas('onCameraOpen', []);
			};
			if(!]] .. tostring(cameraActive) .. [[) game.callOnLuas("onCameraClose", []);
		]])
	end
	if not getProperty('camera.visible') and cameraActive then runHaxeCode('game.callOnLuas("onCameraUpdate", []);') end

	--cameras moving part 1
	if not getProperty('startMoveCam') then
		runHaxeCode([[
			var tweenValue;
			var wait;
			var loopBack:Bool = true;

			tweenValue = function(a:Bool) {
				FlxTween.num((a ? 0 : -320), (a ? -320 : 0), 5 / game.playbackRate, 
				{ease: FlxEase.linear, onUpdate: function(b) {
					setVar('moveCamPos', b.value);
					game.modchartTweens.set('tweenMoveCam', b);
				}, onComplete: function() {
					wait();
				}});
			}

			wait = function() {
				var g = new FlxTimer().start(3 / game.playbackRate, function(tmr:FlxTimer) {
					tweenValue(!loopBack);
					loopBack = !loopBack;
				});
				game.modchartTimers.set('waitMoveCam', g);
			}

			tweenValue(true);
			setVar('startMoveCam', true);
		]])
	end

	-- light system part 1
	usingLeftVent = flashlightHealth > 1 and (not (maskActive or cameraActive) and (mouseOverlap('officeButtonLeft', 'hud') and mousePressed())) or false
	usingRightVent = flashlightHealth > 1 and (not (maskActive or cameraActive) and (mouseOverlap('officeButtonRight', 'hud', 330, 30) and mousePressed())) or false
	usingMainLight = flashlightHealth > 1 and (not maskActive and (keyboardPressed('CONTROL') and true or (keyboardReleased('CONTROL') and false))) or false
	usingLight = flashlightHealth > 1 and (usingMainLight or (usingLeftVent or usingRightVent)) or false

	if flashlightHealth < 1 then
		if keyboardJustPressed('CONTROL') or
		((not (maskActive or cameraActive) and (mouseOverlap('officeButtonLeft', 'hud')) or
		(not (maskActive or cameraActive) and (mouseOverlap('officeButtonRight', 'hud', 330, 30)))) and mouseClicked()) then
			soundPlay('lightFail', true)
		end
	elseif usingLight then soundPlay('lightOn', false, 0.75) end
	if not usingLight and luaSoundExists('lightOn') then soundStop('lightOn') end

	if not (maskActive or cameraActive) then
		if mouseOverlap('freddyNose', 'hud', 0, shadersEnabled and 35 or 0) then if mouseClicked() then soundPlay('freddyNose') end end
	end

	setProperty('officeButtonLeft.animation.curAnim.curFrame', usingLeftVent and 1 or 0)
	setProperty('officeButtonRight.animation.curAnim.curFrame', usingRightVent and 1 or 0)

	if usingLeftVent then loadGraphic('office', 'gameplay/office/officeLeftVent')
	elseif usingRightVent then loadGraphic('office', 'gameplay/office/officeRightVent')
	elseif usingMainLight and not cameraActive then loadGraphic('office', 'gameplay/office/officeLightOn') end

	if not usingLight then loadGraphic('office', 'gameplay/office/officeLightOff') end

	if usingLight and flashlightHealth >= 0 then flashlightHealth = (flashlightHealth - (0.01 * playbackRate)) end

	if flashlightHealth < 75 and flashlightHealth > 51 then setProperty('batteries.animation.curAnim.curFrame', 1)
	elseif flashlightHealth < 50 and flashlightHealth > 26 then setProperty('batteries.animation.curAnim.curFrame', 2)
	elseif flashlightHealth < 25 and flashlightHealth > 2 then setProperty('batteries.animation.curAnim.curFrame', 3)
	elseif flashlightHealth < 1 then setProperty('batteries.animation.curAnim.curFrame', 4) end

	-- time system
	curTime = round(curTimerLength('clock'))
	if ((lastTimeCheck + 70) <= curTime) and changeTime then
		lastTimeCheck = curTime
		curTimeCheck = curTimeCheck + 1
		runHaxeCode('game.callOnLuas("onTimeChange", [' .. curTimeCheck .. ']);')
		changeTime = false
	end
	changeTime = true
end

-- camera system
function onCameraUpdate()
	for i = 1, #cameraButtons do
		if mouseOverlap('cam' .. i .. 'ButtonSpr', 'other') and mouseClicked() then 
			lastCam = curCam
			curCam = i
			runHaxeCode('game.callOnLuas("onCameraChange", [' .. curCam .. ']);')
		end
	end

	setProperty('curCamSpr.x', (curCam == 7 or curCam == 8 or curCam == 9 or curCam == 10 or curCam == 11 or curCam == 12) and getProperty('moveCamPos') or 0)
	loadGraphic('curCamSpr', cameraDir .. (usingMainLight and cameras.on[curCam]() or cameras.default[curCam]()))
	setGraphicSize('curCamSpr', (curCam == 7 or curCam == 8 or curCam == 9 or curCam == 10 or curCam == 11 or curCam == 12) and 1600 or screenWidth, screenHeight)

	-- music box winding system
	if canWind then
		if mouseOverlap('musicBoxButton', 'other') and mousePressed() then
			loadGraphic('musicBoxButton', 'gameplay/ui/camera/musicBoxButtonSelected')
			soundPlay('windUp')
		else 
			loadGraphic('musicBoxButton', 'gameplay/ui/camera/musicBoxButton')
			soundStop('windUp') 
		end
	end
end

-- shit that gets added whenever you open the cameras
function onCameraOpen() 
	setProperty('office.visible', not cameraActive)
	setProperty('desk.visible', not cameraActive) 
	setProperty('officeButtonLeft.visible', not cameraActive)
	setProperty('officeButtonRight.visible', not cameraActive)
	setSoundVolume('desk', 0.25)

	addLuaSprite('curCamSpr')
	setLuaCamera('curCamSpr', 'items')
	
	addLuaSprite('cam6Wires')
	setLuaCamera('cam6Wires', 'items')

	addLuaSprite('camStatic')
	setLuaCamera('camStatic', 'ui')

	addLuaSprite('camBorder')
	setLuaCamera('camBorder', 'ui')

	addLuaSprite('camChangeAnim')
	setLuaCamera('camChangeAnim', 'ui')

	addLuaSprite('redCircle', true)
	setLuaCamera('redCircle', 'ui')

	addLuaSprite('map', true)
	setLuaCamera('map', 'ui')

	addLuaSprite('musicBoxButton', true)
	setLuaCamera('musicBoxButton', 'ui')

	addLuaSprite('windMusic', true)
	setLuaCamera('windMusic', 'ui')

	addLuaSprite('musicBoxInstructions', true)
	setLuaCamera('musicBoxInstructions', 'ui')

	addLuaSprite('musicBoxCircle', true)
	setLuaCamera('musicBoxCircle', 'ui')
	for i = 1, #cameraButtons do
		addLuaSprite('cam' .. i .. 'ButtonSpr', true)
		addLuaSprite('cam' .. i .. 'ButtonTxt', true)

		setLuaCamera('cam' .. i .. 'ButtonSpr', 'ui')
		setLuaCamera('cam' .. i .. 'ButtonTxt', 'ui')
	end

	addLuaSprite('curCamTxt', true)
	setLuaCamera('curCamTxt', 'ui')

	setProperty('curCamSpr.x', (curCam == 7 or curCam == 8 or curCam == 9 or curCam == 10 or curCam == 11 or curCam == 12) and getProperty('moveCamPos') or 0)
	soundPlay('camAmbience', false, 0.7)
	runHaxeCode('game.callOnLuas("onCameraChange", [' .. curCam .. ']);')
end

-- when you close the cameras
function onCameraClose()
	setProperty('office.visible', not cameraActive)
	setProperty('desk.visible', not cameraActive) 
	setProperty('officeButtonLeft.visible', not cameraActive)
	setProperty('officeButtonRight.visible', not cameraActive)
	setSoundVolume('desk', 0.5)

	if getRandomInt(1, 1000000) == 1 then
		setProperty('shadowBonnie.alpha', 1)
		doTweenAlpha('troll', 'shadowBonnie', 0, 4, 'linear')
	end

	removeLuaSprite('curCamSpr', false)
	removeLuaSprite('cam6Wires', false)
	removeLuaSprite('camStatic', false)
	removeLuaSprite('camBorder', false)
	removeLuaSprite('redCircle', false)
	removeLuaSprite('map', false)

	removeLuaSprite('musicBoxButton', false)
	removeLuaSprite('windMusic', false)
	removeLuaSprite('musicBoxInstructions', false)
	removeLuaSprite('musicBoxCircle', false)
	setSoundVolume('musicBoxSong', 0)
	if curCam == 12 then setSoundVolume('mangle', 0) end
	canWind = false
	for i = 1, #cameraButtons do
		removeLuaSprite('cam' .. i .. 'ButtonSpr', false)
		removeLuaSprite('cam' .. i .. 'ButtonTxt', false)
	end
	removeLuaSprite('camChangeAnim', false)
	removeLuaSprite('curCamTxt', false)
	soundStop('camAmbience')
end

-- when you change cameras
function onCameraChange(cam)
	soundPlay('camChange', true)

	cameraDir = ('gameplay/camera/cam' .. curCam .. '/cam' .. curCam)
	setProperty('cam6Wires.visible', cam == 6)

	loadGraphic('cam' .. lastCam .. 'ButtonSpr', 'gameplay/ui/camera/camBox')
	loadGraphic('cam' .. cam .. 'ButtonSpr', 'gameplay/ui/camera/camBoxSelect')
	loadGraphic('curCamTxt', 'gameplay/ui/camera/cams/cam' .. cam .. 'Txt')

	setProperty('musicBoxButton.visible', cam == 11)
	setProperty('windMusic.visible', cam == 11)
	setProperty('musicBoxInstructions.visible', cam == 11)
	setProperty('musicBoxCircle.visible', cam == 11)

	setSoundVolume('musicBoxSong', ((cam == 11 and 0.5) or (cam == 9 and 0.05) or ((cam == 10 or cam == 12) and 0.1) or 0))
	setSoundVolume('mangle', (cam == 12) and 0.5 or 0)

	setProperty('camChangeAnim.visible', true)
	playAnim('camChangeAnim', 'a', true)
	runHaxeCode([[
		var camChange = game.getLuaObject('camChangeAnim', false);

		camChange.animation.finishCallback = _ -> {camChange.visible = false;}
	]])

	canWind = (cam == 11)
end

-- had to manually pause and resume all of the sounds myself cuz it doesn't do that fsr :sob:
function onPause()
	soundPause('desk')
	soundPause(not maskActive and 'takeOff' or 'putOn')
	soundPause(not cameraActive and 'close' or 'open')
	if usingLight then soundStop('lightOn') end
	soundPause('musicBoxSong')
	if maskActive then soundPause('breathing')
	elseif cameraActive then
		soundPause('camAmbience') 
		soundPause('camChange')
	end
	soundPause('mangle')
	soundPause('freddyNose')
	soundPause('enemyAmbience')
end

function onResume()
	soundResume('desk')
	soundResume(not maskActive and 'takeOff' or 'putOn')
	soundResume(not cameraActive and 'close' or 'open')
	soundResume('musicBoxSong') 
	if maskActive then soundResume('breathing')
	elseif cameraActive then 
		soundResume('camAmbience') 
		soundResume('camChange')
	end
	soundResume('mangle')
	soundResume('freddyNose')
	soundResume('enemyAmbience')
end

-- animatronic jumpscare function (unused because there's no animatronic system but it works well)
function doJumpscare(animatronic)
	makeAnimatedLuaSprite('animatronic', 'gameplay/jumpscares/' .. animatronic .. 'Jump')
	addAnimationByPrefix('animatronic', 'a', animatronic .. 'Jump', 24, false)
	setGraphicSize('animatronic', screenWidth, screenHeight)

	soundLoad('jumpscare', 'jumpscare')
	
	runHaxeCode([[
		var animatronic = game.getLuaObject('animatronic', false);
		var jumpscareSound = game.modchartSounds.get('jumpscare');

		game.add(animatronic);
		animatronic.cameras = [getVar('visuals')];
		jumpscareSound.play();
		animatronic.animation.play('a', true);
		animatronic.animation.finishCallback = _ -> {
			jumpscareSound.stop();
			PlayState.deathCounter++;
			MusicBeatState.resetState();
		};
	]])
end

-- extra script shit
function onDestroy() setPropertyFromClass("openfl.Lib", "application.window.title", "Friday Night Funkin': Psych Engine") end
function onTimeChange(time) setTextString('timeNum', time) end

--[[ 
backend functions
use these as you wish :smiling_imp:
]]
function round(num, decimal_places) return math.floor(num * (10 ^ (decimal_places or 0)) + 0.5) / (10 ^ (decimal_places or 0)) end
function onTimerCompleted(t) if timers[t] then timers[t]() end end
function onTweenCompleted(t) if tweens[t] then tweens[t]() end end
function curTimerLength(timer) 
	return runHaxeCode([[
		var tmr = game.modchartTimers.get(']] .. timer .. [[');
		return game.modchartTimers.exists(']] .. timer .. [[') ? ((tmr.progress * tmr.time) * game.playbackRate) : game.addTextToDebug('curTimerLength: Timer tag "]] .. timer .. [[" was not found.', 0xFFFF0000);
  	]]) 
end
function makeCamera(tag, x, y, transparent, width, height)
	transparent = transparent or false
	x = x or 0
	y = y or 0
	width = width or screenWidth
	height = height or screenHeight
	runHaxeCode([[
		var ]] .. tag .. [[ = new FlxCamera(]] .. x .. [[, ]] .. y .. [[, ]] .. width .. [[, ]] .. height .. [[, 1);
		var transparent = ]] .. tostring(transparent) .. [[;
		]] .. tag .. [[.follow(null);
		]] .. tag .. [[.bgColor = (transparent ? 0x00 : 0xFF) + 000000;
		FlxG.cameras.add(]] .. tag .. [[);
		setVar(']] .. tag .. [[', ]] .. tag .. [[);
	]])
end
function setLuaCamera(obj, cam)
	runHaxeCode([[
		var a = game.getLuaObject(']] .. obj .. [[');
		var b = getVar(']] .. cam .. [[');

		if (a != null || b != null) a.cameras = [b];

		trace('camera: ' + getVar(']] .. cam .. [['));
		trace('object: ' + a);
	]])
end
function mouseOverlap(obj, mouseCamera, offsetX, offsetY)
	offsetX = offsetX or 0
	offsetY = offsetY or 0
	local overlapX = (getMouseX(mouseCamera) + offsetX) >= getProperty(obj .. '.x') and (getMouseX(mouseCamera) + offsetX) <= getProperty(obj .. '.x') + getProperty(obj .. '.width')
	local overlapY = (getMouseY(mouseCamera) + offsetY) >= getProperty(obj .. '.y') and (getMouseY(mouseCamera) + offsetY) <= getProperty(obj .. '.y') + getProperty(obj .. '.height')
	return overlapX and overlapY
end
function soundLoad(tag, path, loop)
	loop = loop or false
	runHaxeCode([[
		if (Paths.fileExists('sounds/]] .. path .. [[.ogg')) {
			var a = new FlxSound().loadEmbedded(Paths.sound(']] .. path .. [['), ]] .. tostring(loop) .. [[);
			FlxG.sound.list.add(a);
			a.pitch = game.playbackRate;
			game.modchartSounds.set(']] .. tag .. [[', a);
		} else game.addTextToDebug('soundLoad: Sound file "]] .. path .. [[" was not found.', 0xFFFF0000);
	]])
end
function soundPlay(tag, forceRestart, volume)
	forceRestart = forceRestart or false
	volume = volume or 1
	runHaxeCode([[
		var a = game.modchartSounds.get(']] .. tag .. [[');
		if (game.modchartSounds.exists(']] .. tag .. [[')) {
			a.volume = ]] .. volume .. [[;
			a.play(]] .. tostring(forceRestart) .. [[);
		}
		else game.addTextToDebug('soundPlay: Sound tag "]] .. tag .. [[" was not found.', 0xFFFF0000);
	]])
end
function soundStop(tag)
	runHaxeCode([[
		var a = game.modchartSounds.get(']] .. tag .. [[');
		if (game.modchartSounds.exists(']] .. tag .. [[')) a.stop();
		else game.addTextToDebug('soundStop: Sound tag "]] .. tag .. [[" was not found.', 0xFFFF0000);
	]])
end
function soundPause(tag)
	runHaxeCode([[
		var a = game.modchartSounds.get(']] .. tag .. [[');
		if (game.modchartSounds.exists(']] .. tag .. [[')) a.pause();
		else game.addTextToDebug('soundPause: Sound tag "]] .. tag .. [[" was not found.', 0xFFFF0000);
	]])
end
function soundResume(tag)
	runHaxeCode([[
		var a = game.modchartSounds.get(']] .. tag .. [[');
		if (game.modchartSounds.exists(']] .. tag .. [[')) a.resume();
		else game.addTextToDebug('soundResume: Sound tag "]] .. tag .. [[" was not found.', 0xFFFF0000);
	]])
end