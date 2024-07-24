
#using scripts\core_common\array_shared;
#using scripts\core_common\callbacks_shared;
#using scripts\core_common\system_shared;

#namespace acts_shared_ui;

function autoexec __init__system__() {
    system::register(#"acts_shared_ui", &__init__, undefined);
}

function private __init__() {
    callback::on_spawned(&on_player_spawned);
}

function on_register_menu(func) {
    if (!isdefined(level.acts_shared_ui_callbacks)) {
        level.acts_shared_ui_callbacks = [];
    }

    array::add(level.acts_shared_ui_callbacks, func);
}

function private init_menu(menu_title) {
    if (isdefined(self.menu_info)) {
        // ignore menu creation if already set
        return false;
    }

    self.menu_info = 
    {
        #default_menu: "start_menu",
        #current_menu: "",
        #cursor: 0,
        #no_render: false,
        #menus: [],
        #mods: [],
    };

    self add_menu("start_menu", menu_title, "");

    if (isdefined(level.acts_shared_ui_callbacks)) {
        foreach (func in level.acts_shared_ui_callbacks) {
            self [[ func ]]();
        }
    }

    return true;
}

function menu_drawing_function(txt) {
#ifdef _T9
    if (sessionmodeiszombiesgame()) {
        self iprintlnbold(txt);
    } else {
        self iprintln(txt);
    }
#else
    self iprintln(txt);
#endif
}

function menu_drawing_secondary(txt) {
#ifdef _T9
    if (sessionmodeiszombiesgame()) {
        self iprintln(txt);
    } else {
        self iprintlnbold(txt);
    }
#else
    self iprintlnbold(txt);
#endif
}

function get_menu_size_count() {
#ifdef _T9
    if (sessionmodeiszombiesgame()) {
        return 5;
    } else {
        return 2;
    }
#endif
#ifdef _PC
    return 8;
#else
    return 3;
#endif
}

function toggle_mod(mod_name, value = undefined) {
    if (!isdefined(self.menu_info)) {
        return;
    }

    if (array::contains(self.menu_info.mods, mod_name)) {
        if (isdefined(value) && value) {
            return true;
        }
	    arrayremovevalue(self.menu_info.mods, mod_name);
        return false;
    } else {
        if (isdefined(value) && !value) {
            return false;
        }
        array::add(self.menu_info.mods, mod_name);
        return true;
    }
}

function is_mod_activated(mod_name) {
    return isdefined(self.menu_info) && isdefined(self.menu_info.mods) && array::contains(self.menu_info.mods, mod_name);
}

function add_menu(menu_id, menu_name, parent_id, create_switch = false, menuenterfunc = undefined, menuenterfuncdata1 = undefined, menuenterfuncdata2 = undefined, menuenterfuncdata3 = undefined, menuenterfuncdata4 = undefined) {
    menu = 
    {
        #id: menu_id,
        #cursor: 0,
        #name: menu_name,
        #parent_id: parent_id,
        #menu_enter_func: menuenterfunc,
        #menu_enter_func_data1 : menuenterfuncdata1,
        #menu_enter_func_data2 : menuenterfuncdata2,
        #menu_enter_func_data3 : menuenterfuncdata3,
        #menu_enter_func_data4 : menuenterfuncdata4,
        #sub_menus: [],
    };

    self.menu_info.menus[menu_id] = menu;
    
    if (create_switch) {
        self add_menu_item_menuswitch(parent_id, menu_name, menu_id);
    }
    return menu;
}
function add_menu_item(menu_id, item_name, action, actiondata = undefined, actiondata2 = undefined, actiondata3 = undefined, actiondata4 = undefined, actiondata5 = undefined) {
    if (!isdefined(self.menu_info.menus[menu_id])) {
        self menu_drawing_secondary("^1bad menu config " + menu_id + " isn't set!");
        return;
    }

    parent = self.menu_info.menus[menu_id];

    item = 
    {
        #name: item_name,
        #action: action,
        #activated: false,
        #action_data: actiondata,
        #action_data2: actiondata2,
        #action_data3: actiondata3,
        #action_data4: actiondata4,
        #action_data5: actiondata5
    };

    array::add(parent.sub_menus, item);
    return item;
}


function mod_switch(item, mod_name) {
    item.activated = toggle_mod(mod_name);
    return true;
}

function menu_switch(item, menu_id) {
    if (!isdefined(menu_id)) {
        menu_id = "";
    }
    self.menu_info.current_menu = menu_id;
    self.menu_info.cursor = 0;

    menu = self.menu_info.menus[menu_id];

    if (isdefined(menu) && isdefined(menu.menu_enter_func)) {
        if (isdefined(menu.menu_enter_func_data4)) {
            self [[ menu.menu_enter_func ]](menu, menu.menu_enter_func_data1, menu.menu_enter_func_data2, menu.menu_enter_func_data3, menu.menu_enter_func_data4);
        } else if (isdefined(menu.menu_enter_func_data3)) {
            self [[ menu.menu_enter_func ]](menu, menu.menu_enter_func_data1, menu.menu_enter_func_data2, menu.menu_enter_func_data3);
        } else if (isdefined(menu.menu_enter_func_data2)) {
            self [[ menu.menu_enter_func ]](menu, menu.menu_enter_func_data1, menu.menu_enter_func_data2);
        } else if (isdefined(menu.menu_enter_func_data1)) {
            self [[ menu.menu_enter_func ]](menu, menu.menu_enter_func_data1);
        } else {
            self [[ menu.menu_enter_func ]](menu);
        }
    }
    
    return true;
}

function add_menu_item_menuswitch(menu_id, item_name, new_menu_id) {
    self add_menu_item(menu_id, item_name, &menu_switch, new_menu_id);
}

function add_menu_item_modswitch(menu_id, item_name, mod_name) {
    self add_menu_item(menu_id, item_name, &mod_switch, mod_name);
}

function get_current_menu() {
    return self.menu_info.menus[self.menu_info.current_menu];
}

function private menu_think() {
    if (!isdefined(self.menu_info)) {
        return;
    }
    
    menu_size_count = get_menu_size_count();

    for (i = 0; i < menu_size_count + 1; i++) {
        self menu_drawing_function("");
    }

    ts = 0;
    while (true) {
        menu_info = self.menu_info;

        if (menu_info.current_menu !== "" && !isdefined(menu_info.menus[menu_info.current_menu])) {
            menu_info.current_menu = "";
        }

        render = false;
        if (menu_info.current_menu == "") {
            // out menu
            if (self key_mgr_has_key_pressed(#"open_menu", true)) {
                menu_info.current_menu = menu_info.default_menu;
                self.menu_info.cursor = 0;
                render = true;
            } else {
                waitframe(1);
                continue;
            }
        } else if (self key_mgr_has_key_pressed(#"parent_page", true)) {
            // back
            menu = self get_current_menu();
            if (!isdefined(menu)) {
                menu_info.current_menu = "";
            } else {
                menu_info.current_menu = menu.parent_id;
            }
            self.menu_info.cursor = 0;
            render = true;
        } else if (self key_mgr_has_key_pressed(#"last_item", true)) {
            // up arrow
            menu = self get_current_menu();
            if (isdefined(menu)) {
                //if (menu_info.cursor == 0) {
                //    menu_info.cursor = menu.sub_menus.size - 1;
                //} else {
                //    menu_info.cursor--;
                //}
                if (menu.cursor == 0 || menu.cursor >= menu.sub_menus.size) {
                    menu.cursor = menu.sub_menus.size - 1;
                } else {
                    menu.cursor--;
                }
                render = true;
            }
        } else if (self key_mgr_has_key_pressed(#"next_item", true)) {
            // bottom arrow
            menu = self get_current_menu();
            if (isdefined(menu)) {
                //if (menu_info.cursor < menu.sub_menus.size - 1) {
                //    menu_info.cursor++;
                //} else {
                //    menu_info.cursor = 0;
                //}
                if (menu.cursor < menu.sub_menus.size - 1) {
                    menu.cursor++;
                } else {
                    menu.cursor = 0;
                }
                render = true;
            }
        } else if (self key_mgr_has_key_pressed(#"select_item", true)) {
            // use
            menu = self get_current_menu();
            if (isdefined(menu)) {
                //item = menu.sub_menus[menu_info.cursor];
                item = menu.sub_menus[menu.cursor];
                if (isdefined(item)) {
                    if (isdefined(item.action)) {
                        if (isdefined(item.action_data5)) {
                            res = self [[ item.action ]](item, item.action_data, item.action_data2, item.action_data3, item.action_data4, item.action_data5);
                        } else if (isdefined(item.action_data4)) {
                            res = self [[ item.action ]](item, item.action_data, item.action_data2, item.action_data3, item.action_data4);
                        } else if (isdefined(item.action_data3)) {
                            res = self [[ item.action ]](item, item.action_data, item.action_data2, item.action_data3);
                        } else if (isdefined(item.action_data2)) {
                            res = self [[ item.action ]](item, item.action_data, item.action_data2);
                        } else if (isdefined(item.action_data)) {
                            res = self [[ item.action ]](item, item.action_data);
                        } else {
                            res = self [[ item.action ]](item);
                        }
                        if (isdefined(res) && !res) {
                            // close the menu at the end
                            menu_info.current_menu = "";
                        }
                    }
                } else {
                    // wtf?
                    menu_info.current_menu = "";
                }
                render = true;
            }
        } else {
            if (menu_info.current_menu != "") {
                nts = GetTime();
                
                if (nts > ts) {
                    ts = nts + 5000; // add 5s
                    render = true;
                } else {
                    waitframe(1);
                    continue;
                }
            } else {
                waitframe(1);
                continue;
            }
        }

        if (menu_info.no_render) {
            menu_info.no_render = false;
            waitframe(1);
            continue;
        }

        // render the menu
        if (render) {
            menu = self get_current_menu();
            if (isdefined(menu)) {
                if (menu.sub_menus.size === 0) {
                    self menu_drawing_function("^1---- " + menu.name + " (empty) ----");
                    index_end = 1;
                } else {
                    //page = int(menu_info.cursor / menu_size_count);
                    page = int(menu.cursor / menu_size_count);
                    maxpage = int((menu.sub_menus.size - 1) / menu_size_count) + 1;
                    self menu_drawing_function("^1---- " + menu.name + " (" + (page + 1) + "/" + maxpage + ") ----");

                    index_start = menu_size_count * page;
                    index_end = int(min(menu_size_count * (page + 1), menu.sub_menus.size));
                    for (i = index_start; i < index_end; i++) {
                        //if (menu_info.cursor === i) {
                        if (menu.cursor === i) {
                            if (menu.sub_menus[i].activated) {

                                self menu_drawing_function("^2-> ^1" + (menu.sub_menus[i].name) + "^0 (ON)");
                            } else {
                                self menu_drawing_function("^2-> ^1" + (menu.sub_menus[i].name));
                            }
                            
                        } else {
                            if (menu.sub_menus[i].activated) {
                                self menu_drawing_function("^1- " + (menu.sub_menus[i].name) + "^0 (ON)");
                            } else {
                                self menu_drawing_function("^1- " + (menu.sub_menus[i].name));
                            }
                        }
                    }
                }

                end_space = (menu_size_count - (index_end % menu_size_count));
                if (end_space !== menu_size_count) {
                    for (i = 0; i < end_space; i++) {
                        self menu_drawing_function("");
                    }
                }
            } else {
                for (i = 0; i < menu_size_count + 1; i++) {
                    self menu_drawing_function("");
                }
            }
        }

        waitframe(1);
    }
    
}

function click_menu_button(menu_id, menu_item_name) {
    menu = self.menu_info.menus[menu_id];
    if (isdefined(menu)) {
        menu_item_index = array::find(menu.sub_menus, menu_item_name, function (menu_item, menu_name) { return menu_item.name == menu_name; });
        if (isdefined(menu_item_index)) {
            item = menu.sub_menus[menu_item_index];
            if (isdefined(item.action)) {
                if (isdefined(item.action_data5)) {
                    self [[ item.action ]](item, item.action_data, item.action_data2, item.action_data3, item.action_data4, item.action_data5);
                } else if (isdefined(item.action_data4)) {
                    self [[ item.action ]](item, item.action_data, item.action_data2, item.action_data3, item.action_data4);
                } else if (isdefined(item.action_data3)) {
                    self [[ item.action ]](item, item.action_data, item.action_data2, item.action_data3);
                } else if (isdefined(item.action_data2)) {
                    self [[ item.action ]](item, item.action_data, item.action_data2);
                } else if (isdefined(item.action_data)) {
                    self [[ item.action ]](item, item.action_data);
                } else {
                    self [[ item.action ]](item);
                }
            }
        }
    }
}

function menu_open_message(menu, message, func, data1, data2) {
    if (isdefined(message)) {
        self menu_drawing_secondary(message);
    }

    if (!isdefined(func)) {
        return;
    }

    if (isdefined(data2)) {
        return [[ func ]](data1, data2);
    }

    if (isdefined(data1)) {
        return [[ func ]](data1);
    } 
    return [[ func ]]();
}

function private key_mgr_init() {
    if (isdefined(self.key_mgr)) {
        // ignore menu creation if already set
        return;
    }
    key_mgr = 
    {
        #key_config: {},
        #config: [],
        #valid: [ #"action", #"actionslotfour", #"actionslotone", #"actionslotthree", #"actionslottwo", #"ads", #"attack", 
            #"changeseat", #"frag", #"jump", #"melee", #"offhandspecial", #"reload", #"secondaryoffhand", #"sprint", 
            #"stance", #"throw", #"use", #"vehicleattack", #"vehiclemoveup", #"weaponswitch" ]
    };

    self.key_mgr = key_mgr;

    // load the config
    key_config = key_mgr.key_config;
    //key_config AtianMenuKeyConfig();

    self key_mgr_compile_key(#"open_menu", key_config.menu_open, [#"ads", #"melee"]);
    self key_mgr_compile_key(#"parent_page", key_config.parent_page, #"melee");
    self key_mgr_compile_key(#"last_item", key_config.last_item, #"ads");
    self key_mgr_compile_key(#"next_item", key_config.next_item, #"attack");
    self key_mgr_compile_key(#"select_item", key_config.select_item, #"use");
    self key_mgr_compile_key(#"fly_fast_key", key_config.fly_fast_key, #"sprint");
    self key_mgr_compile_key(#"fly_up_key", key_config.fly_up_key, #"jump");
    self key_mgr_compile_key(#"fly_down_key", key_config.fly_down_key, #"stance");
    self key_mgr_compile_key(#"special_weapon_primary", key_config.special_weapon_primary, #"attack");
    self key_mgr_compile_key(#"special_weapon_secondary", key_config.special_weapon_secondary, #"reload");
    self key_mgr_compile_key(#"special_weapon_ternary", key_config.special_weapon_ternary, #"use");
}

function private key_mgr_is_valid(key) {
    key_mgr_init();
    return array::contains(self.key_mgr.valid, key);
}

function private key_mgr_compile_key(id, config, default_config) {
    if (!isdefined(config)) {
        // no config, use default
        // force array
        if (!isarray(default_config)) {
            default_config = [ default_config ];
        }
        self.key_mgr.config[id] = default_config;
        return;
    }

    cfg_split = strtok(config, "+");

    cfg = [];

    for (i = 0; i < cfg_split.size; i++) {
        if (self key_mgr_is_valid(cfg_split[i])) {
            array::add(cfg, hash(cfg_split[i]));
        }
    }
    
    self.key_mgr.config[id] = cfg;
}

function private key_mgr_get_key_str(id) {
    key_mgr_init();

    if (!isdefined(self.key_mgr.config[id])) {
        return; // bad config
    }
    
    key_cfg = self.key_mgr.config[id];
    if (key_cfg.size == 0) {
        return "";
    }

    s = key_mgr_get_key_str_id(key_cfg[0]);

    for (i = 1; i < key_cfg.size; i++) {
        s += "+" + key_mgr_get_key_str_id(key_cfg[i]);
    }

    return s;
}

function private key_mgr_has_key_pressed(id, wait_release = false) {
    key_mgr_init();

    if (!isdefined(self.key_mgr.config[id])) {
        return; // bad config
    }
    
    key_cfg = self.key_mgr.config[id];

    for (i = 0; i < key_cfg.size; i++) {
        if (!self key_mgr_has_key_pressed_id(key_cfg[i])) {
            return false;
        }
    }
    if (!isdefined(wait_release) || !wait_release) {
        return true;
    }
    
    for (;;) {
        we_continue = false;
        for (i = 0; i < key_cfg.size; i++) {
            if (self key_mgr_has_key_pressed_id(key_cfg[i])) {
                we_continue = true;
            }
        }
        // wait for all the keys
        if (!we_continue) {
            break;
        }
        waitframe(1);
    }
    return true;
}

function key_mgr_get_key_str_id(id) {
    switch (id) {
        case #"action": return "[{+action}]";
        case #"actionslotfour": return "[{+actionslot 4}]";
        case #"actionslotone": return "[{+actionslot 1}]";
        case #"actionslotthree": return "[{+actionslot 3}]";
        case #"actionslottwo": return "[{+actionslot 2}]";
        case #"ads": return "[{+ads}]";
        case #"attack": return "[{+attack}]";
        case #"changeseat": return "[{+switchseat}]";
        case #"frag": return "[{+frag}]";
        case #"jump": return "[{+gostand}]";
        case #"melee": return "[{+melee}]";
        case #"offhandspecial": return "[{+offhandspecial}]";
        case #"reload": return "[{+reload}]";
        case #"secondaryoffhand": return "[{+smoke}]";
        case #"sprint": return "[{+sprint}]";
        case #"stance": return "[{+stance}]";
        case #"throw": return "[{+frag}]";
        case #"use": return "[{+use}]";
        case #"vehicleattack": return "[{+vehicleattack}]";
        case #"vehiclemoveup": return "[{+vehiclemoveup}]";
        case #"weaponswitch": return "[{+weapnext_inventory}]";
        default: return "??";
    }
}
function key_mgr_has_key_pressed_id(id) {
    switch (id) {
        case #"action":
            return self actionbuttonpressed();
        case #"actionslotfour":
            return self actionslotfourbuttonpressed();
        case #"actionslotone":
            return self actionslotonebuttonpressed();
        case #"actionslotthree":
            return self actionslotthreebuttonpressed();
        case #"actionslottwo":
            return self actionslottwobuttonpressed();
        case #"ads":
            return self adsbuttonpressed();
        case #"attack":
            return self attackbuttonpressed();
        case #"changeseat":
            return self changeseatbuttonpressed();
        case #"frag":
            return self fragbuttonpressed();
        case #"jump":
            return self jumpbuttonpressed();
        case #"melee":
            return self meleebuttonpressed();
        case #"offhandspecial":
            return self offhandspecialbuttonpressed();
        case #"reload":
            return self reloadbuttonpressed();
        case #"secondaryoffhand":
            return self secondaryoffhandbuttonpressed();
        case #"sprint":
            return self sprintbuttonpressed();
        case #"stance":
            return self stancebuttonpressed();
        case #"throw":
            return self throwbuttonpressed();
        case #"use":
            return self usebuttonpressed();
        case #"vehicleattack":
            return self vehicleattackbuttonpressed();
        case #"vehiclemoveup":
            return self vehiclemoveupbuttonpressed();
        case #"weaponswitch":
            return self weaponswitchbuttonpressed();
        default:
            return false;
    }
}


function private on_player_spawned() {
    self endon(#"disconnect", #"spawned_player");
    level endon(#"end_game", #"game_ended");

    if (isbot(self) || !self ishost()) {
        return; // ignore bot / other players
    }


    // init menu system
    if (!self init_menu("Menu")) {
        return;
    }

    self key_mgr_init();
    self menu_think();
}