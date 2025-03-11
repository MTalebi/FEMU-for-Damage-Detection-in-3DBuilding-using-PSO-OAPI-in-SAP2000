# FEMU for Damage Detection in 3D Buildings Using PSO-OAPI in SAP2000

**Author:**  
**Mohammad Talebi-Kalaleh**

**GitHub Repository:**  
[https://github.com/MTalebi/FEMU-for-Damage-Detection-in-3DBuilding-using-PSO-OAPI-in-SAP2000/tree/main](https://github.com/MTalebi/FEMU-for-Damage-Detection-in-3DBuilding-using-PSO-OAPI-in-SAP2000/tree/main)

**Publish Date:**  
July 7, 2022

---

## Overview

This documentation explains a MATLAB-based **Finite Element Model Updating (FEMU)** framework for **damage detection** in a 3D building model using **Particle Swarm Optimization (PSO)** in conjunction with the **SAP2000** Open Application Programming Interface (OAPI). The primary goal is to identify stiffness reduction (or damage) through modifying elements’ moments of inertia (beam/column/brace stiffness) until the simulated time-history response matches the **measured** acceleration data from sensors.

A summarized workflow is:

1. **Main Script**  
   - Initializes MATLAB and SAP2000 OAPI.  
   - Defines model file paths, reads measured data, and configures the model for damage detection.  
   - Groups structural elements into beams, columns, and braces, preparing them for parameter modifications.  
   - Sets up the PSO (Particle Swarm Optimization) problem to find optimal stiffness modifiers.  
   - Runs the optimization and visualizes measured vs. simulated accelerations.

2. **Objective_Fun.m**  
   - Implements the cost function for PSO.  
   - Applies stiffness modifiers to each group of elements (beams, columns, braces) in SAP2000.  
   - Performs a time-history analysis and compares the results to measured accelerations.  
   - Calculates a normalized error (mismatch) used by PSO to guide stiffness modification.

---

## Main Script Explanation

Below is a condensed description of the primary sections in the main script:

1. **Clearing Workspace and Setting Up Files**  
   - Resets the MATLAB environment and retrieves file paths for the SAP2000 model (`*.sdb`) and the measured acceleration data (`*.txt`).  
   - The user is prompted to select the corresponding files/directories via `uigetfile`.

2. **Creating the SAP2000 API Objects**  
   - Loads the SAP2000 .NET assembly.  
   - Acquires a handle to the currently running instance of SAP2000 and its main `SapModel` object.  
   - Extracts interface objects like `FrameObj`, `Analyze`, `PropFrame`, `Group`, etc. to modify sections and retrieve analysis outputs.

3. **Model Copy and Units Setup**  
   - Saves a new copy of the SAP2000 model (prefixed by `"DamageCoefIdentified_"`) for the damage detection run.  
   - Unlocks the model so stiffness modifiers can be applied.  
   - Changes the model units (e.g., kgf, cm) as needed.

4. **Frame Grouping and Classification**  
   - Fetches all frame names and sorts them by autoselect section.  
   - Determines if each frame is a **Beam**, **Column**, or **Brace** by examining its orientation (vector in the global Z direction).  
   - Sorts frames by elevation (Z-coordinate) so that beams come first, then columns, then braces.  
   - Assigns each autoselect group to a dedicated SAP2000 Group for easy bulk modification.

5. **Defining Optimization Variables**  
   - **Number of Variables (nvars):** Derived from the count of beams, columns, and braces. For columns, two directions of stiffness modifiers are considered.  
   - **Lower and Upper Bounds (lb, ub):** Specifies the permissible range for stiffness modifiers (moment of inertia scaling) for each element category.  
   - An **initial guess (x0)** for the PSO is set to 1 (no modification).

6. **Analysis Setup**  
   - Selects the required time-history load case for output (`TH_LoadCase_Name`).  
   - Deselects other load cases to reduce unnecessary computations.  
   - Configures analysis result options for direct- and modal-history output.

7. **Ingesting Measured Data**  
   - Reads measured accelerations from text files for each sensor in the group `Output_Sensor_Joints`.  
   - Stores the measured data in a MATLAB structure for later comparison.

8. **Running PSO**  
   - Defines the cost function handle (`fun`) pointing to the objective function script.  
   - Creates a set of PSO options (`optimoptions('particleswarm', ...)`), specifying maximum iterations, swarm size, plotting functions, and display settings.  
   - Calls MATLAB’s `particleswarm` to solve the optimization problem, returning the best set of stiffness modifiers (`x_min`).  

9. **Results and Visualization**  
   - With the optimal parameters found, the script again retrieves and plots simulated vs. measured accelerations for each sensor point.  
   - The final mismatch (or **ResponseEstimationError**) is displayed, along with the total runtime in minutes.

---

## Objective_Fun.m

The **Objective_Fun.m** file calculates the cost for each trial solution (`x`) the PSO produces. A high-level overview:

1. **Model Unlocked**  
   - Ensures the model can be modified at each PSO iteration.

2. **Apply Stiffness Modifiers**  
   - Splits the input vector `x` into three parts:  
     - **Beams** (single moment of inertia direction).  
     - **Columns** (two directions for bending stiffness).  
     - **Braces** (single direction, if applicable).  
   - Uses the SAP2000 `SetModifiers` API call to assign these stiffness changes to entire groups at once.

3. **Run Analysis and Retrieve Results**  
   - Initiates the SAP2000 time-history analysis.  
   - Extracts acceleration time histories at the sensor points.

4. **Compute Error**  
   - Interpolates the measured data onto the model’s time steps for a fair comparison.  
   - Sums the **norm** of differences in both X and Y directions across all sensors.  
   - Normalizes the error by the number of sensors and time points.  
   - Returns this value to the PSO solver.

---

## How to Cite

If this framework or related code is helpful in your research, kindly cite:

> **Talebi-Kalaleh, Mohammad.** (2022). *FEMU for Damage Detection in 3D Building using PSO and OAPI in SAP2000.* Published July 7, 2022. GitHub repository: [https://github.com/MTalebi/FEMU-for-Damage-Detection-in-3DBuilding-using-PSO-OAPI-in-SAP2000/tree/main](https://github.com/MTalebi/FEMU-for-Damage-Detection-in-3DBuilding-using-PSO-OAPI-in-SAP2000/tree/main)

---

## Additional Notes

1. **Requirements**  
   - SAP2000 v23 (or a compatible version) with OAPI enabled.  
   - MATLAB with the Global Optimization Toolbox (for `particleswarm`).  
   - A `.sdb` file and corresponding `.txt` measurement files.

2. **Usage**  
   - Launch MATLAB and run the main script.  
   - Select the SAP2000 `.sdb` model and the folder with sensor `.txt` files when prompted.  
   - The script saves a new SAP2000 model file, executes the PSO-based damage detection, and plots measured vs. simulated accelerations.

3. **Potential Extensions**  
   - Consider more advanced damage models (e.g., changes in mass, damping, or localized changes in cross-sectional properties).  
   - Implement multi-objective approaches that account for multiple response types or multiple damage states.  
   - Adjust the PSO parameters (iterations, swarm size) for a balance between runtime and solution quality.

For more information or collaboration inquiries, contact:  
**talebika@ualberta.ca**
