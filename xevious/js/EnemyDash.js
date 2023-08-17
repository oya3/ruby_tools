// -*- coding: utf-8 -*-

// 敵クラス(突っ込んでくる敵)
EnemyDash = function( main, wx, wy, name, target ) {
    var game = main.game;
    // コンストラクタ
    this.obj = game.add.sprite( wx, wx, name);
    main.group4.add(this.obj);
    this.obj.animations.add('run');
    this.obj.animations.play('run', 15, true);
    this.state = Searching.getInstance( this );

    this.target = target;
    this.wait = Math.floor((60*1) * (Math.random() * 3)); // n秒待
    this.div_speed = 20 + (Math.random() * 10);
    this.tx = 0;
    this.ty = 0;
    this.x = wx;
    this.y = wy;
}

EnemyDash.prototype.update = function() {
    this.state = this.state.update(this);
}

EnemyDash.prototype.kill = function() {
    this.obj.kill();
}

// 一定期間待ってターゲットを捕捉
var Searching = ( function(){
    var instance;
    function init() {
        return {
            // public method
            update: function(my) {
                my.wait -= 1;
                if( my.wait <= 0 ) {
                    // 目標捕捉
                    my.tx = my.target.x;
                    my.ty = my.target.y;
                    return  Dash.getInstance( this );
                }
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


var Dash = ( function(){
    var instance;
    function init() {
        return {
            // public method
            update: function(my) {
                tx = my.tx - my.x;
                ty = my.ty - my.y;
                ax = (tx / my.div_speed);
                ay = (ty / my.div_speed);
                my.x += ax;
                my.y += ay;
                my.obj.x = Math.floor(my.x)
                my.obj.y = Math.floor(my.y)
                // 目標に到達？
                // if( (Math.floor(my.x) == Math.floor(my.tx)) && (Math.floor(my.y) == Math.floor(my.ty)) ) {
                if( (Math.abs(tx) <= 0.01) && (Math.abs(ty) <= 0.01) ){
                    my.wait = Math.floor((60*1) * (Math.random() * 3)); // n秒待
                    return Searching.getInstance( this );
                }
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

