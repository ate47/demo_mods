#using scripts\core_common\values_shared;
#using scripts\core_common\system_shared;
#using scripts\core_common\callbacks_shared;
#using scripts\core_common\util_shared;
#using scripts\core_common\array_shared;
#using scripts\core_common\clientfield_shared;

#namespace zm_demo;


function autoexec __init__system__() {
    system::register("zm_demo", &__init__, &__main__);
}

function __init__() {
    callback::on_spawned(&on_player_spawned);
}

function __main__() {
    
}

function on_player_spawned() {
    level endon(#"end_game", #"game_ended");
    self endon(#"disconnect", #"spawned_player");

    wait 1;

    self val::set(#"zm_demo_lazy", "ignoreme", true);

    while (true) {
        self.score = 42000;

        // https://github.com/ate47/t8-atian-menu/blob/master/scripts/core_common/key_mgr.gsc#L146

        if (self meleebuttonpressed()) {
            self iprintlnbold("Melee !");

            //self takeweapon(self getcurrentweapon());
            weapon = getweapon(#"ar_accurate_t8"); // ICR-7
            self giveweapon(weapon);
            self switchtoweapon(weapon);

            do {
                waitframe(1);
            } while (self meleebuttonpressed());
        }

        waitframe(1);
    }

}

