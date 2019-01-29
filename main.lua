math.randomseed(os.time())

function printInfo()
    love.graphics.setColor(100, 100, 100, 10)
    love.graphics.print('Num of enemies: ' .. EnemiesController:countEnemies(), 2, 200)
    love.graphics.print('Rounds shot: ' .. roundsShot, 2, 215)
    love.graphics.print('Prusix killed: ' .. enemiesKilled, 2, 230)
end

function love.conf(t)
    t.console = true
    t.window.width = 1024
    t.window.height = 768
end


move_offset = 1
default_cooldown_time = 30

EnemiesController = {}
EnemiesController.enList = {}
EnemiesController.image = love.graphics.newImage('ghost.png')
maxEnemies = 10

roundsShot = 0
enemiesKilled = 0


function shouldSpawn()
    if math.random(1, 300) == 74 then
        return true
    end
end

function EnemiesController:sprawnEnemy()
    en = {}
    en.x = math.random(20, 900)
    en.y = 0
    en.speed = math.random(1, 3) * 0.2
    en.bullets = {}
    -- en.scalex = 1 + math.random(1, 10) * 0.1
    en.scalex = 1
    en.scaley = en.scalex
    en.height = 50
    en.width = 50
    en.checkIfDead = function(bullets)
        for bulIndex, b in ipairs(bullets) do
            enemy_right = en.x + 50
            enemy_bottom = en.y + 50

            if b.x >= en.x and b.x <= enemy_right then
                if b.y <= enemy_bottom + 5 then
                    return true, bulIndex
                end
            end
        end
    end
    table.insert(self.enList, en)
end

function EnemiesController:countEnemies()
    return table.getn(self.enList)
end

function love.load()
    player = {}
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
    player.x = 350
    player.cooldown = default_cooldown_time
    player.y = 550
    player.bullets = {}
    player.fire = function()
        if player.cooldown > 0 then
            return
        end
        roundsShot = roundsShot + 1
        player.cooldown = default_cooldown_time
        bullet = {}
        bullet.x = player.x + 13
        bullet.y = player.y
        table.insert(player.bullets, bullet)
        -- end
    end
end


function countHitsSimple(enemies, bullets)
    for enIndex, en in ipairs(enemies) do
        for bulIndex, bul in ipairs(bullets) do
            if bul.y <= en.y + en.height and bul.x > en.x and bul.x <= en.x + en.width then
                table.remove(enemies, enIndex)
                table.remove(bullets, bulIndex)
            end
        end
    end
end

function love.update(dt)
    player.cooldown = player.cooldown - 1

    countHitsSimple(EnemiesController.enList, player.bullets)

    for enIndex, enemy in ipairs(EnemiesController.enList) do
        enemy.y = enemy.y + enemy.speed
        if enemy.y >= 760 then
            table.remove(EnemiesController.enList, enIndex)
        end
    end

    for bulIndex, bullet in ipairs(player.bullets) do
        bullet.y = bullet.y - 1
        if bullet.y < -10 then
            table.remove(player.bullets, bulIndex)
        end
    end

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

    love.graphics.setColor(0, 100, 0)
    love.graphics.rectangle('fill', player.x, player.y, 30, 30)

    love.graphics.setColor(0, 100, 0)
    for _, bullet in pairs(player.bullets) do
        love.graphics.rectangle('fill', bullet.x, bullet.y, 5, 5)
    end

    love.graphics.setColor(255, 255, 255)
    for _, enemy in pairs(EnemiesController.enList) do
        love.graphics.draw(
            EnemiesController.image,
            enemy.x, enemy.y,
            0,
            enemy.scalex, enemy.scaley
        )
    end
end
