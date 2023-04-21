package edgy_man

import rl "vendor:raylib"

player_visualise_collision := false
player_collision_size := [2]f32 { 22, 24 }
player_collision_offset := [2]f32 { player_collision_size.x / 2, player_collision_size.y - grid_size.y }
player_terminal_y_velocity :f32 = 2.0
player_gravity : f32 = 0.008

// sprite is 24 pixels tall, so the bottom is position + 24 pixels. 

Player_State_Idle :: struct {

}

Player_State_Airborne :: struct {

}

// Edgy Man takes a few frames before he can actually start running.
Player_State_Inch :: struct {
    frames_left: int,
}

Player_State_Run :: struct {
    animation_frames_left: int, // TODO: We should probably make an Animation struct which stores where we are in an animation.
    current_frame: int,
}


Player_State :: union {
    Player_State_Idle,
    Player_State_Inch,
    Player_State_Run,
    Player_State_Airborne,
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

    movement_active : bool = true
    col_bl := tiles_point_overlaps_tile( { player_left(player), player_feet(player) })
    col_br := tiles_point_overlaps_tile( { player_right(player), player_feet(player) })
    col_bm := tiles_point_overlaps_tile( { player_horizontal_centre(player), player_feet(player) })
    col_tl := tiles_point_overlaps_tile( { player_left(player), player_head(player) })
    col_tr := tiles_point_overlaps_tile( { player_right(player), player_head(player) })
    col_tm := tiles_point_overlaps_tile( { player_horizontal_centre(player), player_head(player) })
    
    
    grounded := col_bl || col_bm || col_br
    wall_left := tiles_any_point_overlap_tiles( { { player_left(player), player_feet(player) - 1}, { player_left(player), player_mid_vertical(player), }, { player_left(player), player_head(player) + 1, } })
    wall_right := tiles_any_point_overlap_tiles( { { player_right(player), player_feet(player) - 1}, { player_right(player), player_mid_vertical(player), }, { player_right(player), player_head(player) + 1, } })
    ceiling := col_tl || col_tm || col_tr

    if !grounded {
        state = Player_State_Airborne{}
        vertical_velocity = max(vertical_velocity + player_gravity, player_terminal_y_velocity)
    }
    else {

        vertical_velocity = 0
        _, was_airborne := state.(Player_State_Airborne)
        if was_airborne {
            state = Player_State_Idle{}
        }
    }
    switch in state {
        case Player_State_Airborne:
            break;
        case Player_State_Idle:
            break;
        case Player_State_Inch:
            using s := &state.(Player_State_Inch)
            movement_active = false
            frames_left -= 1
            if frames_left <= 0 {
                state = Player_State_Run{animation_frames_left = 6}
                break
            }  
        case Player_State_Run:
            using s := &state.(Player_State_Run)
            animation_frames_left -= 1
            if animation_frames_left <= 0 {
                animation_frames_left = 6
                current_frame += 1
                if current_frame >= 3 do current_frame = 0
            }

    }

    if movement_active {
        old_position := position
        if rl.IsKeyDown(.LEFT) && !wall_left do x -= 1
        if rl.IsKeyDown(.RIGHT) && !wall_right do x += 1
        if old_position == position {
            state = Player_State_Idle{}
            frames_moving = 0
        }
        else {
            if position.x > old_position.x do direction = .Right
            else do direction = .Left
            frames_moving += 1
            #partial switch in state {
                case Player_State_Idle:
                    state = Player_State_Inch{}
            }
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

player_mid_vertical :: proc(using player: ^Player) -> f32 {
    return position.y - player_collision_offset.y + player_collision_size.y * 0.5
}



player_head :: proc(using player: ^Player) -> f32 {
    return position.y - player_collision_offset.y
}

player_draw :: proc(using player: ^Player) {
    draw_pos := rl.Vector2{ position.x - f32(player_collision_size.x / 2) , position.y - cast(f32)edgy_man_idle.height + cast(f32)grid_size.y }
    switch in state {
        case Player_State_Idle:
            if direction == .Left do rl.DrawTextureRec(edgy_man_idle, rl.Rectangle{0, 0, 24, 24}, draw_pos, rl.WHITE)
            else do rl.DrawTexturePro(edgy_man_idle, rl.Rectangle{0, 0, -24, 24}, rl.Rectangle{draw_pos.x, draw_pos.y, 24, 24}, rl.Vector2{}, 0.0, rl.WHITE)

        case Player_State_Inch:
            if direction == .Left do rl.DrawTextureRec(edgy_man_inch, rl.Rectangle{0, 0, 24, 24}, draw_pos, rl.WHITE)
            else do rl.DrawTexturePro(edgy_man_inch, rl.Rectangle{0, 0, -24, 24}, rl.Rectangle{draw_pos.x, draw_pos.y, 24, 24}, rl.Vector2{}, 0.0, rl.WHITE)

        case Player_State_Run:
            using s := &state.(Player_State_Run)
            frame_x := f32(current_frame*32 + 32)

            if direction == .Left do rl.DrawTextureRec(edgy_man_run, rl.Rectangle{frame_x, 0, 32, 24}, draw_pos - rl.Vector2{32 - 24, 0}, rl.WHITE)
            else do rl.DrawTexturePro(edgy_man_run, rl.Rectangle{frame_x, 0, -32, 24}, rl.Rectangle{draw_pos.x, draw_pos.y, 32, 24}, rl.Vector2{}, 0.0, rl.WHITE)
        case Player_State_Airborne:
            if direction == .Left do rl.DrawTextureRec(edgy_man_jump, rl.Rectangle{0, 0, 32, 32}, draw_pos - rl.Vector2{32 - 24, 0}, rl.WHITE)
            else do rl.DrawTexturePro(edgy_man_jump, rl.Rectangle{0, 0, -32, 32}, rl.Rectangle{draw_pos.x, draw_pos.y, 32, 32}, rl.Vector2{}, 0.0, rl.WHITE)
    }

    // not "real" collision at the moment.
    if player_visualise_collision {
        rl.DrawRectangleLines(
            i32(player_left(player)), 
            cast(i32)player_head(player), 
            i32(player_right(player) - player_left(player)), 
            i32(player_feet(player) - player_head(player)), 
            rl.GREEN)
        
    }
}

