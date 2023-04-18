package edgy_man

import rl "vendor:raylib"

edgy_man_idle: rl.Texture2D
edgy_man_run: rl.Texture2D
edgy_man_inch: rl.Texture2D
edgy_man_jump: rl.Texture2D

load_textures :: proc() {
    edgy_man_idle = rl.LoadTexture("assets/edgy_man-Sheet.png")
    edgy_man_run = rl.LoadTexture("assets/edgy_man_run-Sheet.png")
    edgy_man_inch = rl.LoadTexture("assets/edgy_man_inch.png")
    edgy_man_jump = rl.LoadTexture("assets/edgy_man_jump.png")
}

unload_textures :: proc() {
    rl.UnloadTexture(edgy_man_idle)
    rl.UnloadTexture(edgy_man_run)
    rl.UnloadTexture(edgy_man_inch)
    rl.UnloadTexture(edgy_man_jump)
}