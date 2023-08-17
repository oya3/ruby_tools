// -*- coding: utf-8 -*-

// 敵クラス(サインカーブの揺れでくる敵)
EnemySinWave = function( main, wx, wy, name ) {
    var game = main.game;
    // コンストラクタ
    this.obj = game.add.sprite( wx, wx, name);
    main.group4.add(this.obj);
    this.obj.animations.add('run');
    this.obj.animations.play('run', 15, true);
    this.state = SinWave.getInstance( this.obj );
    
    this.radian = Math.random() * (Math.PI * 1.0);
    this.center = wx;
    this.scale = 30 + Math.random() * 20;
    this.wave_speed = 0.02 + Math.random() / 30
    this.x = wx;
    this.y = wy;
}

EnemySinWave.prototype.update = function() {
    this.state = this.state.update(this);
}

EnemySinWave.prototype.kill = function() {
    this.obj.kill();
}

//角度（degree）→ラジアン（radian）に変換
//radian = Math.PI/180 * degree
//
//◆ラジアン（radian）→角度（degree）に変換
//degree = radian / (Math.PI/180)
//
// ラジアンとは、半径１の円弧の長さをもとにした単位みたいです。
// つまり半径１の円周は、直径×3.14・・・ですので、2πとなります。
// これを基に、　360°= 2π　　180°= π　　90°= π/2　　60°= π/3　　30°= π/6　　・・・　　1°= π/180　　
// という風に角度とラジアンが対応
var SinWave = ( function(){
    var instance;
    function init() {
        return {
            // public method
            update: function(my) {
                my.y += 0.25;
                my.radian += 0.05;
                my.x = my.center + (my.scale * Math.sin(my.radian % (Math.PI * 2)))
                my.obj.x = Math.floor(my.x)
                my.obj.y = Math.floor(my.y)
                
                return my.state
            }
        }
    };  
    return {
        getInstance: function() {
            if (!instance) {
                instance = init();
            }
            return instance;
        }
    };
})();

