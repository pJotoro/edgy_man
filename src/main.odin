package edgy_man

import rl "vendor:raylib"
import "core:fmt"


main :: proc() {
    rl.InitWindow(GAME_SCREEN_WIDTH, GAME_SCREEN_HEIGHT, "Edgy Man")
    defer rl.CloseWindow()

    camera := fix_resolution()

    load_textures()
    defer unload_textures()

    t_x := f32(7*16)
    t_y := f32(6*16)

    entities: [1]Entity
    floor_tiles := [?][2]i32{
        { 5, 7 },
        { 6, 7 },
        { 7, 7 },
        { 8, 7 },
        { 9, 10 },
        { 10, 10 },
        { 11, 10 },
        { 12, 11 },
    }
    floor_tex_id := tile_resource_create(floor_tile)
    entities[0] = Player{state = Player_State_Idle{}, position = rl.Vector2{t_x, t_y}, direction = .Left}
    for tile_p in floor_tiles {
        tile_create(floor_tex_id, tile_p)
    }
    rl.SetTargetFPS(60)

    for !rl.WindowShouldClose() {
        for entity, entity_index in entities {
            if entity != nil do entity_update(&entities[entity_index])
        }

        tiles_update(rl.GetFrameTime())

        rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)
        rl.BeginMode2D(camera)
        for entity, entity_index in entities {
            if entity == nil do continue
            entity_draw(&entities[entity_index])
        }

        tiles_render()

        rl.EndMode2D()
        rl.EndDrawing()
    }
}

generate_floor_tiles :: proc($N: int) -> (result: [N][2]i32) {
    for i := 0; i < len(result); i += 1 {
        result[i] = { i32(5 + i), i32(7)}
    }
    return
}

