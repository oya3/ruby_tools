// -*- coding: utf-8 -*-

// キャラクターマネージャ
CharacterFactory= function( game ) {
    // ゲーム本体
    this.game = game;
}

CharacterFactory.prototype.create = function( tableinfo ) {
    var character;
    character = new Enemy( this.game, tableinfo );
    // character = new Enemy( this.game, tableinfo.x, tableinfo.y, tableinfo.name );
    return character;
}
