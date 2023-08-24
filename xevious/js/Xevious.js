// -*- coding: utf-8 -*-

// --- グローバル変数 ---
var game;
var main;
var gameWidth = 224;
var gameHeight =360;

// ---------------------------------------------------------------------------------
// ＮＳゼビウス
NsXevious = function() {
    // コンストラクタ
    this.touch = { x: 0, y: 0, sx: 0, sy: 0 };
    this.group1;
    this.group2;
    this.group3;
    this.group4;
    this.game;
    // Jsonファイルを読み込み
    $.getJSON( "assets/tilemaps/maps/xevious.json", { width: 800, height:600 }, game_start );
};

NsXevious.prototype.preload = function() {
    // マップ情報
    // スーパーマリオ
    // this.game.load.tilemap('mario', 'assets/tilemaps/maps/super_mario.json', null, Phaser.Tilemap.TILED_JSON);
    // this.game.load.image('tiles', 'assets/tilemaps/tiles/super_mario.png');
    
    // ゼビウス
    this.game.load.tilemap('xevious', 'assets/tilemaps/maps/xevious.json', null, Phaser.Tilemap.TILED_JSON);
    this.game.load.image('xevious_tiles', 'assets/tilemaps/tiles/xevious.png');
    
    // とりあえずのキャラ
    // game.load.image('player', 'assets/sprites/phaser-dude.png');
    this.game.load.spritesheet('baddie_cat', 'assets/sprites/baddie_cat_1.png',16, 16, 4 );
    this.game.load.spritesheet('toroid', 'assets/sprites/toroid.png', 16, 16, 8 );
    
    // 自機
    this.game.load.spritesheet('player', 'assets/sprites/shmup-ship.png', 16, 16, 1 );
    // this.game.load.image('toroid', 'assets/sprites/toroid.png');
    
    // キャラクター情報を読み込み
    this.game.load.json('character_info', 'assets/tilemaps/maps/character_info.json');
    
    // ゲームパッド開始
    this.game.input.gamepad.start();
    // 上下左右の方法キー
    //this.cursors = this.game.input.keyboard.createCursorKeys();

    // タッチイベントのリスン
    // this.game.input.addPointer();
    this.game.input.onDown.add(this.onTouchStart, this);
    this.game.input.addMoveCallback(this.onTouchMove, this);
    this.game.input.onUp.add(this.onTouchEnd, this);
};

NsXevious.prototype.create = function() {
    // マップを生成
    // this.map = new SuperMarioMap( this.game );
    this.map = new XeviousMap( this.game );

    // 表示優先グループを作成
    this.group1 = new Phaser.Group(this.game); // 地上
    this.group2 = new Phaser.Group(this.game); // 低空
    this.group3 = new Phaser.Group(this.game); // player
    this.group4 = new Phaser.Group(this.game); // 高空

    this.game.world.bringToTop(this.group1);
    this.game.world.bringToTop(this.group2);
    this.game.world.bringToTop(this.group3);
    this.game.world.bringToTop(this.group4);

    
    // イベントマネージャを生成
    this.eventmanager = new EventManager( this.game );
    // キャラクター情報をセット
    this.charactermanager = new CharacterManager( this );
    var characterinfo = this.game.cache.getJSON('character_info');
    this.eventmanager.setCharacter( this.charactermanager, characterinfo );

    // 無理くり自機を登録
    this.player = new Player( this, this.game.world.width/2, this.game.world.height - 16, 'player' );
    this.charactermanager.addother( this.player );
    
    // レンダリング時のスケーリング
    this.game.scale.scaleMode = Phaser.ScaleManager.SHOW_ALL;
    this.game.scale.setResizeCallback(this.gameResized, this);
    this.game.scale.refresh();
    // this.gameResized(); // 初回のリサイズ処理を呼び出す <-- これできない。。。refresh()で対応しておく
};

NsXevious.prototype.gameResized = function() {
  var scaleRatio = Math.min(window.innerWidth / gameWidth, window.innerHeight / gameHeight);
  this.game.scale.setUserScale(scaleRatio, scaleRatio);
  this.game.canvas.style.marginTop = (window.innerHeight - this.game.height * scaleRatio) / 2 + 'px';
};

NsXevious.prototype.update = function() {
    // マップを更新
    this.map.update();
    // イベントを更新
    this.eventmanager.update();
    // キャラクターを更新
    this.charactermanager.update();
};

NsXevious.prototype.render = function() {
    // デバッグ用
    // カメラ情報
    this.game.debug.cameraInfo( this.game.camera, 240, 280 );
    // gemapad
    this.game.debug.text( this.game.input.gamepad.pad1.connected, 240, 100 );
};

NsXevious.prototype.onTouchStart = function(pointer) {
  // タッチ開始時の処理
  // console.log("onTouchStart {}",pointer);
  this.touch.is_start = true;
  this.touch.sx = pointer.position.x;
  this.touch.sy = pointer.position.y;
  this.touch.pad = 0;
  // this.touch.sx = y;
};

NsXevious.prototype.abs = function(val) {
  return val < 0 ? -val : val;
};

NsXevious.prototype.onTouchMove = function(pointer, x, y) {
  // タッチ移動時の処理
  if(this.touch.is_start === false){
    return;
  }
  this.touch.pad = 0;
  var sub_x = x - this.touch.sx;
  var sub_y = y - this.touch.sy;
  if(this.abs(sub_x) > 10){
    if(sub_x < 0){
      this.touch.pad |= 0x01;
    }else{
      this.touch.pad |= 0x02;
    }
  }
  if(this.abs(sub_y) > 10){
    if(sub_y < 0){
      this.touch.pad |= 0x10;
    }else{
      this.touch.pad |= 0x20;
    }
  }
};
NsXevious.prototype.onTouchEnd = function(pointer) {
  // タッチ終了時の処理
  // console.log("onTouchEnd");
  this.touch.is_start = false;
  this.touch.pad = 0;
};

// ---------------------------------------------------------------------------------
// 矩形の衝突判定
function collision_detection( a, b ) {
    // 対象：a
    var X0 = a.x;
    var Y0 = a.y;
    var X1 = X0 + a.width;
    var Y1 = Y0 + a.height;
    // 対象：b
    var X2 = b.x;
    var Y2 = b.y;
    var X3 = X2 + b.width;
    var Y3 = Y2 + b.height;
    // 矩形の衝突判定
    if( X0 < X3 && X2 < X1 && Y0 < Y3 && Y2 < Y1 ) {
        return true;
    }
    return false;
}

// ---------------------------------------------------------------------------------
function game_start( initdata ) {
  // ゲーム本体を生成する
  // サイズはinitdataから取得
  var width = initdata.width * initdata.tilewidth;
  var height = initdata.height * initdata.tileheight;
  width = 600;
  height = 360;
  main.game = new Phaser.Game(
    gameWidth,
    gameHeight,
    Phaser.CANVAS,
    'ns-xevious',
    main
  );
}

// ---------------------------------------------------------------------------------
// メイン処理を生成
main = new NsXevious();
