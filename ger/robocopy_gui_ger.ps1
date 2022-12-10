# new powershell gui
# start date: 12.06.2022
# last edit: 10.12.2022
# syntax note: comments and explanations above commands

# clearing variables each time script runs

if ($null -ne $first_path -xor $null -ne $second_path -xor $null -ne $both_path -xor $null -ne $process_id -xor $null -ne $param) {

    Clear-Variable first_path 
    Clear-Variable second_path
    Clear-Variable both_path
    Clear-Variable process_id
    Clear-Variable param

}

#minimize console function
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

function ShowConsole {
    $consolePtr = [Console.Window]::GetConsoleWindow()
    [Console.Window]::ShowWindow($consolePtr, 5) #5 show
}

function HideConsole {
    $consolePtr = [Console.Window]::GetConsoleWindow()
    [Console.Window]::ShowWindow($consolePtr, 0) #0 hide
}
#Setting console to be hidden
HideConsole
 
# create main function
function global:MainProgram {

    # modules for windows forms are loaded
    [reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
    [reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null

    # clear Host is clearing the text output when running program
    clear-Host

    # clear the error variable to do better debugging later on
    $error.clear()

    # if error appears, program will continue
    $errorActionPreference = "SilentlyContinue"

    # popup defintion
    function global:popup_one {
        $wsh = New-Object -ComObject Wscript.Shell
        $wsh.Popup("Bitte wähle Start- und Zielverzeichnis aus!", "0", "Fehler!", 0x1)
    }

    # definition of handler click actions
    
    # launch folder dialog 1
    $global:handler_1_click = {

        $TextBox1.Clear()
        #Textbox will be cleared

        $FolderBrowser1 = New-Object System.Windows.Forms.FolderBrowserDialog
        #declaring FolderBrowserDialog
        
        $FolderBrowser1.ShowDialog() | Out-Null
        #Showing FolderDialog

        #Declaring folder choice to variable
        $global:First_Selected_Path = $FolderBrowser1.SelectedPath
        
        $global:First_Path_with_quotes = "`"$global:First_Selected_Path `""

        if ($global:First_Path_with_quotes.Length -lt 4) {
            $global:First_Path_with_quotes = ""
        }

        #Adding chosen path to Textbox next to search... button
        $TextBox1.ReadOnly = $false
        $global:TextBox1.AppendText($First_Selected_Path)
        $TextBox1.ReadOnly = $true

        #cuting out ":" from list of arrays
        $chosen_path_array = $global:First_Selected_Path.split("\")

        $check_for_colun_in_arrays = ForEach ($value in $chosen_path_array) {
            $value.Contains(":")
        }

        if ($check_for_colun_in_arrays -eq $true) {
            
            $arrays_without_colun = ForEach ($value in $chosen_path_array) {
                $value.Replace(':', "")
            }


            #$arrays_with_cr = foreach ($string in $arrays_without_colun){write-host $string}

            if ($arrays_without_colun.count -gt 1) {

                $last_array_without_space = $arrays_without_colun.Split('', [System.StringSplitOptions]::RemoveEmptyEntries)

            }

            $global:last_final_array = $last_array_without_space[-1]
        }

    }

    # launch folder dialog 2
    $global:handler_2_Click = {

        $TextBox2.Clear()
        #Textbox will be cleared

        $FolderBrowser2 = New-Object System.Windows.Forms.FolderBrowserDialog
        #declaring FolderBrowserDialog
        
        $FolderBrowser2.ShowDialog() | Out-Null
        #Showing FolderDialog

        #Declaring folder choice to variable
        $global:Second_Selected_Path = $FolderBrowser2.SelectedPath
        
        #Adding ""PATH"" (quotes)
        $Second_Path_with_quotes = "`"$global:Second_Selected_Path `""

        if ($Second_Path_with_quotes.Length -lt 4) {
            $Second_Path_with_quotes = ""
        }

        #Adding chosen path to Textbox next to search... button
        $TextBox2.ReadOnly = $false
        $global:TextBox2.AppendText($Second_Selected_Path)
        $TextBox2.ReadOnly = $true
    }

    # start-job defintion
    $global:handler_3_Click = {
        
        if ( ($TextBox1.Text.Length -lt 1) -OR ($TextBox2.Text.Length -lt 1) ) {
            popup_one
            return
        }
        
        if ($checkBox1.Checked) {
            $param = "/L "
        }

        if ($checkBox2.Checked) {
            $param = $param + "/E "
        }

        if ($checkBox3.Checked) {
            $param = $param + "/R:0 " , "/W:0 "
        }
        
        
        if ($checkBox4.Checked) {
            $param = $param + "/MIR"
        }

        if ($checkBox5.Checked) {
            $param = $param + "/Mov"
        }

        if ($checkBox6.Checked) {
            $param = $param + "/NFL /NDL"
        }
        
        $RichTextBox1.Clear()
        $RichTextBox1.ReadOnly = $false
        $RichTextBox1.AppendText("Job wird gestartet... `n `n")
        $RichTextBox1.ReadOnly = $true

        #Start-Sleep -Seconds 2

        $last_final_array_with_space_at_end = $last_final_array + " "

        $global:both_path = $First_Path_with_quotes , "`"$Second_Selected_Path\$last_final_array_with_space_at_end"""
        
        $get_transfer_size = "{0:N2}" -f ((Get-ChildItem -path $first_selected_path -recurse | Measure-Object -property length -sum ).sum /1GB) + " GB"

        $RichTextBox1.ReadOnly = $false
        $RichTextBox1.AppendText("Transfer-Size: $get_transfer_size`n`n")
        $RichTextBox1.ReadOnly = $true


        if (!$checkBox1.Checked -and !$checkBox2.Checked -and !$checkBox3.Checked -and !$checkBox4.Checked) {
            start-process -FilePath C:\Windows\System32\cmd.exe -ArgumentList ("/K" , "color a & robocopy" , "$both_path" , "/V /move") -PassThru -WindowStyle Minimized
            $RichTextBox1.ReadOnly = $false
            $RichTextBox1.AppendText("Folgende Verzeichnisse sind betroffen:`n`n$First_Selected_Path wird kopiert in  ------>  $Second_selected_path`n`nFolgende Parameter wurden genutzt:`n $param")
            $RichTextBox1.ReadOnly = $true
        }
        
        else {
            start-process -FilePath C:\Windows\System32\cmd.exe -ArgumentList ("/K" , "color a & robocopy" , "$both_path" , "/V" , "$param") -PassThru -WindowStyle Minimized
            $RichTextBox1.ReadOnly = $false
            $RichTextBox1.AppendText("Folgende Verzeichnisse sind betroffen:`n`n$First_Selected_path wird kopiert in  ------>  $Second_selected_path`n`nFolgende Parameter wurden genutzt:`n $param")          
            $RichTextBox1.ReadOnly = $true
        }
    }

    # stop-job definition
    $global:handler_4_Click = {

        Add-Type -AssemblyName PresentationCore, PresentationFramework
        $ButtonType = [System.Windows.MessageBoxButton]::YesNoCancel
        $MessageIcon = [System.Windows.MessageBoxImage]::Error
        $MessageBody = "Bist du sicher, dass du jeden Robocopy Job beenden willst? Aufpassen: Jeder Robocopy-Job wird unterbrochen."
        $MessageTitle = "Bestätige Abbruch"
        $Result = [System.Windows.MessageBox]::Show($MessageBody, $MessageTitle, $ButtonType, $MessageIcon)

        switch ($Result) {
            'Yes' {
                Stop-Process -ProcessName Robocopy -Force
            }
            'No' {
            }
            'Cancel' {
            }
        }
        
    }

    #refresh click definition
    $global:refresh_click = { 
        Function MakeNewForm {
            $mainform.Close()
            #Closes the form
            $mainform.Dispose()
            MainProgram
            #reopen the main program
        }
        MakeNewForm  
    }

        

    # start of form definition function
    function global:FormDefinition {

        # main window
        # main form definition
        $mainform = New-Object System.Windows.Forms.Form
        # name of the form which will be displayed
        $mainform.Text = "Robocopy GUI"
        # just a name for the form - wont be displayed
        $mainform.Name = "mainform"
        # comment
        $mainform.DataBindings.DefaultDataSourceUpdateMode = 0
        # "import" to be able to define form size
        $system_Drawing_Size = New-Object System.Drawing.Size
        # form width definition
        $system_Drawing_Size.Width = 800
        # form height definition
        $system_Drawing_Size.Height = 600
        # tell that var is drawing size var
        $mainform.ClientSize = $System_Drawing_Size

        # define form will be in foreground opened
        $mainform.Top = $false
        
        # define windows is fixed and cant be resized.
        # (https://docs.microsoft.com/de-de/dotnet/api/system.windows.forms.formborderstyle?view=windowsdesktop-6.0)
        $mainform.FormBorderStyle = 'Fixed3D'
        # define if form can be maximized or not
        $mainform.MaximizeBox = $false
        # define form will pop up in center of screen
        $mainform.StartPosition = "CenterScreen"
        #Save the initial state of the form
        #$initialFormWindowState = $mainform.WindowState
        #Init the OnLoad event to correct the initial state of the form
        $mainform.add_Load($OnLoadForm_StateCorrection)

        # TextBox 1 definition
        $global:TextBox1 = New-Object System.Windows.Forms.TextBox
        #$TextBox1.FormattingEnabled = $True
        $System_Drawing_Size = New-Object System.Drawing.Size
        $System_Drawing_Size.Width = 400
        $System_Drawing_Size.Height = 20
        $TextBox1.Size = $System_Drawing_Size
        $TextBox1.DataBindings.DefaultDataSourceUpdateMode = 0
        $TextBox1.Name = "RichTextBox1"
        $System_Drawing_Point = New-Object System.Drawing.Point
        $System_Drawing_Point.X = 195
        $System_Drawing_Point.Y = 70
        $TextBox1.Location = $System_Drawing_Point
        $TextBox1.ReadOnly = $true
        $Textbox1.TabIndex = 4
        $TextBox1.Font = [System.Drawing.Font]::New('Tahoma', 12)

        # TextBox 2 definition
        $global:TextBox2 = New-Object System.Windows.Forms.TextBox
        #$TextBox2.FormattingEnabled = $True
        $System_Drawing_Size = New-Object System.Drawing.Size
        $System_Drawing_Size.Width = 400
        $System_Drawing_Size.Height = 20
        $TextBox2.Size = $System_Drawing_Size
        $TextBox2.DataBindings.DefaultDataSourceUpdateMode = 0
        $TextBox2.Name = "RichTextBox1"
        $System_Drawing_Point = New-Object System.Drawing.Point
        $System_Drawing_Point.X = 195
        $System_Drawing_Point.Y = 190
        $TextBox2.Location = $System_Drawing_Point
        $TextBox2.ReadOnly = $true
        $TextBox2.TabIndex = 5
        $TextBox2.Font = [System.Drawing.Font]::New('Tahoma', 12)

        # RichTextBox 1 definition
        $RichTextBox1 = New-Object System.Windows.Forms.RichTextBox
        #$RichTextBox1.FormattingEnabled = $True
        $System_Drawing_Size = New-Object System.Drawing.Size
        $System_Drawing_Size.Width = 760
        $System_Drawing_Size.Height = 170
        $RichTextBox1.Size = $System_Drawing_Size
        $RichTextBox1.DataBindings.DefaultDataSourceUpdateMode = 0
        $RichTextBox1.Name = "RichTextBox1"
        $System_Drawing_Point = New-Object System.Drawing.Point
        $System_Drawing_Point.X = 20 
        $System_Drawing_Point.Y = 350
        $RichTextBox1.Location = $System_Drawing_Point
        $RichTextBox1.ReadOnly = $true
        $RichTextBox1.Font = [System.Drawing.Font]::New('Tahoma', 10)

        # label 1
        $label1 = New-Object System.Windows.Forms.Label
        $label1.Location = New-Object System.Drawing.Point(200, 30)
        $label1.Size = New-Object System.Drawing.Size(400, 20)
        $label1.Font = new-object System.Drawing.Font('Ariel', 10, [System.Drawing.FontStyle]::Regular)
        $label1.Text = 'Wähle den zu kopierenden Ordner:'
        $label1.Font = [System.Drawing.Font]::New('Tahoma', 12)
        
        # label 2
        $label2 = New-Object System.Windows.Forms.Label
        $label2.Location = New-Object System.Drawing.Point(200, 150)
        $label2.Size = New-Object System.Drawing.Size(400, 20)
        $label2.Font = new-object System.Drawing.Font('Ariel', 10, [System.Drawing.FontStyle]::Regular)
        $label2.Text = 'Wähle das Zielverzeichnis:'
        $label2.Font = [System.Drawing.Font]::New('Tahoma', 12)

        # label 3 (LOG)
        $label3 = New-Object System.Windows.Forms.Label
        $label3.Location = New-Object System.Drawing.Point(20, 330)
        $label3.Size = New-Object System.Drawing.Size(400, 20)
        $label3.Font = new-object System.Drawing.Font('Ariel', 10, [System.Drawing.FontStyle]::Regular)
        $label3.Text = 'Log:'
        $label3.Font = [System.Drawing.Font]::New('Tahoma', 10)


        ### buttons

        ## Copy-Directory
        $Choose_Copy_Directory_Button = New-Object System.Windows.Forms.Button
        $Choose_Copy_Directory_Button.Location = New-Object System.Drawing.Point(620, 70) #y und x Achse
        $Choose_Copy_Directory_Button.Size = New-Object System.Drawing.Size(75, 23)
        # text of button 
        $Choose_Copy_Directory_Button.Text = 'Suchen..'
        $Choose_Copy_Directory_Button.TabIndex = 6
        # define what happens if click
        $Choose_Copy_Directory_Button.add_Click($handler_1_Click)

        ## Destination Directory
        $DestinationButton = New-Object System.Windows.Forms.Button
        $DestinationButton.Location = New-Object System.Drawing.Point(620, 190) #y und x Achse
        $DestinationButton.Size = New-Object System.Drawing.Size(75, 23)
        # text of button 
        $DestinationButton.Text = 'Suchen..'
        $DestinationButton.TabIndex = 7
        # define what happens if click
        $DestinationButton.add_Click($handler_2_Click)

        ## Quit button
        $CancelButton = New-Object System.Windows.Forms.Button
        $CancelButton.Location = New-Object System.Drawing.Point(705, 550) #y und x Achse
        $CancelButton.Size = New-Object System.Drawing.Size(75, 23)
        # text of button 
        $CancelButton.Text = 'Beenden'
        # define what happens if click
        $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        # define color of the button text - default is black
        $CancelButton.ForeColor = "red"
        # define color of the background of button - default is white/gray
        #$CancelButton.BackColor = "red"

        ## start-job button
        $start_job_button = New-Object System.Windows.Forms.Button
        $start_job_button.Location = New-Object System.Drawing.Point(324, 550 ) #y und x Achse
        $start_job_button.Size = New-Object System.Drawing.Size(75, 23)
        $start_job_button.Text = 'Start'
        $start_job_button.ForeColor = "white"
        $start_job_button.BackColor = "green"
        $start_job_button.TabIndex = 8
        $start_job_button.add_Click($handler_3_Click)

        ## stop job button definition
        $stop_job_button = New-Object System.Windows.Forms.Button
        $stop_job_button.Location = New-Object System.Drawing.Point(424, 550 ) #Y und x Achse
        $stop_job_button.Size = New-Object System.Drawing.Size(75, 23)
        $stop_job_button.Text = 'Stop'
        $stop_job_button.ForeColor = "white"
        $stop_job_button.BackColor = "red"
        $stop_job_button.TabIndex = 9
        $stop_job_button.add_Click($handler_4_Click)

        #Refresh Button
        $RefreshButton = New-Object System.Windows.Forms.Button
        $RefreshButton.Location = New-Object System.Drawing.Point(20, 550 ) #X und Y Achse
        $RefreshButton.Size = New-Object System.Drawing.Size(75, 23)
        $RefreshButton.Text = 'Refresh'
        $RefreshButton.add_Click($refresh_click)

        # checkbox 1 definition
        $global:checkBox1 = New-Object System.Windows.Forms.CheckBox
        $checkBox1.UseVisualStyleBackColor = $True
        $System_Drawing_Size = New-Object System.Drawing.Size
        $System_Drawing_Size.Width = 155
        $System_Drawing_Size.Height = 30
        $checkBox1.Size = $System_Drawing_Size
        $checkBox1.TabIndex = 0
        $checkBox1.Text = "Nur Testen (/L)"
        $System_Drawing_Point = New-Object System.Drawing.Point
        $System_Drawing_Point.X = 20
        $System_Drawing_Point.Y = 20
        $checkBox1.Location = $System_Drawing_Point
        $checkBox1.DataBindings.DefaultDataSourceUpdateMode = 0
        $checkBox1.Name = "checkBox1"

        #Checkbox 2 wird definiert
        $global:checkBox2 = New-Object System.Windows.Forms.CheckBox
        $checkBox2.UseVisualStyleBackColor = $True
        $System_Drawing_Size = New-Object System.Drawing.Size
        $System_Drawing_Size.Width = 155
        $System_Drawing_Size.Height = 30
        $checkBox2.Size = $System_Drawing_Size
        $checkBox2.TabIndex = 1
        $checkBox2.Text = "Auch (leere) Unterverzeichnisse (/E)"
        $System_Drawing_Point = New-Object System.Drawing.Point
        $System_Drawing_Point.X = 20
        $System_Drawing_Point.Y = 70
        $checkBox2.Location = $System_Drawing_Point
        $checkBox2.DataBindings.DefaultDataSourceUpdateMode = 0
        $checkBox2.Name = "checkBox2"

        $checkbox2.Checked = $true
        #$checkbox2.Enabled = $false
        
        #Checkbox 3 wird definiert
        $global:checkBox3 = New-Object System.Windows.Forms.CheckBox
        $checkBox3.UseVisualStyleBackColor = $True
        $System_Drawing_Size = New-Object System.Drawing.Size
        $System_Drawing_Size.Width = 155
        $System_Drawing_Size.Height = 30
        $checkBox3.Size = $System_Drawing_Size
        $checkBox3.TabIndex = 2
        $checkBox3.Text = "Fehler ignorieren (/R:0, /W:0)"
        $System_Drawing_Point = New-Object System.Drawing.Point
        $System_Drawing_Point.X = 20
        $System_Drawing_Point.Y = 120
        $checkBox3.Location = $System_Drawing_Point
        $checkBox3.DataBindings.DefaultDataSourceUpdateMode = 0
        $checkBox3.Name = "checkBox3"

        $checkbox3.Checked = $true
        #$checkbox3.Enabled = $false

        #Checkbox 4 wird definiert
        $global:checkBox4 = New-Object System.Windows.Forms.CheckBox
        $checkBox4.UseVisualStyleBackColor = $True
        $System_Drawing_Size = New-Object System.Drawing.Size
        $System_Drawing_Size.Width = 155
        $System_Drawing_Size.Height = 30
        $checkBox4.Size = $System_Drawing_Size
        $checkBox4.TabIndex = 3
        $checkBox4.Text = "Ziel-Ordner Inhalt löschen"
        $System_Drawing_Point = New-Object System.Drawing.Point
        $System_Drawing_Point.X = 20
        $System_Drawing_Point.Y = 170
        $checkBox4.Location = $System_Drawing_Point
        $checkBox4.DataBindings.DefaultDataSourceUpdateMode = 0
        $checkBox4.Name = "checkBox4"

        #Checkbox 5 wird definiert
        $global:checkBox5 = New-Object System.Windows.Forms.CheckBox
        $checkBox5.UseVisualStyleBackColor = $True
        $System_Drawing_Size = New-Object System.Drawing.Size
        $System_Drawing_Size.Width = 155
        $System_Drawing_Size.Height = 30
        $checkBox5.Size = $System_Drawing_Size
        $checkBox5.TabIndex = 4
        $checkBox5.Text = "Ursprungs-Ordner Inhalt löschen"
        $System_Drawing_Point = New-Object System.Drawing.Point
        $System_Drawing_Point.X = 20
        $System_Drawing_Point.Y = 220
        $checkBox5.Location = $System_Drawing_Point
        $checkBox5.DataBindings.DefaultDataSourceUpdateMode = 0
        $checkBox5.Name = "checkBox5"

        #Checkbox 6 wird definiert
        $global:checkBox6 = New-Object System.Windows.Forms.CheckBox
        $checkBox6.UseVisualStyleBackColor = $True
        $System_Drawing_Size = New-Object System.Drawing.Size
        $System_Drawing_Size.Width = 155
        $System_Drawing_Size.Height = 30
        $checkBox6.Size = $System_Drawing_Size
        $checkBox6.TabIndex = 5
        $checkBox6.Text = "Zeige keinen Fortschritt an"
        $System_Drawing_Point = New-Object System.Drawing.Point
        $System_Drawing_Point.X = 20
        $System_Drawing_Point.Y = 270
        $checkBox6.Location = $System_Drawing_Point
        $checkBox6.DataBindings.DefaultDataSourceUpdateMode = 0
        $checkBox6.Name = "checkBox6"
               
        # implement all things to mainform

        # implement textboxes
        $mainform.Controls.Add($TextBox1)
        $mainform.Controls.Add($TextBox2)

        # implement RichTextBox
        $mainform.Controls.Add($RichTextBox1)

        # implement labels
        $mainform.Controls.Add($label1)
        $mainform.Controls.Add($label2)
        $mainform.Controls.Add($label3)

        # implement all action buttons
        $mainform.Controls.Add($Choose_Copy_Directory_Button)
        $mainform.Controls.Add($DestinationButton)
        $mainform.Controls.Add($CancelButton)
        $mainform.Controls.Add($start_job_button)
        $mainform.Controls.Add($stop_job_button)
        $mainform.Controls.Add($RefreshButton)
        
        # implement checkboxes
        $mainform.Controls.Add($checkBox1)
        $mainform.Controls.Add($checkBox2)
        $mainform.Controls.Add($checkBox3)
        $mainform.Controls.Add($checkBox4)
        $mainform.Controls.Add($checkBox5)
        $mainform.Controls.Add($checkBox6)

        # show the form
        $mainform.ShowDialog() | Out-Null
    }
    FormDefinition
}

# call the main program
MainProgram
