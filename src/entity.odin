package edgy_man

Entity :: union {
    Player,
    Tile,
}

entity_update :: proc(entity: ^Entity) {
    switch in entity^ {
        case Player:
            player_update(&entity.(Player))
        case Tile:
            break
    }
}

entity_draw :: proc(entity: ^Entity) {
    switch in entity^ {
        case Player:
            player_draw(&entity.(Player))
        case Tile:
            tile_render(&entity.(Tile))
    }
}