package edgy_man

import rl "vendor:raylib"

Player_State_Idle :: struct {

}

// Edgy Man takes a few frames before he can actually start running.
Player_State_Inch :: struct {
    frames_left: int,
}

Player_State_Run :: struct {
    animation_frames_left: int, // TODO: We should probably make an Animation struct which stores where we are in an animation.
    current_frame: int,
}

Player_State_Jump :: struct {

}

Player_State :: union {
    Player_State_Idle,
    Player_State_Inch,
    Player_State_Run,
    Player_State_Jump,
}

Direction :: enum {
    Left,
    Right,
}

Player :: struct {
    state: Player_State,
    using position: rl.Vector2,
    direction: Direction,
}

player_update :: proc(using player: ^Player) {
    switch in state {
        case Player_State_Idle:
            old_position := position
            if rl.IsKeyDown(.LEFT) do x -= 1
            if rl.IsKeyDown(.RIGHT) do x += 1
            if position != old_position {
                if position.x > old_position.x do direction = .Right
                else do direction = .Left
                state = Player_State_Inch{frames_left = 3} // I actually don't know if 3 is the right number of frames to be honest...
                return
            }

        case Player_State_Inch:
            using s := &state.(Player_State_Inch)
            frames_left -= 1
            if frames_left <= 0 {
                state = Player_State_Run{animation_frames_left = 6}
                return
            }

        case Player_State_Run:
            using s := &state.(Player_State_Run)

            animation_frames_left -= 1
            if animation_frames_left <= 0 {
                animation_frames_left = 6
                current_frame += 1
                if current_frame >= 3 do current_frame = 0
            }

            old_position := position
            if rl.IsKeyDown(.LEFT) do x -= 1
            if rl.IsKeyDown(.RIGHT) do x += 1
            if old_position == position do state = Player_State_Idle{}

        case Player_State_Jump:
    }
}

player_draw :: proc(using player: ^Player) {
    switch in state {
        case Player_State_Idle:
            if direction == .Left do rl.DrawTextureRec(edgy_man_idle, rl.Rectangle{0, 0, 24, 24}, position, rl.WHITE)
            else do rl.DrawTexturePro(edgy_man_idle, rl.Rectangle{0, 0, -24, 24}, rl.Rectangle{position.x, position.y, 24, 24}, rl.Vector2{}, 0.0, rl.WHITE)

        case Player_State_Inch:
            if direction == .Left do rl.DrawTextureRec(edgy_man_inch, rl.Rectangle{0, 0, 24, 24}, position, rl.WHITE)
            else do rl.DrawTexturePro(edgy_man_inch, rl.Rectangle{0, 0, -24, 24}, rl.Rectangle{position.x, position.y, 24, 24}, rl.Vector2{}, 0.0, rl.WHITE)

        case Player_State_Run:
            using s := &state.(Player_State_Run)

            frame_x := f32(current_frame*32 + 32)
            if direction == .Left do rl.DrawTextureRec(edgy_man_run, rl.Rectangle{frame_x, 0, 32, 24}, position - rl.Vector2{32 - 24, 0}, rl.WHITE)
            else do rl.DrawTexturePro(edgy_man_run, rl.Rectangle{frame_x, 0, -32, 24}, rl.Rectangle{position.x, position.y, 32, 24}, rl.Vector2{}, 0.0, rl.WHITE)

        case Player_State_Jump:
            
    }
}

