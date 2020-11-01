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

-- <TILES>
-- 001:6666666666666666363636363333333333333333333333333333333333333333
-- 002:3333333333333333333333333333333333333333333333333333333333333333
-- </TILES>

-- <SPRITES>
-- 000:f2666fffff6666faff4040f1ff4444f146666664ff6666f1ff3333ffff2ff2ff
-- 001:ff604ffff66444faf66044f1f66444f142666664ff6666f1ff3333ffff2ff2ff
-- 002:4444444444444444444444444444444444444444444444444444444444444444
-- </SPRITES>

-- <MAP>
-- 006:100000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 007:200000000000000000000000000000000000000000000000000000001020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 008:200000000000000000000000000000000000000000000000000000102020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 009:200000000000000000000000000000000000000000000000000010202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 010:200000000000000000000000000000000000000000000000001020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 011:201010101010101010101010101010101010101010101010102020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </MAP>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100404000000000
-- </SFX>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

