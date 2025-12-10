import 'util/pdfxr'

local SoundManager = {}

SoundManager.kClick = 'click'
SoundManager.kClimb = 'climb'
SoundManager.kDeath = 'death'
SoundManager.kGrow = 'grow'
SoundManager.kHeadbut = 'headbut'
SoundManager.kJump = 'jump'
SoundManager.kLand = 'land'
SoundManager.kStepSusi = 'step_susi'
SoundManager.kStepSandy = 'step_sandy'
SoundManager.kMenuMove = 'menu_move'
SoundManager.kButtonA = 'button_a'
SoundManager.kButtonB = 'button_b'
SoundManager.kSwoosh = 'swoosh'
SoundManager.kSpring = 'spring'
SoundManager.kCollect = 'collect'

SoundManager.sounds = {
    [SoundManager.kClick] = pdfxr.synth.new("assets/sfx/click"),
    [SoundManager.kClimb] = pdfxr.synth.new("assets/sfx/climb"),
    [SoundManager.kDeath] = pdfxr.synth.new("assets/sfx/death"),
    [SoundManager.kGrow] = pdfxr.synth.new("assets/sfx/grow"),
    [SoundManager.kHeadbut] = pdfxr.synth.new("assets/sfx/headbut"),
    [SoundManager.kJump] = pdfxr.synth.new("assets/sfx/jump"),
    [SoundManager.kLand] = pdfxr.synth.new("assets/sfx/land"),
    [SoundManager.kStepSusi] = pdfxr.synth.new("assets/sfx/step_susi"),
    [SoundManager.kStepSandy] = pdfxr.synth.new("assets/sfx/step_sandy"),
    [SoundManager.kMenuMove] = pdfxr.synth.new("assets/sfx/menu_move"),
    [SoundManager.kButtonA] = pdfxr.synth.new("assets/sfx/button_a"),
    [SoundManager.kButtonB] = pdfxr.synth.new("assets/sfx/button_b"),
    [SoundManager.kSwoosh] = pdfxr.synth.new("assets/sfx/swoosh"),
    [SoundManager.kSpring] = pdfxr.synth.new("assets/sfx/spring"),
    [SoundManager.kCollect] = pdfxr.synth.new("assets/sfx/collect"),
}

function SoundManager:playSound(name)
    self.sounds[name]:play()
end

function SoundManager:stopSound(name)
    self.sounds[name]:stop()
end

function SoundManager:playBackgroundMusic()
    local filePlayer = pdfxr.synth.new("assets/sfx/background_music")
    filePlayer:start()
end

_G.SoundManager = SoundManager