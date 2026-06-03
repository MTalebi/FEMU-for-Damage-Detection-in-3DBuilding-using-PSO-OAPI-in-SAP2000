# FEMU for Damage Detection in 3D Building using PSO and SAP2000 OAPI

This repository contains a MATLAB workflow that updates a SAP2000 structural model to match measured acceleration data.

The main script groups frame members, applies stiffness modifiers, runs a time history analysis, and uses particle swarm optimization to minimize the mismatch between measured and simulated accelerations.

## Repository contents

- `Main_SteelBuildingDDTH_Model_Updating.m`
  Main workflow. Connects to SAP2000, prepares groups and bounds, reads measured data, runs PSO, and plots results.
- `Objective_Fun.m`
  Objective function used by PSO. Applies modifiers, runs analysis, reads response, and returns normalized error.
- `3D Building Example in SAP2000/`
  Example SAP2000 model folder and measured acceleration text files.

## Requirements

- SAP2000 v23 installed.
- MATLAB with Global Optimization Toolbox (`particleswarm`).
- SAP2000 model file (`.sdb`).
- Measured acceleration files (`Point<JointName>.txt`) with 3 columns:
  1. Time
  2. X acceleration
  3. Y acceleration

## Important setup details from the current code

- The script uses these fixed local paths by default:
  - `C:\Program Files\Computers and Structures\SAP2000 23\SAP2000.exe`
  - `C:\Program Files\Computers and Structures\SAP2000 23\SAP2000v1.dll`
- The script attaches to an already running SAP2000 instance using:
  `helper.GetObject('CSI.SAP2000.API.SapObject')`
- Sensor joints are read from SAP2000 group: `Sensor_Points`
- Time history case selected for output and run: `RHA_Earthquacke`
- The script also enables case `MODAL`

## How to run

1. Open SAP2000 and open your `.sdb` model.
2. In MATLAB, run:
   `Main_SteelBuildingDDTH_Model_Updating`
3. Select:
   - a `.sdb` file
   - a `.txt` file inside the measured data folder
4. The script then:
   - saves a new model copy named `DamageCoefIdentified_<original_model_name>`
   - creates frame groups based on assigned autoselect sections
   - classifies groups as beam, column, or brace from element direction
   - builds optimization variables and bounds
   - runs PSO (`MaxIterations=30`, `SwarmSize=10`)
   - evaluates the best solution and plots measured vs simulated X and Y acceleration for each sensor point

## Parameterization used in optimization

The number of variables is:

`n_beam_groups + 2 * n_column_groups + n_brace_groups`

Bounds in the current script:

- Beams: `0.99` to `1.01`
- Columns: `0.79` to `1.01`
- Braces: `0.99` to `1.01`

Modifiers applied in `Objective_Fun.m`:

- Beam groups: modifier index 6
- Column groups: modifier indices 5 and 6
- Brace groups: modifier index 1

## Included example data

Example files are under:

`3D Building Example in SAP2000/`

This folder includes:

- `SAP 23 Model/2StoryFrame_RHA_Main.$2k`
- `SAP 23 Model/2StoryFrame_RHA_Main.sbk`
- measured acceleration files for points `8`, `9`, `29`, and `30`

Note: the example folder does not include an `.sdb` file. Create or save an `.sdb` model in SAP2000 before running the script.

## Citation

Talebi-Kalaleh, Mohammad (2022). FEMU for Damage Detection in 3D Building using PSO and OAPI in SAP2000.
Repository: https://github.com/MTalebi/FEMU-for-Damage-Detection-in-3DBuilding-using-PSO-OAPI-in-SAP2000

## Contact

talebika@ualberta.ca
