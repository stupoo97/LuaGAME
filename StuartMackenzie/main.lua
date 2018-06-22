debug = true

-- Timers
-- We declare these here so we don't have to edit them multiple places
canShoot = true
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax
createEnemyTimerMax = 0.4
createEnemyTimer = createEnemyTimerMax

-- Player Object
player = { x = 200, y = 710, speed = 150, img = nil }
isAlive = true
score = 0

bulletImg = nil 
enemyImg = nil

bullets = {} -- array of current bullets being drawn and updated
enemies = {} -- array of current enemies on screen

-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end
function love.load()
	require('lib');

	love.graphics.setBackgroundColor(0, 255, 255)
	
	player.img = love.graphics.newImage('plane.png')
	enemyImg = love.graphics.newImage('enemy.png')
	bulletImg = love.graphics.newImage('bullet.png')
	
	gameState = 1;
	
	assets = {};
	assets.title = love.graphics.newImage("title.png");
	assets.start = love.graphics.newImage("start.png");
	assets.quit = love.graphics.newImage("quit.png");
	
	ents = {};
	
	
	ents.menu = {};
	
	local w, h = love.graphics.getDimensions();
	
	local title = lib.entity();
	title.image = assets.title;
	title.w, title.h = assets.title:getDimensions();
	title.x = w / 2 - title.w / 2;
	title.y = h * 0.25 - title.h / 2;
	ents.menu.title = title;
	
	local start = lib.entity();
	start.image = assets.start;
	start.w, start.h = assets.start:getDimensions();
	start.x = w / 2 - start.w / 2;
	start.y = h * 0.50 - start.h / 2;
	ents.menu.start = start;
	
	local quit = lib.entity();
	quit.image = assets.quit;
	quit.w, quit.h = assets.quit:getDimensions();
	quit.x = w / 2 - quit.w / 2;
	quit.y = h * 0.75 - quit.h / 2;
	--quit.y = h * 0.66 + quit.h / 2;
	ents.menu.quit = quit;
	
	ents.game = {};
	
end

function love.draw(dt)
	if gameState == 1 then
		-- menu
		-- menu doesn't do anything in update
		for k, v in pairs(ents.menu) do
			love.graphics.draw(v.image, v.x, v.y);
		end		
	elseif gameState == 2 then

		for k, v in pairs(ents.game) do			
			love.graphics.draw(v.image, v.x, v.y, v.r);
		end
		
		for i, bullet in ipairs(bullets) do
		love.graphics.draw(bullet.img, bullet.x, bullet.y)
		end

		for i, enemy in ipairs(enemies) do
		love.graphics.draw(enemy.img, enemy.x, enemy.y)
		end
		
		love.graphics.print("SCORE: " .. tostring(score), 400, 10)

		if isAlive then
		love.graphics.draw(player.img, player.x, player.y)

		if debug then
		fps = tostring(love.timer.getFPS())
		
		love.graphics.print("Current FPS: "..fps, 9, 10)
		end
	
		else
		love.graphics.setColor(0,0,0)
		
		love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
		love.graphics.setColor(255, 255, 215)
		end
	
	
	elseif gameState == 3 then
	
		love.graphics.setColor(255, 255, 255)
	love.graphics.print("SCORE: " .. tostring(score), 400, 10)
	
	else
		love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
	end
	
	
end

function love.update(dt)
	if gameState == 1 then
		-- menu
		-- menu doesn't do anything in update
	elseif gameState == 2 then
		-- in-game state
		-- move characters etc here
		canShootTimer = canShootTimer - (1 * dt)
	if canShootTimer < 0 then
		canShoot = true
	end
	
	
	createEnemyTimer = createEnemyTimer - (1 * dt)
	if createEnemyTimer < 0 then
		createEnemyTimer = createEnemyTimerMax

		-- Create an enemy
		randomNumber = math.random(10, love.graphics.getWidth() - 10)
		newEnemy = { x = randomNumber, y = -10, img = enemyImg }
		table.insert(enemies, newEnemy)
	end

	for i, bullet in ipairs(bullets) do
		bullet.y = bullet.y - (250 * dt)

		if bullet.y < 0 then -- remove bullets when they pass off the screen
			table.remove(bullets, i)
		end
	end
	
	for i, enemy in ipairs(enemies) do
		enemy.y = enemy.y + (200 * dt)

		if enemy.y > 850 then -- remove enemies when they pass off the screen
			table.remove(enemies, i)
		end
	end
	
	for i, enemy in ipairs(enemies) do
		for j, bullet in ipairs(bullets) do
			if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
				table.remove(bullets, j)
				table.remove(enemies, i)
				score = score + 1
			end
		end

		if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight()) 
		and isAlive then
			table.remove(enemies, i)
			isAlive = false
			
			--if isAlive == false then
				--gameState == 3
			--end
		end
		
	end
	
	if love.keyboard.isDown('left','a') then
		if player.x > 0 then -- binds us to the map
			player.x = player.x - (player.speed*dt)
		end
	elseif love.keyboard.isDown('right','d') then
		if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
			player.x = player.x + (player.speed*dt)
		end
	end

	if love.keyboard.isDown('space', 'rctrl', 'lctrl') and canShoot then -- checks if player is still alive
		-- Create some bullets
		newBullet = { x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg }
		table.insert(bullets, newBullet)
		canShoot = false
		canShootTimer = canShootTimerMax
		
	end
	
	if not isAlive and love.keyboard.isDown('r') then
		-- remove all our bullets and enemies from screen
		bullets = {}
		enemies = {}
		

		-- reset timers
		canShootTimer = canShootTimerMax
		createEnemyTimer = createEnemyTimerMax

		-- move player back to default position
		player.x = 50
		player.y = 710

		-- reset our game state
		score = 0
		isAlive = true
	end
	
	elseif gameState == 3 then
	
	end
end

function love.keypressed(key)

	if gameState == 1 then
		-- menu
		-- menu doesn't do anything in update
	elseif gameState == 2 then
		-- in-game state
		-- move characters etc here
	elseif gameState == 3 then
	
	gameState = 1;
	end
	if key == "escape" then
		love.event.quit();
	end
end	

function love.mousepressed(x,y,button)
	if gameState == 1 then
		-- menu
		-- menu doesn't do anything in update
		local click = lib.entity();
		click.x = x;
		click.y = y;
		click.w = 1;
		click.h = 1;
		
		if lib.bounding(click, ents.menu.quit) then
			love.event.quit();
		end
		
		if lib.bounding(click, ents.menu.start) then
			gameState = 2;
		end
	elseif gameState == 2 then
		-- in-game state
		-- move characters etc here
	elseif gameState == 3 then
	end	
end