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

tiles_collision_visualize : bool = false

tiles_update :: proc(dt: f32) {
    if rl.IsKeyReleased(.SPACE) {
        tiles_collision_visualize = !tiles_collision_visualize
    }
}


import "core:fmt"
tiles_render :: proc() {
    for i := 0; i < tile_count; i += 1{
        pos := tile_positions[i]
        tex := tile_texture_resources[tile_texture_ids[i]]
        rl.DrawTextureRec(tex, rl.Rectangle{0,0, cast(f32)tex.width, cast(f32)tex.height}, 
            rl.Vector2{ cast(f32)(pos.x * tex.width), cast(f32)(pos.y * tex.height)},
            rl.WHITE)
        if tiles_collision_visualize {
            rl.DrawRectangleLines(cast(i32)tile_left(pos), cast(i32)tile_top(pos), i32(tile_right(pos) - tile_left(pos)), i32(tile_bottom(pos) - tile_top(pos)), rl.GREEN)
        }
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

tile_grid_cell_from_point :: #force_inline proc(point: [2]f32) -> [2]i32 {
    return {  i32(point.x / f32(grid_size.x)), i32(point.y / f32(grid_size.y)) }
}

tiles_point_overlaps_tile :: #force_inline proc(pixel: [2]f32) -> (int, bool) {
    cell := tile_grid_cell_from_point(pixel)
    index, found := slice.linear_search(tile_positions[:], cell) 
    return index, found
}

tiles_any_point_overlap_tiles :: proc(pixels: [][2]f32) -> bool {
    for p in pixels {
        index, overlap := tiles_point_overlaps_tile(p)
        if overlap do return true
    }
    return false
}

tile_right_id :: proc(tile_id: int) -> f32 {
    return f32(tile_positions[tile_id].x + 1) * grid_size.x
}

tile_right_pos :: proc(pos: [2]i32) -> f32 {
    return f32(pos.x + 1) * grid_size.x
}

tile_right :: proc { tile_right_id, tile_right_pos }

tile_left_id :: proc(tile_id: int) -> f32 {
    return f32(tile_positions[tile_id].x) * grid_size.x
}

tile_left_pos :: proc(pos: [2]i32) -> f32 {
    return f32(pos.x) * grid_size.x
}

tile_left :: proc { tile_left_id, tile_left_pos }

// returns the top pixel of the tile
tile_top_id :: proc(tile_id: int) -> f32 {
    return f32(tile_positions[tile_id].y) * grid_size.y
}

tile_top_pos :: proc(pos: [2]i32) -> f32 {
    return f32(pos.y) * grid_size.y
}

tile_top :: proc { tile_top_id, tile_top_pos }

tile_bottom_id :: proc(tile_id: int) -> f32 {
    return f32(tile_positions[tile_id].y + 1) * grid_size.y
}

tile_bottom_pos :: proc(pos: [2]i32) -> f32 {
    return f32(pos.y + 1) * grid_size.y
}

tile_bottom :: proc { tile_bottom_id, tile_bottom_pos }