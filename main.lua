math.randomseed(os.time())

function printInfo()
    love.graphics.setColor(100, 100, 100, 10)
    love.graphics.print('On screen enemies: ' .. EnemiesController:countEnemies(), 2, 200)
    love.graphics.print('Rounds shot: ' .. roundsShot, 2, 215)
    love.graphics.print('Prusix killed: ' .. enemiesKilled, 2, 230)
    love.graphics.print('Prusix escaped: ' .. enemiesBehindTheWall, 2, 245)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 2, 260)
    love.graphics.print('Hit rate: ' .. tostring(enemiesKilled / roundsShot), 2, 275)
end

function love.conf(t)
    t.console = true
    t.window.width = 1024
    t.window.height = 768
end


move_offset = 1
default_cooldown_time = 50

prusixes = {}
table.insert(prusixes, love.graphics.newImage('prusix1.png'))
table.insert(prusixes, love.graphics.newImage('prusix2.png'))
table.insert(prusixes, love.graphics.newImage('prusix3.png'))

EnemiesController = {}
EnemiesController.enList = {}
-- EnemiesController.image = 
maxEnemies = 15

roundsShot = 0
enemiesKilled = 0
enemiesBehindTheWall = 0

bulletImage = love.graphics.newImage('waterm.png')


function shouldSpawn()
    if math.random(1, 300) == 74 then
        return true
    end
end

function EnemiesController:sprawnEnemy()
    en = {}
    en.x = math.random(20, 750)
    en.y = 0
    en.speed = math.random(1, 3) * 0.2
    en.bullets = {}
    en.height = 50
    en.width = 50
    en.skin = prusixes[math.random(#prusixes)]
    table.insert(self.enList, en)
end

function EnemiesController:countEnemies()
    return table.getn(self.enList)
end

function love.load()
    player = {}
    player.x = 350
    player.y = 525
    player.cooldown = default_cooldown_time
    player.bullets = {}
    player.image = love.graphics.newImage('prusix_pencil.png')
    player.fire = function()
        if player.cooldown > 0 then
            return
        end
        roundsShot = roundsShot + 1
        player.cooldown = default_cooldown_time
        bullet = {}
        bullet.x = player.x
        bullet.y = player.y - 20
        table.insert(player.bullets, bullet)
    end
    player.move_left = function()
        if player.x < 20 then
            return
        end
        player.x = player.x - move_offset
    end
    player.move_right = function()
        if player.x > 750 then
            return
        end
        player.x = player.x + move_offset
    end
end


function countHitsSimple(enemies, bullets)
    for enIndex, en in ipairs(enemies) do
        for bulIndex, bul in ipairs(bullets) do
            if bul.y <= en.y + en.height and bul.x > en.x and bul.x <= en.x + en.width then
                table.remove(enemies, enIndex)
                table.remove(bullets, bulIndex)
                enemiesKilled = enemiesKilled + 1
            end
        end
    end
end

function love.update(dt)
    player.cooldown = player.cooldown - 1

    countHitsSimple(EnemiesController.enList, player.bullets)

    -- moving enemy towards player and removing them
    -- if below the line if sight
    for enIndex, enemy in ipairs(EnemiesController.enList) do
        enemy.y = enemy.y + enemy.speed
        if enemy.y >= 760 then
            table.remove(EnemiesController.enList, enIndex)
            enemiesBehindTheWall = enemiesBehindTheWall + 1
        end
    end

    -- shooting bullets towards enemies and
    -- removing them if left the screen
    for bulIndex, bullet in ipairs(player.bullets) do
        bullet.y = bullet.y - 1
        if bullet.y < -10 then
            table.remove(player.bullets, bulIndex)
        end
    end

    -- spawning enemies
    if shouldSpawn() and EnemiesController:countEnemies() < maxEnemies then
        EnemiesController:sprawnEnemy()
    end

    if love.keyboard.isDown('right') then
        player.move_right()
    elseif love.keyboard.isDown('left') then
        player.move_left()
    end

    if love.keyboard.isDown('space') then
        player.fire()
    end
end

function love.draw()
    printInfo()

    -- love.graphics.setColor(255, 255, 255)
    -- love.graphics.rectangle('fill', player.x, player.y, 30, 30)
    love.graphics.draw(player.image, player.x, player.y, 0, 0.5, 0.5)

    -- love.graphics.setColor(0, 100, 0)
    for _, bullet in pairs(player.bullets) do
        -- love.graphics.rectangle('fill', bullet.x, bullet.y, 5, 5)
        love.graphics.draw(bulletImage, bullet.x, bullet.y, 0, .5, .5)
    end

    love.graphics.setColor(255, 255, 255)
    for _, enemy in pairs(EnemiesController.enList) do
        love.graphics.draw(
            -- EnemiesController.image,
            enemy.skin,
            enemy.x, enemy.y, 0, 1, 1
        )
    end
end
