// -*- coding: utf-8 -*-

// マップクラス
SuperMarioMap= function( game ) {
    // ゲーム本体
    this.game = game;
    
    // スーパーマリオのマップを生成
    this.tilemap = game.add.tilemap('mario');
    this.tilemap.addTilesetImage('SuperMarioBros-World1-1', 'tiles');
    this.layer = this.tilemap.createLayer('World1');
    // worldサイズをリサイズ
    this.layer.resizeWorld();
    
    // カメラ位置を左上にしておく
    // this.game.camera.setPosition( 0, 0 );
    this.game.camera.setPosition( 0, this.game.world.height - this.game.camera.height );
}

SuperMarioMap.prototype.update = function() {
    // 横スクロール
    this.game.camera.y -= 1;
}
