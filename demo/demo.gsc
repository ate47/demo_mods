#using scripts\core_common\values_shared;
#using scripts\core_common\system_shared;
#using scripts\core_common\callbacks_shared;
#using scripts\core_common\util_shared;
#using scripts\core_common\array_shared;
#using scripts\core_common\clientfield_shared;

#namespace demo;

/*
  load scripts -> autoexec functions
  init step
  post init step
 */

function autoexec __init__system__() {
    system::register("demo", &__init__, &__main__);
    setgametypesetting(#"drafttime", 2);
}

function __init__() {
    callback::on_spawned(&on_player_spawned);
}

function __main__() {
    
}

function on_player_spawned() {
    level endon(#"end_game", #"game_ended");
    self endon(#"disconnect", #"spawned_player");

    wait 10;

    c = 0;

    while (true) {
      self iprintlnbold("Hello " + c);

      c++;

      wait 1;
    }
}

