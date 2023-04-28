package edgy_man

import "core:fmt"
import rl "vendor:raylib"

player_visualise_collision := false
player_collision_size := [2]f32 { 22, 24 }
player_collision_offset := [2]f32 { 11, 12 }
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

update_animation :: proc(using player: ^Player) {
    switch in state {
        case Player_State_Airborne:
            break;
        case Player_State_Idle:
            break;
        case Player_State_Inch:
            using s := &state.(Player_State_Inch)
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
}

player_update :: proc(using player: ^Player) {

    update_animation(player)
    left_feet_index, col_bl := tiles_point_overlaps_tile( { player_left(player) + 1, player_feet(player) })
    right_feet_index, col_br := tiles_point_overlaps_tile( { player_right(player) - 1, player_feet(player) })
    mid_feet_index, col_bm := tiles_point_overlaps_tile( { player_horizontal_centre(player), player_feet(player) })
    grounded := col_bl || col_bm || col_br

    movement_active : bool 
    switch in state {
        case Player_State_Airborne, Player_State_Idle, Player_State_Run:
            movement_active = true
        case Player_State_Inch:
            movement_active = false
    }
    
    _, col_tl := tiles_point_overlaps_tile( { player_left(player), player_head(player) })
    _, col_tr := tiles_point_overlaps_tile( { player_right(player), player_head(player) })
    _, col_tm := tiles_point_overlaps_tile( { player_horizontal_centre(player), player_head(player) })
    
    check_left := player_left(player) + 1
    check_right := player_right(player) - 1

    ceiling := col_tl || col_tm || col_tr

    if !grounded {
        state = Player_State_Airborne{}
        vertical_velocity = max(vertical_velocity + player_gravity, player_terminal_y_velocity)
    }
    else {
        if col_bl do y = tile_top(left_feet_index) - player_collision_offset.y
        else if col_br do y = tile_top(right_feet_index) - player_collision_offset.y
        else if col_bm do y = tile_top(mid_feet_index) - player_collision_offset.y

        vertical_velocity = 0
        _, was_airborne := state.(Player_State_Airborne)
        if was_airborne {
            state = Player_State_Idle{}
        }
    }


    if movement_active {
        old_position := position
        if rl.IsKeyDown(.LEFT) {
            x -= 1
            direction = .Left
        }
        if rl.IsKeyDown(.RIGHT) {
            x += 1
            direction = .Right
        }

        if rl.IsKeyUp(.LEFT) && rl.IsKeyUp(.RIGHT) && grounded {
            state = Player_State_Idle{}
            frames_moving = 0
        } else {
            movement_direction : Direction
            if old_position.x < position.x {
                movement_direction = .Right
            } else if old_position.x > position.x {
                movement_direction = .Left
            }
            frames_moving += 1
            #partial switch in state {
                case Player_State_Idle:
                    state = Player_State_Inch{}
                case Player_State_Inch, Player_State_Run, Player_State_Airborne:
                    switch movement_direction {
                        case .Left:
                            // check the left side of edgy_man, move right if need to.
                            left_p := player_left(player)
                            left_head, left_mid, left_feet : bool
                            collision_id : int
                            collision_id, left_head = tiles_point_overlaps_tile({ left_p, player_head(player)})
                            if left_head { 
                                x = tile_right(collision_id) + player_collision_size.x * 0.5
                                break
                            }

                            collision_id, left_mid = tiles_point_overlaps_tile({ left_p, player_mid_vertical(player)})
                            if left_mid { 
                                x = tile_right(collision_id) + player_collision_size.x * 0.5
                                break
                            }

                            collision_id, left_feet = tiles_point_overlaps_tile({ left_p, player_feet(player) - 1})
                            if left_feet { 
                                x = tile_right(collision_id)+ player_collision_size.x * 0.5
                                break
                            }
                        case .Right:
                            right_p := player_right(player)
                            right_head, right_mid, right_feet: bool
                            collision_id : int

                            collision_id, right_head = tiles_point_overlaps_tile({ right_p, player_head(player)})
                            if right_head { 
                                x = tile_left(collision_id) - player_collision_size.x * 0.5 - 1
                                break;
                            }
                            collision_id, right_mid = tiles_point_overlaps_tile({ right_p, player_mid_vertical(player)})
                            if right_mid {
                                 x = tile_left(collision_id) - player_collision_size.x * 0.5 - 1
                                 break
                            } 

                            collision_id, right_feet = tiles_point_overlaps_tile({ right_p, player_feet(player) - 1})
                            if right_feet {
                                x = tile_left(collision_id) - player_collision_size.x * 0.5 - 1
                                break
                            }
                    }
                    
            }
        }
    }

    if rl.IsKeyDown(.Z) do vertical_velocity = -1

    y += vertical_velocity
    check_above_points := [3]f32 { player_left(player), player_horizontal_centre(player), player_right(player) }
    p_head := player_head(player)
    for p, i in check_above_points {
        id, collision := tiles_point_overlaps_tile( { p, p_head })
        if collision {
            y = tile_bottom(id) + (player_collision_size.y * 0.5)
            break
        }
    }
    frame_box := rl.Rectangle{ 
        position.x + cast(f32)player_collision_offset.x, 
        position.y + cast(f32)player_collision_offset.y, 
        cast(f32)player_collision_size.x, 
        cast(f32)player_collision_size.y, 
    }

    if rl.IsKeyReleased(rl.KeyboardKey.SPACE) {
        player_visualise_collision = !player_visualise_collision
        if player_visualise_collision{
            rl.SetTargetFPS(10)
        } else {
            rl.SetTargetFPS(60)
        }
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
    draw_pos := position - rl.Vector2(player_collision_offset)
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
        left := i32(player_left(player))
        right := i32 (player_right(player))
        head := i32 (player_head(player))
        feet := i32 (player_feet(player))
        centre := i32 (player_horizontal_centre(player))
        mid := i32 (player_mid_vertical(player))
        if direction == .Left {
            rl.DrawCircle(left, head, 1, rl.RED)
            rl.DrawCircle(left, mid, 1, rl.RED)
            rl.DrawCircle(left, feet, 1, rl.RED)
        }
        rl.DrawCircle(centre, head, 1, rl.RED)
        rl.DrawCircle(centre, feet, 1, rl.RED)
        if direction == .Right {
            rl.DrawCircle(right, mid, 1, rl.RED)
            rl.DrawCircle(right, feet, 1, rl.RED)
            rl.DrawCircle(right, head, 1, rl.RED)
        }
        /*rl.DrawRectangleLines(
            i32(player_left(player)), 
            cast(i32)player_head(player), 
            i32(player_right(player) - player_left(player)), 
            i32(player_feet(player) - player_head(player)), 
            rl.GREEN)*/
        
    }
}

