# Robocopy_gui

A powerful Powershell Robocopy Gui.

## What is possible with this tool?

With this simple powershell tool / gui you are able to use the [robocopy](https://docs.microsoft.com/de-de/windows-server/administration/windows-commands/robocopy) program (which is installed by default on any Windows OS) to copy folders on your computer with the use of many parameters.

After you have chosen the source and destination folder the script will start with the use of the chosen parameters the robocopy job.

<br>

Screenshot 1:

![mainprogram](/pictures/main_program.png)



<br>

Screenshot 2:
![mainprogram](/pictures/choosen_files.png)

Here is a small example of what will happen in the background.

The code which will be executed is:

```powershell
PS C:\> start-process -FilePath C:\Windows\System32\cmd.exe RunAs -ArgumentList /K robocopy "C:\Users\Francesco\Desktop\Test 1" "C:\Users\Francesco\Desktop\Copy_dest" /V /E /R:0  /W:0  -PassThru
```

So the important part is:

```powershell
PS C:\> [....] robocopy "C:\Users\Francesco\Desktop\Test 1" "C:\Users\Francesco\Desktop\Copy_dest" /V /E /R:0  /W:0  -PassThru
```
<br>

Screenshot 3:
![mainprogram](/pictures/copy_progress.png)

Here you can see the script while running.

<br>

Screenshot 4:
![mainprogram](/pictures/copy_finished.png)

Here you can see the result when the job is finished.

## Prerequisites

To be able to run this script, you have two possible options:

1.  You need to change the ExecutionPolicy on your computer.
To do so, start powershell with **Admin-Rights** and paste the following code and confirm it with [A]:

<br>

```powershell
Set-ExecutionPolicy bypass
```
<br>

2.  If you dont want to change the ExecutionPolicy, you can copy and paste the content of the powershell script and create and run a new powershell script on your local machine.

## Errors or Comments

If you encounter any errors or if you miss some features, let me know

## Note

Because I use powershell in this tool, it's limited to Windows.