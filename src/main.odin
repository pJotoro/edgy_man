package edgy_man

import rl "vendor:raylib"
import "core:fmt"


main :: proc() {
    rl.InitWindow(GAME_SCREEN_WIDTH, GAME_SCREEN_HEIGHT, "Edgy Man")
    defer rl.CloseWindow()

    camera := fix_resolution()

    load_textures()
    defer unload_textures()

    t_x := f32(14 * 8)
    t_y := f32(12 * 8)

    entities: [256]Entity
    floor_tiles := generate_floor_tiles(14)
    entities[0] = Player{state = Player_State_Idle{}, position = rl.Vector2{t_x, t_y}, direction = .Left}
    for tile, i in floor_tiles {
        entities[i + 1] = tile
    }

    fmt.println(floor_tiles)

    rl.SetTargetFPS(60)

    for !rl.WindowShouldClose() {
        for entity, entity_index in entities {
            if entity != nil do entity_update(&entities[entity_index])
        }

        rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)
        rl.BeginMode2D(camera)
        for entity, entity_index in entities {
            if entity == nil do continue
            entity_draw(&entities[entity_index])
        }

        rl.EndMode2D()
        rl.EndDrawing()
    }
}

generate_floor_tiles :: proc($N: int) -> (result: [N]Tile) {
    for i := 0; i < len(result); i += 1 {
        result[i] = tile_create(floor_tile, { i32(10 + i), i32(15)})
    }
    return
}

