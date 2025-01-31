# WebMethods Deployment Helper Script

This script automates the process of linking webMethods **packages** and **property files** from a Git repository to an **Integration Server (IS)** home directory.

## Features
- Allows selective or bulk installation of **packages**.
- Supports **instance-specific property files**.
- Ensures property file symlinks are created **without environment prefixes**.
- Works with both **flat** and **nested** property folder structures.

## Prerequisites
- Ensure **IS_HOME** environment variable is set:
  ```sh
  export IS_HOME=/path/to/integration/server
  ```
- Place the script inside `assets/IS/` folder of your repository.
- Run the script from `assets/IS/`.
- The repository follows the standard **Software AG webMethods** structure:
  
  ```
  assets/IS/
  ├── packages/
  │   ├── Package1/
  │   ├── Package2/
  ├── properties/
  │   ├── DV_LOBProperties.txt
  │   ├── IT_ABCProperties.xml
  │   ├── INS1/
  │   │   ├── DV_ABCProperties.xml
  │   │   ├── IT_ABCProperties.xml
  ```

## Usage
### Step 1: Run the Script
```sh
bash sag_sym_link_packages_properties.sh
```

### Step 2: Select Packages to Install
The script will display available packages:
```
Available packages to install:
0) All Packages
1) Package1
2) Package2
```
**Example:**
- To install all packages, enter `0`.
- To install specific packages, enter numbers separated by commas (e.g., `1,2`).

### Step 3: Select Property Files
#### Case 1: Flat Properties Folder
```
Available Environments:
0) All
1) DV
2) IT
3) PD
```
**Example:**
- If selecting `DV`, the script will list:
  ```
  1) DV_LOBProperties.txt
  2) DV_ABCProperties.xml
  ```
- If `0` is chosen, all property files will be linked.

#### Case 2: Instance-Specific Properties Folder
```
Available Instances:
0) No specific instance (default properties folder)
1) INS1
2) INS2
```
**Example:**
- If selecting `INS1`, the script will list environments.
- Then it will show files specific to that instance.

### Step 4: Symlinks Created
The script creates **symbolic links** to the Integration Server directory:
- Packages:
  ```
  ln -s assets/IS/packages/Package1 $IS_HOME/packages/Package1
  ```
- Properties (removing environment prefix):
  ```
  ln -s assets/IS/properties/DV_LOBProperties.txt $IS_HOME/properties/LOBProperties.txt
  ```
  ```
  ln -s assets/IS/properties/INS1/IT_ABCProperties.xml $IS_HOME/properties/ABCProperties.xml
  ```

## Notes
- The script automatically removes the **environment prefix** (`DV_`, `IT_`) when linking property files.
- If symbolic links already exist, they will be updated (`ln -sfnv`).
- it also does this in verbose mode (`-v`) so u see whats going on

## Troubleshooting
**1. IS_HOME is not set**
```
Error: IS_HOME is not set. Please export IS_HOME to the correct Integration Server home directory.
```
Solution:
```sh
export IS_HOME=/your/path/to/IS
```

**2. No property files found**
```
No environment-specific property files found.
```
Solution:
- Ensure property files exist in `assets/IS/properties/`.
- Check the naming convention (e.g., `DV_`, `IT_`).

