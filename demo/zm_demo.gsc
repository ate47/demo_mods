#using scripts\core_common\values_shared;
#using scripts\core_common\system_shared;
#using scripts\core_common\callbacks_shared;
#using scripts\core_common\util_shared;
#using scripts\core_common\array_shared;
#using scripts\core_common\clientfield_shared;
#using scripts\atian_mods\acts_shared_ui;

#namespace zm_demo;


function autoexec __init__system__() {
    system::register("zm_demo", &__init__, &__main__);
}

function __init__() {
    callback::on_spawned(&on_player_spawned);

    // Menu (start_menu)
    // - Menu 2 (menu_2)
    //   - Function 1
    //   - Function 2
    // - Menu 3 (menu_3)
    //   - Function 3

    acts_shared_ui::on_register_menu(function () {
        self acts_shared_ui::add_menu("menu_2", "Menu 2", "start_menu", true);

        self acts_shared_ui::add_menu_item("menu_2", "Function 1", &my_function_1);
        self acts_shared_ui::add_menu_item("menu_2", "Function 2", &my_function_2, 55);

        self acts_shared_ui::add_menu("menu_3", "Menu 3", "start_menu", true);
        
        self acts_shared_ui::add_menu_item("menu_3", "Function 3", &my_function_3);
    });
}

function __main__() {
    
}

function my_function_1(item) {
    self iprintlnbold("Hello from function 1");
}

function my_function_2(item, my_value) {
    self iprintlnbold("Hello from function 2 " + my_value);
}

function my_function_3(item) {
    self iprintlnbold("Hello from function 3");
}

function on_player_spawned() {
    level endon(#"end_game", #"game_ended");
    self endon(#"disconnect", #"spawned_player");

    wait 1;

    self val::set(#"zm_demo_lazy", "ignoreme", true);

    self.dqzzdzqdqzd = 2;
    
    if (1 + self.dqzzdzqdqzd) {
        self iprintlnbold("ok !");
    }

    while (true) {
        self.score = 42000;

        // https://github.com/ate47/t8-atian-menu/blob/master/scripts/core_common/key_mgr.gsc#L146

/*
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
*/

        waitframe(1);
    }

}

