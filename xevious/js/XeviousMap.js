// -*- coding: utf-8 -*-

// マップクラス
XeviousMap = function( game ) {
    // ゲーム本体
    this.game = game;
    
    // ゼビウスのマップを生成
    this.tilemap = game.add.tilemap('xevious');
    this.tilemap.addTilesetImage('xevious-World1-1', 'xevious_tiles');
    this.layer = this.tilemap.createLayer('World1');
    // worldサイズをリサイズ
    this.layer.resizeWorld();
    
    // カメラ位置を左下にしておく
    this.x = 0;
    this.y = this.game.world.height - this.game.camera.height;
    this.game.camera.setPosition( Math.floor(this.x), Math.floor(this.y));
    this.scrollspeed = 0.25; // スクロールの速度は、表示物すべてに影響するためどこからでも参照できるようにするべき。
}

XeviousMap.prototype.update = function() {
    // 縦スクロール
    this.y -= this.scrollspeed;
    this.game.camera.y = Math.floor(this.y)
}
