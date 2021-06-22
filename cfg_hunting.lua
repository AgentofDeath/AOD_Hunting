Config = {}

Config.Animals = {"a_c_deer", "a_c_coyote", "a_c_boar"} -- add more animals here if you add animals you need to add them to the server side for obvious reasons

Config.SpawnDistance = math.random(50, 65) -- distance animals spawn from the bait

Config.DistanceFromBait = 25 -- distance you need to get from the bait for an animal to spawn

Config.HuntingZones = {'AIRP', 'CMSW' , 'SANCHIA', 'MTGORDO', 'MTJOSE', 'PALHIGH'} -- add or remove hunting zones here

Config.HuntingWeapon = `WEAPON_MUSKET` -- Set to nil to disable weapon requirement

Config.Notifications = {
    cannot_place_bait = 'You can\'t place bait in this area, try somewhere else!',
    exploit_detected = 'Please do not attempt to exploit',
    bait_placed = 'You placed bait, move at least %s meters away and wait!',
    wait_to_place_bait = 'You must wait a while to use more bait',
    animal_destroyed = 'This animal looks more like roadkill now, perhaps try a musket?',
    no_animal_nearby = 'You must be near an animal carcass to use this',
    animal_not_dead = 'You cannot use this on a live animal!',
    animal_invalid = 'You cannot butcher this',
    baiting = 'Placing bait...',
    harvesting = 'Harvesting animal...'
}