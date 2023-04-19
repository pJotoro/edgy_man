package edgy_man

import "core:slice"

import rl "vendor:raylib"

tile_resource_count : u8 = 0
tile_texture_resources: [256]rl.Texture2D

grid_size := [2]f32 { 16, 16 }

tile_count := 0
tile_current_id := 0
tile_ids: [960]int
tile_positions: [960][2]i32 // 960 is the absolute maximum number of tiles for the resolution in resolution.odin
tile_texture_ids: [960]u8   // we of course are not limited by resolution, since levels expand beyond the screen.

tiles_update :: proc(dt: f32) {

}


import "core:fmt"
tiles_render :: proc() {
    for i := 0; i < tile_count; i += 1{
        pos := tile_positions[i]
        tex := tile_texture_resources[tile_texture_ids[i]]
        rl.DrawTextureRec(tex, rl.Rectangle{0,0, cast(f32)tex.width, cast(f32)tex.height}, 
        rl.Vector2{ cast(f32)(pos.x * tex.width), cast(f32)(pos.y * tex.height)},
        rl.WHITE)
    }
}

tile_create_texture :: proc(in_texture: rl.Texture2D, position: [2]i32) -> int {
   tile_positions[tile_count] = position
   tex_id : int = -1
   for tex, index in tile_texture_resources {
        if (in_texture.id == tex.id) {
            tex_id = index
            break
        }
   }
   tex_byte : u8
   if (tex_id == -1) {
        tex_byte = tile_resource_create(in_texture)
   }
   else {
    assert(tex_id < 256)
    tex_byte = cast(u8)tex_id
   }
   return #force_inline tile_create_tex_id(tex_byte, position)
}

tile_create_tex_id :: proc(tile_tex_id: u8, position: [2]i32) -> int {
    tile_texture_ids[tile_count] = tile_tex_id
    tile_positions[tile_count] = position
    tile_ids[tile_count] = tile_current_id 
    tile_current_id += 1
    tile_count += 1
    return tile_ids[tile_count]
}

tile_create :: proc{tile_create_texture, tile_create_tex_id}

tile_resource_create :: proc(texture: rl.Texture2D) -> u8 {
    tile_texture_resources[tile_resource_count] = texture
    tile_resource_count += 1
    assert(tile_resource_count != 0)
    return tile_resource_count - 1
}

tile_remove :: proc(tile_id: int) -> (exists: bool) {
    tile_index := slice.linear_search(tile_ids[:], tile_id) or_return
    slice.swap(tile_positions[:], tile_index, tile_count)
    slice.swap(tile_ids[:], tile_index, tile_count)
    slice.swap(tile_texture_ids[:], tile_index, tile_count)
    tile_count -= 1
    return true
}

tiles_point_overlaps_tile :: proc(pixel: [2]f32) -> (tile_id: int, ok: bool) {
    cell := [2]i32 { i32(pixel.x / f32(grid_size.x)), i32(pixel.y / f32(grid_size.y)) }
    celldex := slice.linear_search(tile_positions[:], cell) or_return
    return tile_ids[celldex], true
}