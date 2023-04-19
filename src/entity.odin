package edgy_man

Entity :: union {
    Player,
}

entity_update :: proc(entity: ^Entity) {
    switch in entity^ {
        case Player:
            player_update(&entity.(Player))
    }
}

entity_draw :: proc(entity: ^Entity) {
    switch in entity^ {
        case Player:
            player_draw(&entity.(Player))
    }
}