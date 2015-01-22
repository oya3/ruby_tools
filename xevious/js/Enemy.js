// -*- coding: utf-8 -*-

// 敵クラス
Enemy = function( game, tableinfo ) {
    // コンストラクタ
    this.enemy = game.add.sprite( tableinfo.x, tableinfo.y, tableinfo.name );
    this.enemy.animations.add('run');
    this.enemy.animations.play('run', 15, true);
    this.state = MoveLeft.getInstance( this.enemy );
}

Enemy.prototype.update = function() {
    this.state = this.state.update(this.enemy);
}

Enemy.prototype.kill = function() {
    this.enemy.kill();
}

var MoveLeft = ( function(){
    var instance;
    function init() {
        return {
            // public method
            update: function(obj) {
                obj.x -= 1;
                state = this;
                if ( obj.x < 10 ) {
                    state = MoveRight.getInstance();
                }
                return state;
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

var MoveRight = ( function(){
    var instance;
    function init() {
        return {
            // public method
            update: function(obj) {
                obj.x += 1;
                state = this;
                if ( obj.x > 200 ) {
                    state = MoveLeft.getInstance();
                }
                return state;
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
