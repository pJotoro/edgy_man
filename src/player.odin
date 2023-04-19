package edgy_man

import rl "vendor:raylib"

player_visualise_collision := false
player_collision_size := [2]f32 { 22, 24 }
player_collision_offset := [2]f32 { player_collision_size.x / 2, player_collision_size.y - grid_size.y }

// sprite is 24 pixels tall, so the bottom is position + 24 pixels. 

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


Player_State :: enum {
    Idle,
    Inch,
    Run,
    Airborne,
}

Direction :: enum {
    Left,
    Right,
}

Player :: struct {
    state: Player_State,
    using position: rl.Vector2,
    direction: Direction,
    vertical_velocity : f32,
    frames_moving: int,
}

player_update :: proc(using player: ^Player) {

    old_position := position
    if rl.IsKeyDown(.LEFT) do x -= 1
    if rl.IsKeyDown(.RIGHT) do x += 1
    if old_position == position {
        state = .Idle
        frames_moving = 0
    }
    else {
        if position.x > old_position.x do direction = .Right
        else do direction = .Left
        frames_moving += 1
    }

    ground_tile_index, grounded := tiles_point_overlaps_tile({ player_horizontal_centre(player), player_feet(player) }) 
    if !grounded do state = .Airborne // overwrite all the other stuff
    else {
        if frames_moving > 3 {
            state = .Run
        }
        else if frames_moving > 0 {
            state = .Inch
        }
        else {
            state = .Idle
        }
    }
    y += vertical_velocity

    frame_box := rl.Rectangle{ 
        position.x + cast(f32)player_collision_offset.x, 
        position.y + cast(f32)player_collision_offset.y, 
        cast(f32)player_collision_size.x, 
        cast(f32)player_collision_size.y, 
    }

    if rl.IsKeyReleased(rl.KeyboardKey.SPACE) {
        player_visualise_collision = !player_visualise_collision
    }
}

player_horizontal_centre :: proc(using player: ^Player) -> f32 {
    return position.x
}

player_right :: proc(using player: ^Player) -> f32 {
    return position.x + player_collision_size.x / 2
}

player_left :: proc(using player: ^Player) -> f32 {
    return position.x - player_collision_size.x / 2
}

player_feet :: proc(using player: ^Player) -> f32 {
    return position.y + player_collision_size.y - player_collision_offset.y
}

player_head :: proc(using player: ^Player) -> f32 {
    return position.y - player_collision_offset.y
}

player_draw :: proc(using player: ^Player) {
    draw_pos := rl.Vector2{ position.x - f32(player_collision_size.x / 2) , position.y - cast(f32)edgy_man_idle.height + cast(f32)grid_size.y }
    switch state {
        case .Idle:
            if direction == .Left do rl.DrawTextureRec(edgy_man_idle, rl.Rectangle{0, 0, 24, 24}, draw_pos, rl.WHITE)
            else do rl.DrawTexturePro(edgy_man_idle, rl.Rectangle{0, 0, -24, 24}, rl.Rectangle{draw_pos.x, draw_pos.y, 24, 24}, rl.Vector2{}, 0.0, rl.WHITE)

        case .Inch:
            if direction == .Left do rl.DrawTextureRec(edgy_man_inch, rl.Rectangle{0, 0, 24, 24}, draw_pos, rl.WHITE)
            else do rl.DrawTexturePro(edgy_man_inch, rl.Rectangle{0, 0, -24, 24}, rl.Rectangle{draw_pos.x, draw_pos.y, 24, 24}, rl.Vector2{}, 0.0, rl.WHITE)

        case .Run:
            frame_x := f32((frames_moving/6)%3*32 + 32)
            if direction == .Left do rl.DrawTextureRec(edgy_man_run, rl.Rectangle{frame_x, 0, 32, 24}, draw_pos - rl.Vector2{32 - 24, 0}, rl.WHITE)
            else do rl.DrawTexturePro(edgy_man_run, rl.Rectangle{frame_x, 0, -32, 24}, rl.Rectangle{draw_pos.x, draw_pos.y, 32, 24}, rl.Vector2{}, 0.0, rl.WHITE)
        case .Airborne:
            if direction == .Left do rl.DrawTextureRec(edgy_man_jump, rl.Rectangle{0, 0, 32, 32}, draw_pos - rl.Vector2{32 - 24, 0}, rl.WHITE)
            else do rl.DrawTexturePro(edgy_man_jump, rl.Rectangle{0, 0, -32, 32}, rl.Rectangle{draw_pos.x, draw_pos.y, 32, 32}, rl.Vector2{}, 0.0, rl.WHITE)
    }

    if player_visualise_collision {
        rl.DrawRectangleLines(
            i32(player_left(player)), 
            cast(i32)player_head(player), 
            i32(player_right(player) - player_left(player)), 
            i32(player_feet(player) - player_head(player)), 
            rl.GREEN)
        
    }
}

