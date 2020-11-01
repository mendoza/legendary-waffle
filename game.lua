-- title:  Cuadrito
-- author: David
-- desc:   Prueba
-- script: lua
function init()
    p = {
        image = 256,
        x = 96,
        y = 24,
        vx = 0,
        vy = 0,
        flip = 0,
        moveY = function(self)
            self.y = self.y + self.vy;
        end,
        moveX = function(self)
            self.x = self.x + self.vx;
        end
    }
    solids = {
        [0] = false,
        [1] = true,
        [2] = true,
    }
end

function solid(x, y)
    return solids[mget((x) // 8, (y) // 8)]
end

init()
function TIC()
    input()
    p:moveX()
    p:moveY()
    cls(12)
    map(0, 0, 30, 17)
    spr(p.image, p.x, p.y, 15, 1, p.flip)
    p.image = 256
end

function input()
    if btn(2) then
        p.vx = -1
        p.flip = 1

    elseif btn(3) then
        p.vx = 1
        p.flip = 0
    else
        p.vx = 0
    end

    if btn(0) then
        p.image = 257
    end

    if solid(p.x + p.vx, p.y + p.vy) or solid(p.x + 7 + p.vx, p.y + p.vy) or solid(p.x + p.vx, p.y + 7 + p.vy) or
        solid(p.x + 7 + p.vx, p.y + 7 + p.vy) then
        p.vx = 0
    end

    if solid(p.x, p.y + 8 + p.vy) or solid(p.x + 7, p.y + 8 + p.vy) then
        p.vy = 0
    else
        p.vy = p.vy + 0.2
    end

    if p.vy == 0 and btnp(4) then
        p.vy = -2.5
    end

    if p.vy < 0 and (solid(p.x + p.vx, p.y + p.vy) or solid(p.x + 7 + p.vx, p.y + p.vy)) then
        p.vy = 0
    end
end
