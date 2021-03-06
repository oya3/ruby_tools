// -*- coding: utf-8 -*-

// --- グローバル変数 ---
var game;
var main;

// ---------------------------------------------------------------------------------
// ＮＳゼビウス
NsXevious = function() {
    // コンストラクタ
    this.game;
    // Jsonファイルを読み込み
    $.getJSON( "assets/tilemaps/maps/xevious.json", { width: 800, height:600 }, game_start );
}

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
    this.game.load.spritesheet('enemy', 'assets/sprites/baddie_cat_1.png',16, 16, 4 );
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

}

NsXevious.prototype.create = function() {
    // マップを生成
    // this.map = new SuperMarioMap( this.game );
    this.map = new XeviousMap( this.game );
    
    // イベントマネージャを生成
    this.eventmanager = new EventManager( this.game );
    // キャラクター情報をセット
    this.charactermanager = new CharacterManager( this.game );
    var characterinfo = this.game.cache.getJSON('character_info');
    this.eventmanager.setCharacter( this.charactermanager, characterinfo );

    // 無理くり自機を登録
    this.player = new Player( this.game, this.game.world.width/2, this.game.world.height - 16, 'player' )
    this.charactermanager.addother( this.player )
    
    // 無理くり敵を登録
    // 追跡
    for(i=0;i<2000;i++){
        enemyman = new Enemyman( this.game, this.game.world.width/2 - 100 + Math.random() * 200 - 8, this.game.world.height - 200, 'toroid', this.player )
        this.charactermanager.addother( enemyman )
    }
    // サインカーブ
    for(i=0;i<100;i++){
        enemy = new EnemySinWave( this.game, this.game.world.width/2 - 100 + Math.random() * 200 - 8, this.game.world.height - 400 - (Math.random() * 100), 'toroid')
        this.charactermanager.addother( enemy )
    }
    // ダッシュ
    for(i=0;i<300;i++){
        enemy = new EnemyDash( this.game, this.game.world.width/2 - 100 + Math.random() * 200 - 8, this.game.world.height - 400 - (Math.random() * 100), 'toroid', this.player )
        this.charactermanager.addother( enemy )
    }
}

NsXevious.prototype.update = function() {
    // マップを更新
    this.map.update();
    // イベントを更新
    this.eventmanager.update();
    // キャラクターを更新
    this.charactermanager.update();
}

NsXevious.prototype.render = function() {
    // デバッグ用
    // カメラ情報
    this.game.debug.cameraInfo( this.game.camera, 240, 280 );
    // gemapad
    this.game.debug.text( this.game.input.gamepad.pad1.connected, 240, 100 );
}

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
        width,
        height,
        Phaser.CANVAS,
        'ns-xevious',
        main
    );
}

// ---------------------------------------------------------------------------------
// メイン処理を生成
main = new NsXevious();
