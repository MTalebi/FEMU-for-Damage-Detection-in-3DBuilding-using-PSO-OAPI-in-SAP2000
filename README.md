# FEMU for Damage Detection in 3D Buildings using SAP2000 and PSO

This repository contains a MATLAB workflow for finite element model updating (FEMU) to estimate stiffness loss in a 3D building model in SAP2000.

The code adjusts frame stiffness modifiers and minimizes the difference between:
- measured accelerations from sensor files
- simulated accelerations from SAP2000 time history analysis

## Repository contents

- `/tmp/workspace/MTalebi/FEMU-for-Damage-Detection-in-3DBuilding-using-PSO-OAPI-in-SAP2000/Main_SteelBuildingDDTH_Model_Updating.m`  
  Main script. Connects to SAP2000, prepares groups and variables, runs PSO, and plots measured versus simulated acceleration.

- `/tmp/workspace/MTalebi/FEMU-for-Damage-Detection-in-3DBuilding-using-PSO-OAPI-in-SAP2000/Objective_Fun.m`  
  Objective function used by PSO. Applies stiffness modifiers, runs analysis, reads joint accelerations, and returns a normalized error.

- `/tmp/workspace/MTalebi/FEMU-for-Damage-Detection-in-3DBuilding-using-PSO-OAPI-in-SAP2000/3D Building Example in SAP2000/`  
  Example SAP2000 model files and sample measured acceleration files.

## Requirements

- MATLAB with Global Optimization Toolbox (`particleswarm`)
- SAP2000 v23 installed
- SAP2000 OAPI DLL available at:
  - `C:\Program Files\Computers and Structures\SAP2000 23\SAP2000v1.dll`
- SAP2000 application path available at:
  - `C:\Program Files\Computers and Structures\SAP2000 23\SAP2000.exe`

## Input data format

Measured acceleration files are read as:
- `Point<ID>.txt`
- each file has columns: time, X acceleration, Y acceleration

The script loads these files based on joint IDs assigned to the SAP2000 group:
- `Sensor_Points`

## How it works

1. You select one `.sdb` model file and one `.txt` file from the measured data folder.
2. The script attaches to a running SAP2000 instance through OAPI.
3. It creates frame groups based on assigned auto select section names.
4. It classifies groups as beams, columns, or braces from element direction.
5. It defines optimization variables and bounds for stiffness modifiers:
   - beams: modifier on one bending inertia term
   - columns: modifiers on two bending inertia terms
   - braces: modifier on axial term
6. It runs PSO with:
   - swarm size: 10
   - max iterations: 30
7. For each trial solution, the objective function:
   - applies modifiers by group
   - runs analysis
   - compares modeled and measured accelerations at sensor joints
   - computes normalized error
8. After optimization, it plots measured and modeled X and Y acceleration for each sensor point.

## Default settings in the current code

- Sensor group name: `Sensor_Points`
- Time history load case: `RHA_Earthquacke`
- Model units: `kgf_cm_C`
- Bound ranges:
  - beams: 0.99 to 1.01
  - columns: 0.79 to 1.01
  - braces: 0.99 to 1.01

## Running the workflow

1. Open SAP2000 and load your model.
2. Make sure your sensor joints are assigned to group `Sensor_Points`.
3. Make sure measured files are named `Point<ID>.txt`.
4. Run `Main_SteelBuildingDDTH_Model_Updating.m` in MATLAB.
5. Choose:
   - the SAP2000 `.sdb` file
   - any `.txt` file from the measured data folder
6. Review:
   - `ResponseEstimationError`
   - optimization runtime
   - comparison plots

## Notes

- The script saves a copy of the model as `DamageCoefIdentified_<original_model_name>`.
- If your SAP2000 install path, group name, or load case name is different, edit the values near the top of `Main_SteelBuildingDDTH_Model_Updating.m`.

## Author

Mohammad Talebi-Kalaleh  
talebika@ualberta.ca
