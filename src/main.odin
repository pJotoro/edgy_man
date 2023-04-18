package edgy_man

import rl "vendor:raylib"

main :: proc() {
    rl.InitWindow(GAME_SCREEN_WIDTH, GAME_SCREEN_HEIGHT, "Edgy Man")
    defer rl.CloseWindow()

    camera := fix_resolution()

    load_textures()
    defer unload_textures()

    entities: [1]Entity
    entities[0] = Player{state = Player_State_Idle{}, position = rl.Vector2{100, 150}, direction = .Left}

    rl.SetTargetFPS(60)

    for !rl.WindowShouldClose() {
        for entity, entity_index in entities {
            if entity != nil do entity_update(&entities[entity_index])
        }

        rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)
        rl.BeginMode2D(camera)
        for entity, entity_index in entities {
            if entity != nil do entity_draw(&entities[entity_index])
        }
        rl.EndMode2D()
        rl.EndDrawing()
    }
}

