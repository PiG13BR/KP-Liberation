/*
    - Place here the structures that you want the enemy static weapons to spawn. For that, you need:
        The classname of the building, followed by arrays in array of,
        The type of the static weapon ("HMG", "AT", "AA"), related to ones in the presets. Can be more than one. Recommended: one type per position.
        The positionRelative coordinates where the static weapon will spawn, relative to the structure.
        The direction of the weapon (it will be relative to the object).
    - Example:
        - ["classname", [[[types], [relative position], relative direction], [["HMG", "AT", "AA"], [x,y,z], (+/- dir)]]]
    - To get positionRelative, stand your character where you want to static weapon to spawn and run the code below in debug, it will return a [x,y,z] array. 
        (varNameOfTheObject or cursorObject) worldToModel ASLToAGL getPosASL player
    - Using modded static weapons may require small adjustments in relative positions
    - To open the possibility of spawning static weapons, it requires more editing by placing those buildings classnames referenced below in the map. Some building classes may be already in the map.
    - The static weapons will only spawn near sectors, so place the garrisons buildings near them
    - Don't duplicate classnames
    - Be careful when making a new array. Copy an example and change the values, and then check for missing or additional commas.
*/

PIG_staticsConfigs = [
    // Vanilla
    ["Land_Cargo_Patrol_V1_F", [[["HMG"], [-1.14307,-1.2998,-0.55952], (180)]]],
    ["Land_Cargo_Patrol_V2_F", [[["HMG"], [-1,-1.3,-0.5], (180)]]],
    ["Land_Cargo_Patrol_V3_F", [[["HMG"], [-1,-1.3,-0.5], (180)]]], 
    ["Land_Cargo_HQ_V1_F", [[["AA"], [1.54492,0.740723,-0.747444], (0)], [["HMG"], [-1.57813,-4.04639,-0.747444], (180)], [["HMG"], [-2.64551,3.2,-0.747444], (- 45)], [["HMG"], [5.88232,1.84473,-0.747444], (- 45)]]],
    ["Land_Cargo_HQ_V2_F", [[["AA"], [1.54492,0.740723,-0.747444], (0)], [["HMG"], [-1.57813,-4.04639,-0.747444], (180)], [["HMG"], [-2.64551,3.2,-0.747444], (- 45)], [["HMG"], [5.88232,1.84473,-0.747444], (- 45)]]],
    ["Land_Cargo_HQ_V3_F", [[["AA"], [1.54492,0.740723,-0.747444], (0)], [["HMG"], [-1.57813,-4.04639,-0.747444], (180)], [["HMG"], [-2.64551,3.2,-0.747444], (- 45)], [["HMG"], [5.88232,1.84473,-0.747444], (- 45)]]],
    ["Land_Cargo_Tower_V1_F", [[["HMG"], [4.61279,3.98389,5.00471], (45)], [["HMG"], [4.8584,-2.90234,5.00471], (140)], [["HMG"], [-4.18359,-3.16211,5.00471], (- 90)], [["HMG"], [-3.07178,4.40283,5.00471], (0)]]],
    ["Land_Cargo_Tower_V2_F", [[["HMG"], [4.61279,3.98389,5.00471], (45)], [["HMG"], [4.8584,-2.90234,5.00471], (140)], [["HMG"], [-4.18359,-3.16211,5.00471], (- 90)], [["HMG"], [-3.07178,4.40283,5.00471], (0)]]],
    ["Land_Cargo_Tower_V3_F", [[["HMG"], [4.61279,3.98389,5.00471], (45)], [["HMG"], [4.8584,-2.90234,5.00471], (140)], [["HMG"], [-4.18359,-3.16211,5.00471], (- 90)], [["HMG"], [-3.07178,4.40283,5.00471], (0)]]],
    ["Land_Cargo_Tower_V1_No1_F", [[["HMG"], [4.61279,3.98389,5.00471], (45)], [["HMG"], [4.8584,-2.90234,5.00471], (140)], [["HMG"], [-4.18359,-3.16211,5.00471], (- 90)], [["HMG"], [-3.07178,4.40283,5.00471], (0)]]],
    ["Land_Cargo_Tower_V1_No2_F", [[["HMG"], [4.61279,3.98389,5.00471], (45)], [["HMG"], [4.8584,-2.90234,5.00471], (140)], [["HMG"], [-4.18359,-3.16211,5.00471], (- 90)], [["HMG"], [-3.07178,4.40283,5.00471], (0)]]],
    ["Land_Cargo_Tower_V1_No3_F", [[["HMG"], [4.61279,3.98389,5.00471], (45)], [["HMG"], [4.8584,-2.90234,5.00471], (140)], [["HMG"], [-4.18359,-3.16211,5.00471], (- 90)], [["HMG"], [-3.07178,4.40283,5.00471], (0)]]],
    ["Land_Cargo_Tower_V1_No4_F", [[["HMG"], [4.61279,3.98389,5.00471], (45)], [["HMG"], [4.8584,-2.90234,5.00471], (140)], [["HMG"], [-4.18359,-3.16211,5.00471], (- 90)], [["HMG"], [-3.07178,4.40283,5.00471], (0)]]],
    ["Land_Cargo_Tower_V1_No5_F", [[["HMG"], [4.61279,3.98389,5.00471], (45)], [["HMG"], [4.8584,-2.90234,5.00471], (140)], [["HMG"], [-4.18359,-3.16211,5.00471], (- 90)], [["HMG"], [-3.07178,4.40283,5.00471], (0)]]],
    ["Land_Cargo_Tower_V1_No6_F", [[["HMG"], [4.61279,3.98389,5.00471], (45)], [["HMG"], [4.8584,-2.90234,5.00471], (140)], [["HMG"], [-4.18359,-3.16211,5.00471], (- 90)], [["HMG"], [-3.07178,4.40283,5.00471], (0)]]],
    ["Land_Cargo_Tower_V1_No7_F", [[["HMG"], [4.61279,3.98389,5.00471], (45)], [["HMG"], [4.8584,-2.90234,5.00471], (140)], [["HMG"], [-4.18359,-3.16211,5.00471], (- 90)], [["HMG"], [-3.07178,4.40283,5.00471], (0)]]],
    ["Land_BagFence_Round_F", [[["AT"], [0,1.5,0], (180)]]],
    ["Land_BagFence_Long_F", [[["AA"], [0,1.5,0], (180)]]],
    ["Land_HBarrierTower_F", [[["HMG"], [0,-1.2793,0.0967188], (180)]]],
    ["Land_BagBunker_Small_F", [[["HMG"], [0,0,-0.9], (180)]]],
    ["Land_BagBunker_Large_F", [[["HMG"], [0.0717773,-3.24316,-0.709913], (180)], [["HMG"], [2.7627,-1.0293,-0.709913], (90)]]],
    ["Land_BagBunker_Tower_F", [[["AA", "AT"], [0.163086,1.16992,0.571415], (0)], [["HMG"], [-0.599121,-1.44092,0.571415], (180)]]]
]

PIG_staticConfigs_classes = PIG_staticsConfigs apply { _x select 0 };
