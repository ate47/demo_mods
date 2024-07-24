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
}

function __init__() {
    
}

function __main__() {
    
}

