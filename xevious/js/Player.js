// -*- coding: utf-8 -*-

// player class
Player = function( main, wx, wy, name ) {
    var main = main;
    var game = main.game;
    // コンストラクタ
    this.x = wx;
    this.y = wy;
    this.obj = game.add.sprite( wx, wy, name);
    main.group3.add(this.obj);
    this.state = Normal.getInstance( this.obj );
    this.game = game;
    this.speed_x = 0; // x スピード
    this.speed_y = 0; // y スピード
    this.accel = 0.20; // 加速
    this.decel = 0.05; // 減速
};

Player.prototype.update = function() {
    this.state = this.state.update(this);
};

Player.prototype.kill = function() {
    this.obj.kill();
};

// my.game.input.gamepad.supported;
// my.game.input.gamepad.active;
// pad.connected
// pad._axes[0]);
// pad._rawPad.axes[0]);
// if ( pad.isDown(Phaser.Gamepad.XBOX360_DPAD_LEFT) || pad.axis(Phaser.Gamepad.XBOX360_STICK_LEFT_X) < -0.1 ) {
//     my.obj.x -= my.obj.speed;
// }
// else if( pad.isDown(Phaser.Gamepad.XBOX360_DPAD_RIGHT) ){
//     my.obj.x += my.obj.speed;
// }
// if ( pad.isDown(Phaser.Gamepad.XBOX360_DPAD_UP) ){
//     my.obj.y -= my.obj.speed;
// }
// else if (pad.isDown(Phaser.Gamepad.XBOX360_DPAD_DOWN) ){
//     my.obj.y += my.obj.speed;
// }

var Normal = ( function(){
    var instance;
    function init() {
        return {
            // public method
            update: function(my) {
                var pad = my.game.input.gamepad.pad1;
                console.log(pad.connected);
                my.y -= 0.25; // スクロールと同じ速度で飛ぶ。

                // x減速
                if( my.speed_x < 0 ) {
                    my.speed_x += my.decel;
                    if( my.speed_x > 0 ) my.speed_x = 0;
                }
                else if( my.speed_x > 0){
                    my.speed_x -= my.decel;
                    if( my.speed_x < 0 ) my.speed_x = 0;
                }
                // y減速
                if( my.speed_y < 0 ) {
                    my.speed_y += my.decel;
                    if( my.speed_y > 0 ) my.speed_y = 0;
                }
                else if( my.speed_y > 0){
                    my.speed_y -= my.decel;
                    if( my.speed_y < 0 ) my.speed_y = 0;
                }
                
                key = my.game.input.keyboard;
                if (key.isDown(Phaser.Keyboard.LEFT) ) {
                    my.speed_x -= my.accel;
                }
                else if (key.isDown(Phaser.Keyboard.RIGHT) ) {
                    my.speed_x += my.accel;
                }
                if (key.isDown(Phaser.Keyboard.UP) ) {
                    my.speed_y -= my.accel;
                }
                else if (key.isDown(Phaser.Keyboard.DOWN) ) {
                    my.speed_y += my.accel;
                }

                // game pad
                var px = pad.axis(Phaser.Gamepad.AXIS_0);
                var py = pad.axis(Phaser.Gamepad.AXIS_1);
                my.speed_x += (my.accel * px);
                my.speed_y += (my.accel * py);
                // if ( pad.axis(Phaser.Gamepad.AXIS_0) == -1 ) {
                //     my.speed_x -= my.accel;
                // }
                // else if ( pad.axis(Phaser.Gamepad.AXIS_0) == 1 ) {
                //     my.speed_x += my.accel;
                // }
                // if ( pad.axis(Phaser.Gamepad.AXIS_1) == -1 ) {
                //     my.speed_y -= my.accel;
                // }
                // else if ( pad.axis(Phaser.Gamepad.AXIS_1) == 1 ) {
                //     my.speed_y += my.accel;
                // }

                
                // 最大速度制限
                if( my.spped_x > 5 ) {
                    my.speed_x = 5;
                }
                else if( my.speed_x < -5){
                    my.speed_x = -5;
                }
                if( my.spped_y > 5 ) {
                    my.speed_y = 5;
                }
                else if( my.speed_y < -5){
                    my.speed_y = -5;
                }

                // 進む
                my.x += my.speed_x;
                my.y += my.speed_y;
                // オブジェクトに反映
                my.obj.x = Math.floor(my.x);
                my.obj.y = Math.floor(my.y);
                return my.state;
            }
        };
    }
    return {
        getInstance: function() {
            if (!instance) {
                instance = init();
            }
            return instance;
        }
    };
})();

