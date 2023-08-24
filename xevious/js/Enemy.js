// -*- coding: utf-8 -*-

// 敵クラス(地上を歩く)
Enemy = function( main, tableinfo ) {
    var game = main.game;
    // コンストラクタ
    this.obj = game.add.sprite( tableinfo.x, tableinfo.y, tableinfo.spritename );
    main.group1.add(this.obj);
    this.obj.animations.add('run');
    this.obj.animations.play('run', 15, true);
    this.state = MoveLeft.getInstance( this.obj );
};

Enemy.prototype.update = function() {
    this.state = this.state.update(this.obj);
};

Enemy.prototype.kill = function() {
    this.obj.kill();
};

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
