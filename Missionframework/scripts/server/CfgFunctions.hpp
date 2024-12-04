class server_highcommand {
    file = "scripts\server\highcommand";

    class highcommand                   {ext = ".fsm";};
};

class server_sector {
    file = "scripts\server\sector";

    class destroyFob                    {};
    class sectorMonitor                 {ext = ".fsm";};
    class spawnSectorCrates             {};
    class spawnSectorIntel              {};
};

class server_support {
    file = "scripts\server\support";

    class createSuppModules             {};
};

class server_artillery {
    file = "scripts\server\artillery";
    
class addMagazinesMortar            {};
    class artilleryFobFiring            {};
    class artilleryFobTargeting         {};
    class artilleryPositionManager      {};
    class getArtilleryRanges            {};
    class artillerySpawnPosition        {};
    class artillerySupRequest           {};
    class artilleryTimerSpawn           {};
    class createLaserTarget             {};
    class fireArtillery                 {};
    class getArtySpawnPoint             {};
    class getNearestArtillery           {};
    class getReadyArtillery             {};
    class grpUnitKilled                 {};
    class spawnArtillery                {};
}
