-- title:  Legendary Waffle 🧇
-- author: CodeBaker & Leonard1on
-- desc:   Game Off 2020 Entry
-- script: lua
function isSolid(x, y)
    return solidTiles[mget((x + game.map.x) // 8, (y) // 8)]
end

function renderEnemies()
    for k, v in ipairs(enemies) do
        v:update()
        for pk, pv in ipairs(projectiles) do
            if pv.x // 8 == v.x // 8 and pv.y // 8 == v.y // 8 then
                if not pv.hittedEnemy then
                    v.health = v.health - 1
                end
                pv.hittedEnemy = true
            end
        end
        if v.health == 0 then
            table.remove(enemies, k)
        else
            v:render()
        end
    end
end

function renderProjectiles()
    for k, v in ipairs(projectiles) do
        v:update()
        if v.shouldDelete then
            table.remove(projectiles, k)
        else
            v:render()
        end
    end
end

function writeSpeech(text)
    local final = ''
    for i = 1, #text do
        final = final .. string.sub(text, i, i)
        if i % 38 == 0 then
            final = final .. '\n'
        end
    end
    rect(0, (136 * 0.75) // 1, 240, 136 * 0.25, 8)
    rectb(0, (136 * 0.75) // 1, 240, 136 * 0.25, 4)
    print(final, 5, (136 * 0.75) + 5 // 1, 12, true)
    local seconds = (ticks // 60)
    if seconds % 2 == 0 then
        tri(235, 129, 229, 129, 232, 132, 12)
    end
end

function addProjectile(x, y, flip)
    local vx = 0
    if flip == 0 then
        vx = 2
    else
        vx = -2
    end
    table.insert(projectiles, {
        x = x,
        y = y,
        vx = vx,
        flip = flip,
        step = 0,
        shouldDelete = false,
        hittedEnemy = false,
        image = 260,
        explosionAnimation = function(self)
            local t = self.step % 30 // 15
            self.image = 262 + t
        end,
        update = function(self)
            if isSolid(self.x + vx, self.y) or isSolid(self.x + 7 + self.vx, self.y) or self.hittedEnemy then
                self:explosionAnimation()
                if (self.step / 60) > 0.40 then
                    self.shouldDelete = true
                end
            else
                self.x = self.x + self.vx
                if (self.step / 60) > 0.25 then
                    self.shouldDelete = true
                end
                local t = self.step % 30 // 15
                self.image = 260 + t
            end
            self.step = self.step + 1
        end,
        render = function(self)
            spr(self.image, self.x, self.y, 6, 1, self.flip)
        end
    })
end

function addEnemy(x, y, flip)
    table.insert(enemies, {
        health = 3,
        image = 335,
        x = x,
        y = y,
        vx = 0.5,
        vy = 0,
        flip = flip,
        moveX = function(self)
            self.x = self.x + self.vx;
        end,
        walkingAnimation = function(self)
            local t = 1 + ticks % 30 // 15
            self.image = 335 + t
        end,
        testMovement = function(self)
            if isSolid(self.x + self.vx, self.y + self.vy) or isSolid(self.x + 7 + self.vx, self.y + self.vy) or
                isSolid(self.x + self.vx, self.y + 7 + self.vy) or isSolid(self.x + 7 + self.vx, self.y + 7 + self.vy) then
                self.vx = self.vx * -1
                self.flip = (self.flip + 1) % 2
            end

            if isSolid(self.x, self.y + 8 + self.vy) or isSolid(self.x + 7, self.y + 8 + self.vy) then
                self.vy = 0
            else
                self.vy = self.vy + 0.2
            end

            if self.vy < 0 and
                (isSolid(self.x + self.vx, self.y + self.vy) or isSolid(self.x + 7 + self.vx, self.y + self.vy)) then
                self.vy = 0
            end

            if (p.x <= self.x + 4 and p.x >= self.x - 4) and (p.y <= self.y + 0.2 and p.y >= self.y - 0.2) then
                p:hurt()
            end
        end,
        update = function(self)
            self:testMovement()
            self:moveX()
            self:walkingAnimation()
        end,
        render = function(self)
            spr(self.image, self.x, self.y, 6, 1, self.flip)
        end
    })
end

function init()
    ticks = 0
    game = {
        currentLevel = 0,
        map = {
            x = 0,
            y = 0,
        },
        nextLevel = function(self)
            self.currentLevel = self.currentLevel + 1
            self.map.x = self.map.x + 30 * self.currentLevel
            -- self.map.w = 30 * (self.currentLevel + 1)
            -- self.map.h = 30 * currentLevel
        end
    }
    projectiles = {}
    enemies = {}
    p = {
        health = 3.5,
        magic = 12,
        image = 256,
        hurted = false,
        dead = false,
        lastHurted = 0,
        knockBackVx = 0,
        x = 88,
        y = 72,
        vx = 0,
        vy = 0,
        flip = 0,
        moveY = function(self)
            self.y = self.y + self.vy;
        end,
        moveX = function(self)
            self.x = self.x + self.vx;
        end,
        walkingAnimation = function(self)
            local t = 1 + ticks % 30 // 15
            self.image = 256 + t
        end,
        fallingAnimation = function(self)
            self.image = 259
        end,
        shootAnimation = function(self)
            self.image = 273
        end,
        isGrounded = function(self)
            return self.vy == 0
        end,
        refillMagic = function(self)
            local t = ticks % 60
            if self.magic < 25 and t == 0 then
                self.magic = self.magic + 1
            end
        end,
        testMovement = function(self)
            if isSolid(self.x + self.vx, self.y + self.vy) or isSolid(self.x + 7 + self.vx, self.y + self.vy) or
                isSolid(self.x + self.vx, self.y + 7 + self.vy) or isSolid(self.x + 7 + self.vx, self.y + 7 + self.vy) then
                self.vx = 0
            end

            if isSolid(self.x, self.y + 8 + self.vy) or isSolid(self.x + 7, self.y + 8 + self.vy) then
                self.vy = 0
            else
                self.vy = self.vy + 0.2
            end

            if self.vy < 0 and
                (isSolid(self.x + self.vx, self.y + self.vy) or isSolid(self.x + 7 + self.vx, self.y + self.vy)) then
                self.vy = 0
            end
            if self:isGrounded() and btnp(4) then
                self.vy = -2.5
            end
        end,
        hurt = function(self)
            if self.health ~= 0 and not self.hurted then
                self.hurted = true
                self.lastHurted = ticks
                self.health = self.health - 0.5
                self.knockBackVx = 1
                if self.flip == 0 then
                    self.knockBackVx = self.knockBackVx * -1
                end
            end
        end,
        update = function(self)
            if self.hurted and (ticks - self.lastHurted) <= 30 then
                self.image = 275
                if (ticks - self.lastHurted) < 15 then
                    self.vy = -1
                    self.vx = self.knockBackVx
                else
                    self.vy = 1
                end
            else
                self.hurted = false
                if self:isGrounded() and (btn(2) or btn(3)) then
                    self:walkingAnimation()
                elseif not self:isGrounded() then
                    self:fallingAnimation()
                end
                if btn(2) then
                    self.vx = -1
                    self.flip = 1
                elseif btn(3) then
                    self.vx = 1
                    self.flip = 0
                else
                    self.vx = 0
                end
                if btnp(5) and self.magic > 0 then
                    addProjectile(self.x + 2, self.y, self.flip)
                    self.magic = self.magic - 1
                end
                if btn(1) and not btn(2) and not btn(3) and not btn(4) then
                    self.image = 272
                end
                if btn(5) then
                    self:shootAnimation()
                    game:nextLevel()
                end
            end
            self:testMovement()
            self:moveX()
            self:moveY()
            self:refillMagic()
        end,
        hud = function(self)
            local total = self.health
            local xh = 0
            local yh = 0
            for i = 1, 5 do
                if total - 1 < 0 then
                    if total - 0.5 < 0 then
                        spr(306, xh * 8, yh, 6)
                    else
                        spr(305, xh * 8, yh, 6)
                        total = total - 0.5
                    end
                else
                    spr(304, xh * 8, yh, 6)
                    total = total - 1
                end
                xh = xh + 1
            end
            -- Codigo por Velasquez UwU
            local totalMagic = self.magic
            local xm = 200
            local ym = 0
            for i = 0, 4 do
                if totalMagic - 5 < 0 then
                    if totalMagic > 0 then
                        spr(321, xm + i * 8, ym, 6)
                        totalMagic = totalMagic - totalMagic % 5
                    else
                        spr(322, xm + i * 8, ym, 6)
                    end
                else
                    spr(320, xm + i * 8, ym, 6)
                    totalMagic = totalMagic - 5
                end
            end
        end,
        render = function(self)
            spr(self.image, self.x, self.y, 6, 1, self.flip)
            self.image = 256
        end
    }
    solidTiles = {
        [0] = false,
        [1] = true,
        [2] = true,
        [3] = true,
        [4] = true,
        [19] = true,
        [20] = true
    }
end

init()
addEnemy(184, 72, 0)

function TIC()
    cls(12)
    map(game.map.x, game.map.y)
    spr(492, 29 * 8, 5 * 8, 15)
    p:update()

    renderEnemies()
    renderProjectiles()

    p:render()
    p:hud()
    writeSpeech(string.format("balas: %s, isGrounded: %s, magia: %s, health: %s, hurted: %s, X: %s, Y: %s",
                    #projectiles, p:isGrounded(), p.magic, p.health, p.hurted, p.x, p.y))
    ticks = ticks + 1
end

-- <TILES>
-- 000:9999999999999999999999999999999999999999999999999999999999999999
-- 001:66666666767676767777777777777777ffeffefefeefeffffffeefeefeffffef
-- 002:66666666767676767777777777777777f7777777fe77777fff7777eefef77fef
-- 003:66666666766666667767676777777777fe777777feefeffffffeefeefeffffef
-- 004:effefffeffeefefffefffffeeefffeefffffeeffffeefffffefffeeeeefefeff
-- 005:9999999999999999999999999999999999777777977666667766666676666666
-- 006:9999999999999999999999999999999977777777666666666666666666666666
-- 009:9999999999999999999999999999999d99999dd89999dd8d999dd88899dd8888
-- 010:99999999999999999999999988000999d8800099808800098888000988808009
-- 018:effe7fffffee77fffefff77eeefff77fffffe77fffee77fffeff7eeeeefefeff
-- 019:6666666666666666676767677777777777777777fffefeefeefeeffffeffffef
-- 020:6666666666666666666666667777777777777777feefeffffffeefeefeffffef
-- 025:99d888d89dd888889d888888dd88d888dd8888886d888dd86dd8888866dd8888
-- 026:8888080988888800888888808880088088808880888888808888880088880006
-- 048:99999eee9999efee999efeff99eefeff9effefeeeefefeffefeefefffeffefee
-- 049:eeeeeeeeeefeeeefffeffffeffeffffeeefeeeefffeffffeffeffffeeefeeeef
-- 050:eeeeeeeeeeeefeeeffffefffffffefffeeeefeeeffffefffffffefffeeeefeee
-- 051:ee999999efe99999fefe9999fefee999efeffe99fefefee9fefeefe9efeffef9
-- 052:9999999999999996999999669996667799677777967766779677767766777777
-- 053:9996666666677777777777766777666677766777777677777777777777777707
-- 054:9999999969999999666699997777699977776999777776997707769970777769
-- 055:999999999999999999999999999999999999999999999999999999999999dd99
-- 056:999999999999999999999ddd9999dccc999dcccc99dccccc9dccccccdccccccc
-- 057:9999999999999999dd999999ccd99999cccd9999ccccd99dccccd9dccccccdcc
-- 058:9999999999999999999999999999999999999999dd999999ccd99999cccd9999
-- 064:eefefeffefeefefffeffefeeeefeeeeeefee0e00fee000e0ee00000eeeeeeeee
-- 065:ffeffffeffeffffeeefeeeefeeeeeeee00e0000e00e000e000e00e00eeeeeeee
-- 066:ffffefffffffefffeeeefeeeeeeeeeee0000e000e000e0000e00e00eeeeeeeee
-- 067:fefefee9fefeefe9efeffef9eeeefee90e0eefe9e000eef900000ee9eeeeeee9
-- 068:67777077777777007777777777777700077777e007777eee90077eee999070ee
-- 069:0777777077777777777000777700e007000ee00e00eee0eeeeeeeeeeeeeeeeee
-- 070:0777776977777769776677797677770977777709777777097777709977700999
-- 071:999dccd999dccccd9dcccccc9dccccccdcccccccdccccccc9ddddddd99999999
-- 072:dcccccccccccccccccccccccccccccccccccccccccccccccdddddddd99999999
-- 073:ccccccccccccccccccccccccccccccccccccccccccccccccdddddddd99999999
-- 074:ccccd999ccccd999cccccdd9cccccccdcccccccdcccccddddddddd9999999999
-- 080:9933333399344444993444cc993444ca993444ca993444cc9934444499344444
-- 081:3333333344444444ccc44444bbc44444bbc44444ccc4444444444444444444ee
-- 082:33333333444444444444cccc4444cabb4444cabb4444cccc44444444e4444444
-- 083:3333399944443999c4443999c4443999c4443999c44439994444399944443999
-- 084:999900ee9999999f9999999f9999999f9999999f9999999f9999999f9999999f
-- 085:eeeeeee0eeeeee00feeeee99feeeee99feeeee99feeeee99feeeee99feeeee99
-- 086:7009999909999999999999999999999999999999999999999999999999999999
-- 087:9999999999999999dd999999ccd99999cccd9999ccccd999ccccd999ccccddd9
-- 096:993444449934141499344144993447449934674477ddd76d67eeeeee66666666
-- 097:44444eef14144eff41444eff47444eff67444effd76ddccceeee766666666666
-- 098:ee444444fe4441414e444414fe444474fe444674ccdddd76667eeeee66666666
-- 099:4444399941413999441439994474399946743999dd76d777eeeee76666666666
-- 100:9999999f9999999f9999999f9999999e777777ee6666eee066eeee0066666666
-- 101:feeeee99eeeeee99eeeeee99eeeeef99eeeeeef7e00eeef600000eef66666666
-- 102:9999999999999999999999999999999977777777666666666666666666666666
-- 103:cccdccddccdccccdcddccccccdccccccdcccccccdcccccccdddddddd99999999
-- 160:bbbbbbbbcbbbbcbbcbbbbcbbcbbbbcbbcbbbbbbbcbcbbcbbbbcbbbbbbbcbbcbb
-- 161:bbbbbbcbbcbbbbbbbcbbbbcbbcbbcbcbbcbbcbcbbbbbcbcbbcbbcbbbbbbbbbbb
-- 162:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 176:bbcbbbbbbbbbbbbbbbcbbcbbbbbbbbbbbbbbbcbbcbbbbcbbcbbbbcbbcbcbbbbb
-- 177:bbbbbbbbbbbbcbbbbbbbbbbbbbbbcbbcbbbbcbbcbbbbcbbbbbbbbbbcbbbbbbbc
-- 192:cbcbbbbbcbcbbbbbcbcbbbbbbbcbbbbbcbbbbbbbbbcbbbbbbbbbbbbbbbbbbbbb
-- 193:bbbbbbbbbbcbbbbbbbbbbbbbbbcbbbbbbbcbbbcbbbcbbbcbbbbbbbcbbbbbbbcb
-- 208:bbbbbbbbbbbbcbbbbbbbcbbbbbbbcbbbbbbbcbbbbbbbbbbbbbbbcbbbbbbbbbbb
-- 209:bbbbbbcbbbbbbbbbbbbbbbcbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- </TILES>

-- <SPRITES>
-- 000:66eee6666e444666640406666444466667737666674774666ffff6666e66e666
-- 001:66eee6666e444666640406666444466667737466647776666ffffe666e666666
-- 002:66eee6666e44466664040666644446666773766667477466effff6666666e666
-- 003:66eee6666e44466664040666444444666773766667777666effffe6666666666
-- 004:6666666666666666666662226362233266662232264662226666666666666666
-- 005:6666666666666666264662226666223263622332666662226666666666666666
-- 006:6666666666662266666233266623443266234432666233266666226666666666
-- 007:6666666666623326662466426636666366366663662466426662332666666666
-- 016:6666666666eee6666e444666640406666444466667737666674774666feffe66
-- 017:66eee6666e444666640406666444466667774666677774666ffff6666e66e666
-- 019:666eee6666e4446666404066664a446667737666674746666ffffe6666e66666
-- 032:66efff666eff4f66ef404066ef544466e6111146661411666111111666266266
-- 033:66efff666eff4f66ef404066ef544466e6141166661111466111111666266266
-- 034:6d4446666d04066664444666689c946668884ee6699996e6688886e666f6f6e6
-- 035:6d4446666d04066664444646689c98666884ee6669999ee6688886ee66f6f66e
-- 036:64146666444146d64ffffd2d4f0f04d64ffff6d664f44fd6644446d6680880d6
-- 037:66666666441446d644414d2d4ffff4d64f0f06d6644446d664f44fd6680880d6
-- 048:6666666662666266222622262222222622222226622222666622266666626666
-- 049:6666666662666066222600062220000622200006622200666622066666626666
-- 050:6666666660666066000600060000000600000006600000666600066666606666
-- 064:666166666671766666787666667876666788876678c888767c88887667777766
-- 065:666166666671766666707666667076666700076678c888767c88887667777766
-- 066:666166666671766666707666667076666700076670c000767c00007667777766
-- 080:6666666661111116612112162132231262111126211221126ff66e6666666ee6
-- 081:66666666611111166121121621322312621111262112211266e66ff66ee66666
-- 096:ff604ffff66444faf66044f1f66444f142666664ff6666f1ff3333ffff2ff2ff
-- 236:cffcfffcccffcfccfcfcffcfffffffffcff33ffcff3434fff344444f3ccccccc
-- 237:00cccc00000cccc000cc2c20cc1cccc00cc1cc000ccc100000ccc00000000000
-- </SPRITES>

-- <MAP>
-- 001:0000738393a300000000738393a30000000000007383758393a300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 002:0000748494a400000000748494a40000000000007484768494a400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 005:000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 006:100000000000000000000000000313233300435363000000000000005010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 007:400000000000000000000000000414243400445464000000000000501040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 008:4090a0000000000000000000000515253500455565000000000050104040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 009:4091a1606060606060606060600616263660465666606060606010404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 010:401010101010101010101020101010102030414131101010101040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 011:404040404040404040404021404040402140404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 012:404040404040404040404040404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 013:404040404040404040404040404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 014:404040404040404040404040404040404040404040404040404040404040100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 015:404040404040404040404040404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 016:404040404040404040404040404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </MAP>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000
-- 006:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000
-- </SFX>

-- <FLAGS>
-- 001:00000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </FLAGS>

-- <PALETTE>
-- 000:1a1c2c8d0cd2d2182cf2892cffcd75ff81795d953025592429366f3b5dc941a6f65dd2fff4f4f494b0c2441c0059280c
-- </PALETTE>

