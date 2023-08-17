// -*- coding: utf-8 -*-

// キャラクターマネージャ
CharacterManager = function( main ) {
    this.main = main;
    // ゲーム本体
    this.game = main.game;
    // キャラクター群
    this.characters = new Array();
    // キャラクターのファクトリー
    this.characterfactory = new CharacterFactory( main );
};

CharacterManager.prototype.add = function( tableinfo ) {
    // ここをファクトリーで生成するようにしたい！！
    var character = this.characterfactory.create( tableinfo );
    this.characters.push( character );
};

CharacterManager.prototype.addother = function( target ) {
    // 外部オブジェクトを無理くり登録
    this.characters.push( target );
};

CharacterManager.prototype.update = function() {
    // キャラクター群を更新する
    for (var i=0; i<this.characters.length; i++){
        this.characters[i].update();
    }
};
