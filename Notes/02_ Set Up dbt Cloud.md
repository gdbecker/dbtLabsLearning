## 02_ Set Up dbt Cloud

### Learning Objectives
- Load training data into your data platform
- Set up an empty repository and connect your GitHub account to dbt Cloud.
- Set up your warehouse and repository connections.
- Navigate the dbt Cloud IDE.
- Complete a simple development workflow in the dbt Cloud IDE.

### Review

#### dbt Cloud IDE
The dbt Cloud integrated development environment (IDE) is a single interface for building, testing, running, and version-controlling dbt projects from your browser. With the Cloud IDE, you can compile dbt code into SQL and run it against your database directly

!["basic layout"](./02_01%20ide-basic-layout-blank.png)

#### Basic Layout 
The IDE streamlines your workflow, and features a popular user interface layout with files and folders on the left, editor on the right, and command and console information at the bottom.

!["side menu"](./02_02%20ide-side-menu.png)

1. Git repository link — Clicking the Git repository link, located on the upper left of the IDE, takes you to your repository on the same active branch.
2. Documentation site button — Clicking the Documentation site book icon, located next to the Git repository link, leads to the dbt Documentation site. The site is powered by the latest dbt artifacts generated in the IDE using the dbt docs generate command from the Command bar. 
3. Version Control — The IDE's powerful Version Control section contains all git-related elements, including the Git actions button and the Changes section.
4. File Explorer — The File Explorer shows the filetree of your repository. You can: 
   1. Click on any file in the filetree to open the file in the File Editor. 
   2. Click and drag files between directories to move files. 
   3. Right click a file to access the sub-menu options like duplicate file, copy file name, copy as ref, rename, delete. 
      1. Note: To perform these actions, the user must not be in read-only mode, which generally happens when the user is viewing the default branch. 
   4. Use file indicators, located to the right of your files or folder name, to see when changes or actions were made: 
      1. Unsaved (•) — The IDE detects unsaved changes to your file/folder 
      2. Modification (M) — The IDE detects a modification of existing files/folders 
      3. Added (A) — The IDE detects added files 
      4. Deleted (D) — The IDE detects deleted files

!["cmd status"](./02_03%20ide-cmd-status.png)

5. Command bar — The Command bar, located in the lower left of the IDE, is used to invoke dbt commands. When a command is invoked, the associated logs are shown in the Invocation History Drawer. 
6. IDE Status button — The IDE Status button, located on the lower right of the IDE, displays the current IDE status. If there is an error in the status or in the dbt code that stops the project from parsing, the button will turn red and display "Error". If there aren't any errors, the button will display a green "Ready" status. To access the IDE Status modal, simply click on this button.