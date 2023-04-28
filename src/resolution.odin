package edgy_man

import rl "vendor:raylib"
import "core:math"

GAME_SCREEN_WIDTH :: 256
GAME_SCREEN_HEIGHT :: 240

fix_resolution :: proc() -> (camera: rl.Camera2D) {
    monitor_width := rl.GetMonitorWidth(rl.GetCurrentMonitor())
    zoom := math.floor(f32(monitor_width) / GAME_SCREEN_WIDTH / 5)
    camera = rl.Camera2D{zoom = zoom}

    rl.SetWindowSize(GAME_SCREEN_WIDTH * i32(zoom), GAME_SCREEN_HEIGHT * i32(zoom))
    //rl.SetWindowPosition((rl.GetMonitorWidth(rl.GetCurrentMonitor()) - GAME_SCREEN_WIDTH * i32(zoom)) / 2, (rl.GetMonitorHeight(rl.GetCurrentMonitor()) - GAME_SCREEN_HEIGHT * i32(zoom)) / 2)
    rl.SetWindowPosition(100, 100)
    return
}