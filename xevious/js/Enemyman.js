// -*- coding: utf-8 -*-

// 敵クラス
Enemyman = function( game, wx, wy, name, target ) {
    // コンストラクタ
    this.obj = game.add.sprite( wx, wy, name );
    this.obj.animations.add('run');
    this.obj.animations.play('run', 10 + Math.random() * 10, true);
    this.target = target
    this.x = wx;
    this.y = wy;
    this.radian = 0; // 今の向き
    this.time = 5*60; // おねむ時間
    this.accel = 0;
    this.radian = Math.atan2((this.target.y - this.y), (this.target.x - this.x)); // 初回の向き
    this.radian_speed = Math.random() / 10;
    this.state = Sleeping.getInstance( this.obj );
}

Enemyman.prototype.update = function() {
    this.state = this.state.update(this);
}

Enemyman.prototype.kill = function() {
    this.obj.kill();
}


var Sleeping = ( function(){
    var instance;
    function init() {
        return {
            // public method
            update: function(my) {
                my.accel -= 0.02;
                if( my.accel < 0 ) {
                    my.accel = 0;
                }
                my.x += Math.cos(my.radian) * my.accel;
                my.y += Math.sin(my.radian) * my.accel;
                my.obj.x = Math.floor(my.x)
                my.obj.y = Math.floor(my.y)

                my.time -= 1;
                if( my.time == 0 ) {
                    my.time = 5*60; // 追跡時間
                    return Tracking.getInstance( this.obj );
                }
                return my.state;
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


var Tracking = ( function(){
    var instance;
    function init() {
        return {
            // public method
            update: function(my) {
                // target を追尾する。
                my.accel += 0.02;
                // 最大速度制限
                if( my.accel > 1.5 ) {
                    my.accel = 1.5;
                }
                target_radian = Math.atan2((my.target.y - my.y), (my.target.x - my.x));
                delta = target_radian - my.radian;
                if (delta > Math.PI) delta -= Math.PI * 2;
                if (delta < -Math.PI) delta += Math.PI * 2;
                if (delta > 0) { // turn clockwise
                    my.radian += my.radian_speed;
                } else { // turn counter-clockwise
                    my.radian -= my.radian_speed;
                }
                my.x += Math.cos(my.radian) * my.accel;
                my.y += Math.sin(my.radian) * my.accel;
                my.obj.x = Math.floor(my.x)
                my.obj.y = Math.floor(my.y)
                
                my.time -= 1;
                if( my.time == 0 ) {
                    my.time = 1 + Math.floor((2*60) * Math.random()); // オネム時間
                    return Sleeping.getInstance( this.obj );
                }
                return my.state;
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

