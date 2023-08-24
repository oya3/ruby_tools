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
  // TODO: スプライト単位に当たり判定を実施するので、characters[] を返すようにするべき
  // var character = this.characterfactory.create( tableinfo );
  // this.characters.push( character );
  switch (tableinfo.name) {
  case 'hunter':
    // 追跡
    for(i=0;i<50;i++){
      // enemyman = new Enemyman( this.main, this.game.world.width/2 - 100 + Math.random() * 200 - 8, this.game.world.height - 200, 'toroid', this.main.player );
      enemyman = new Enemyman( this.main, this.game.world.width/2 - 100 + (Math.random() * 200) - 8, tableinfo.y, 'toroid', this.main.player );
      this.characters.push( enemyman );
    }
    break;
  case 'curver':
    // サインカーブ
    for(i=0;i<50;i++){
      // enemy = new EnemySinWave( this.main, this.game.world.width/2 - 100 + Math.random() * 200 - 8, this.game.world.height - 400 - (Math.random() * 100), 'toroid');
      enemy = new EnemySinWave( this.main, this.game.world.width/2 - 100 + Math.random() * 200 - 8, tableinfo.y, 'toroid');
      this.characters.push( enemy );
    }
    break;
  case 'dash':
    // ダッシュ
    for(i=0;i<50;i++){
      // enemy = new EnemyDash( this.main, this.game.world.width/2 - 100 + Math.random() * 200 - 8, this.game.world.height - 400 - (Math.random() * 100), 'toroid', this.main.player );
      enemy = new EnemyDash( this.main, this.game.world.width/2 - 100 + Math.random() * 200 - 8, tableinfo.y, 'toroid', this.main.player );
      this.characters.push( enemy );
    }
    break;
  case 'toroid':
    enemy = new Enemy( this.main, tableinfo );
    this.characters.push( enemy );
    break;
  case 'zako':
    enemy = new Enemy( this.main, tableinfo );
    this.characters.push( enemy );
    break;
  }
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
