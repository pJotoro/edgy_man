package edgy_man

import rl "vendor:raylib"

Tile :: struct {
    using position: [2]i32, // cell position
    texture: rl.Texture2D,
    half_size: [2]i32, // of cell.
}

tile_update :: proc(using tile: ^Tile) {

}

import "core:fmt"
tile_render :: proc(using tile: ^Tile) {
    render_pos := rl.Vector2{ f32(position.x * half_size.x * 2), f32(position.y * half_size.y*2)}
    rl.DrawTextureRec(texture, 
            rl.Rectangle{0, 0, f32(half_size.x * 2), f32(half_size.y * 2) }, 
            render_pos, 
            rl.WHITE)
}

tile_create :: proc(in_texture: rl.Texture2D, position: [2]i32) -> Tile {
    return Tile{
        half_size = {4, 4},
        position = position,
        texture = in_texture,
    }
}

