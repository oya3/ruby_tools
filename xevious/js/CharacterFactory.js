// -*- coding: utf-8 -*-

// キャラクターマネージャ
CharacterFactory= function( main ) {
    this.main = main;
    // ゲーム本体
    this.game = main.game;
};

CharacterFactory.prototype.create = function( tableinfo ) {
    var character;
    character = new Enemy( this.main, tableinfo );
    // character = new Enemy( this.game, tableinfo.x, tableinfo.y, tableinfo.name );
    return character;
};
