// -*- coding: utf-8 -*-

// イベントマネージャ
EventManager = function( game ) {
    // ゲーム本体
    this.game = game;
};

EventManager.prototype.setCharacter = function( manager, table ) {
    // キャラクター情報をセット
    this.charactermanager = manager;
    this.charactertable = table;
};

EventManager.prototype.update = function() {
    // キャラクター情報のチェック
    if ( typeof this.charactermanager !== 'undefined' ) {
        this.checkCharacter();
    }
};

EventManager.prototype.checkCharacter = function() {
    // テーブルがなければチェックしない
    if ( typeof this.charactertable === 'undefined' ) {
        return;
    }
    // キャラクター情報をチェックする
    for (var i=0; i<this.charactertable.length; i++){
        // 実行チェック
        if ( this.is_execute( this.charactertable[i] ) ) {
            // キャラクターを追加
            this.charactermanager.add( this.charactertable[i] );
            // 追加したキャラクター情報は削除する
            this.charactertable.splice( i, 1 );
        }
    }
};

// 画面範囲内かどうかの判定
EventManager.prototype.is_execute = function( tableinfo ) {
    // 画面の範囲
    var X0 = this.game.camera.x;
    var Y0 = this.game.camera.y;
    var X1 = X0 + this.game.camera.width;
    var Y1 = Y0 + this.game.camera.height;
    // 対象：b
    var X2 = tableinfo.x;
    var Y2 = tableinfo.y;
    var X3 = X2;
    var Y3 = Y2;
    // 矩形の衝突判定
    if( X0 < X3 && X2 < X1 && Y0 < Y3 && Y2 < Y1 ) {
        return true;
    }
    return false;
};
