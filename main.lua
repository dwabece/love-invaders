math.randomseed(os.time())

move_offset = 1
default_cooldown_time = 20

EnemiesController = {}
EnemiesController.enList = {}
EnemiesController.image = love.graphics.newImage('ghost.png')

roundsShot = 0
enemiesKilled = 0

-- function getColor()
--     c_red = math.random(1, 25) * 100
--     c_gr = math.random(1, 25) * 100
--     c_bl = math.random(1, 25) * 100
--     return c_red, c_gr, c_bl
-- end

function shouldSpawn()
    if math.random(1, 300) == 74 then
        return true
    end
end

function EnemiesController:sprawnEnemy()
    en = {}
    en.x = math.random(20, 650)
    en.y = 0
    en.speed = math.random(1, 3) * 0.2
    en.bullets = {}
    -- en.scalex = 1 + math.random(1, 10) * 0.1
    en.scalex = 1
    en.scaley = en.scalex
    en.checkIfDead = function(bullets)
        for bulIndex, b in ipairs(bullets) do
            enYTop = en.y + 50
            enXTop = en.x + 50
            if enYTop >= b.y then
                if b.x >= en.x and b.x <= enXTop then
                    enemiesKilled = enemiesKilled + 1
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

function love.update(dt)
    player.cooldown = player.cooldown - 1

    if love.keyboard.isDown('right') then
        player.move_right()
    elseif love.keyboard.isDown('left') then
        player.move_left()
    end

    if love.keyboard.isDown('space') then
        player.fire()
    end

    for i, e in ipairs(EnemiesController.enList) do
        e.y = (e.y + e.speed)
        dead, inde = e.checkIfDead(player.bullets)
        if dead then
            table.remove(EnemiesController.enList, i)
            table.remove(player.bullets, inde)
        end
    end

    for index, bullet in ipairs(player.bullets) do
        if bullet.y < -10 then
            table.remove(player.bullets, index)
        end
        bullet.y = bullet.y - 1
    end

    if shouldSpawn() then
        EnemiesController:sprawnEnemy()
    end

    checkBulletCollision()
end


function checkBulletCollision()
    -- widths = {}
    -- -- for _, pos in pairs(EnemiesController.enList)
    -- for _, b in pairs(player.bullets) do
    --     for i, e in ipairs(EnemiesController.enList) do
    --         if b.y == e.y then
    --             table.remove(EnemiesController.enList, i)
    --         end
    --     end
    -- end
end

function love.draw()
    love.graphics.setColor(100, 100, 100, 10)
    love.graphics.print('Num of enemies: ' .. EnemiesController:countEnemies(), 2, 200)
    love.graphics.print('Rounds shot: ' .. roundsShot, 2, 215)
    love.graphics.print('Prusix killed: ' .. enemiesKilled, 2, 230)

    love.graphics.setColor(0, 100, 0)
    love.graphics.rectangle('fill', player.x, player.y, 30, 30)

    love.graphics.setColor(0, 100, 0)
    for _, bullet in pairs(player.bullets) do
        love.graphics.rectangle('fill', bullet.x, bullet.y, 5, 5)
    love.graphics.setColor(1, 1, 1)
        love.graphics.print(bullet.y, bullet.x + 5, bullet.y - 10)
    end

    love.graphics.setColor(255, 255, 255)
    for _, enemy in pairs(EnemiesController.enList) do
        love.graphics.draw(
            EnemiesController.image,
            enemy.x, enemy.y,
            0,
            enemy.scalex, enemy.scaley
        )
        love.graphics.rectangle('line', enemy.x, enemy.y, 50, 50)
    end
end
