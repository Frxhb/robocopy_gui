# new powershell gui for learning
# start date: 12.06.2022
# last edit: 19.06.2022
# syntax note: comments and explanations above commands

# clearing variables each time script runs
if ($null -ne $first_path -xor $null -ne $second_path -xor $null -ne $both_path -xor $null -ne $process_id -xor $null -ne $param) {

    Clear-Variable first_path 

    Clear-Variable second_path

    Clear-Variable both_path

    Clear-Variable process_id

    Clear-Variable param

}
 
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
        $wsh.Popup("Bitte waehle Start- und Zielverzeichnis aus!", "0", "Fehler!", 0x1)
    }

    # definition of handler click actions
    
    # launch folder dialog 1
    $global:handler_1_click = {

        $TextBox1.Clear()

        $FolderBrowser1 = New-Object System.Windows.Forms.FolderBrowserDialog
        $FolderBrowser1.ShowDialog() | Out-Null

        $global:First_Path_without_komma = $FolderBrowser1.SelectedPath

        # define !GLOBAL! path variable
        $global:First_Path = "`"$First_Path_without_komma`""

        $TextBox1.ReadOnly = $false
        $global:TextBox1.AppendText($First_Path_without_komma)
        $TextBox1.ReadOnly = $true
    }

    # launch folder dialog 2
    $global:handler_2_Click = {

        $TextBox2.Clear()

        $FolderBrowser2 = New-Object System.Windows.Forms.FolderBrowserDialog
        $FolderBrowser2.ShowDialog() | Out-Null

        $global:Second_Path_without_komma = $FolderBrowser2.SelectedPath

        $global:Second_Path = "`"$Second_Path_without_komma`""

        $TextBox2.ReadOnly = $false
        $global:TextBox2.AppendText($Second_Path_without_komma)
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
        

        $RichTextBox1.Clear()
        $RichTextBox1.ReadOnly = $false
        $RichTextBox1.AppendText("Starte job... `n `n")
        $RichTextBox1.ReadOnly = $true

        #Start-Sleep -Seconds 2

        #combine both path:
        #Add last folder of source path to destination path
        
        #Extract last folder
        $path_endname = $First_Path_without_komma -replace '.*\\'
        #write-host $path_endname

        #Now adding to destination folder
        $end_path_two = "$Second_Path_without_komma\$path_endname"

        #Adding ""
        $end_path_two_with_marks = "`"$end_path_two`""

        #write-host $end_path_two

        $global:both_path = $first_path ,  $end_path_two_with_marks
        #Write-Host $both_path

        if (!$checkBox1.Checked -and !$checkBox2.Checked -and !$checkBox3.Checked -and !$checkBox4.Checked) {

            $cmd_process = start-process -FilePath C:\Windows\System32\cmd.exe -ArgumentList ("/K" , "robocopy" , "$both_path" , "/V /move") -PassThru -WindowStyle Minimized
            $global:process_id = $cmd_process.Id

            $RichTextBox1.ReadOnly = $false
            $RichTextBox1.AppendText("Folgende Verzeichnisse sind betroffen:`n`n$First_Path_without_komma wird kopiert in ------>  $Second_path_without_komma")
            $RichTextBox1.ReadOnly = $true
        }
        
        else {
            $cmd_process = start-process -FilePath C:\Windows\System32\cmd.exe -ArgumentList ("/K" , "robocopy" , "$both_path" , "/V" , "$param") -PassThru -WindowStyle Minimized
            $global:process_id = $cmd_process.Id
            $RichTextBox1.ReadOnly = $false
            $RichTextBox1.AppendText("Folgende Verzeichnisse sind betroffen:`n`n$First_Path_without_komma wird kopiert in ------>  $Second_path_without_komma")          
            $RichTextBox1.ReadOnly = $true
        } 
    }


    # stop-job definition
    $global:handler_4_Click = {

        Add-Type -AssemblyName PresentationCore,PresentationFramework
        $ButtonType = [System.Windows.MessageBoxButton]::YesNoCancel
        $MessageIcon = [System.Windows.MessageBoxImage]::Error
        $MessageBody = "Bist du Sicher, dass du jeden Robocopy Job beenden willst? Aufpassen: Jeder Job wird unterbrochen."
        $MessageTitle = "Bestaetige Abbruch"
        $Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)

        switch ($Result){
            'Yes'{
                Stop-Process -ProcessName Robocopy -Force
            }
            'No'{
            }
            'Cancel'{
            }
        }
        
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

        $iconBase64 = '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'
        $iconBytes = [Convert]::FromBase64String($iconBase64)
        $stream = New-Object IO.MemoryStream($iconBytes, 0, $iconBytes.Length)
        $stream.Write($iconBytes, 0, $iconBytes.Length);
        $iconImage = [System.Drawing.Image]::FromStream($stream, $true)
        $mainform.Icon = [System.Drawing.Icon]::FromHandle((New-Object System.Drawing.Bitmap -Argument $stream).GetHIcon())

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
        $TextBox1.Font =  [System.Drawing.Font]::New('Tahoma', 12)

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
        $TextBox2.Font =  [System.Drawing.Font]::New('Tahoma', 12)

        # RichTextBox 1 definition
        $RichTextBox1 = New-Object System.Windows.Forms.RichTextBox
        #$RichTextBox1.FormattingEnabled = $True
        $System_Drawing_Size = New-Object System.Drawing.Size
        $System_Drawing_Size.Width = 760
        $System_Drawing_Size.Height = 150
        $RichTextBox1.Size = $System_Drawing_Size
        $RichTextBox1.DataBindings.DefaultDataSourceUpdateMode = 0
        $RichTextBox1.Name = "RichTextBox1"
        $System_Drawing_Point = New-Object System.Drawing.Point
        $System_Drawing_Point.X = 20 
        $System_Drawing_Point.Y = 350
        $RichTextBox1.Location = $System_Drawing_Point
        $RichTextBox1.ReadOnly = $true
        $RichTextBox1.Font =  [System.Drawing.Font]::New('Tahoma', 12)

        # label 1
        $label1 = New-Object System.Windows.Forms.Label
        $label1.Location = New-Object System.Drawing.Point(200, 30)
        $label1.Size = New-Object System.Drawing.Size(400, 20)
        $label1.Font = new-object System.Drawing.Font('Ariel', 10, [System.Drawing.FontStyle]::Regular)
        $label1.Text = 'Waehle den zu kopierenden Ordner:'
        $label1.Font =  [System.Drawing.Font]::New('Tahoma', 12)
        
        # label 2
        $label2 = New-Object System.Windows.Forms.Label
        $label2.Location = New-Object System.Drawing.Point(200, 150)
        $label2.Size = New-Object System.Drawing.Size(400, 20)
        $label2.Font = new-object System.Drawing.Font('Ariel', 10, [System.Drawing.FontStyle]::Regular)
        $label2.Text = 'Waehle das Zielverzeichnis:'
        $label2.Font = [System.Drawing.Font]::New('Tahoma', 12)

        # label 3 (LOG)
        $label3 = New-Object System.Windows.Forms.Label
        $label3.Location = New-Object System.Drawing.Point(20, 330)
        $label3.Size = New-Object System.Drawing.Size(400, 20)
        $label3.Font = new-object System.Drawing.Font('Ariel', 10, [System.Drawing.FontStyle]::Regular)
        $label3.Text = 'Log:'
        $label3.Font = [System.Drawing.Font]::New('Tahoma', 12)


        ### buttons

        ## Copy-Directory
        $Choose_Copy_Directory_Button = New-Object System.Windows.Forms.Button
        $Choose_Copy_Directory_Button.Location = New-Object System.Drawing.Point(620, 68) #y und x Achse
        $Choose_Copy_Directory_Button.Size = New-Object System.Drawing.Size(75, 23)
        # text of button 
        $Choose_Copy_Directory_Button.Text = 'Suchen..'
        $Choose_Copy_Directory_Button.TabIndex = 6
        # define what happens if click
        $Choose_Copy_Directory_Button.add_Click($handler_1_Click)

        ## Destination Directory
        $DestinationButton = New-Object System.Windows.Forms.Button
        $DestinationButton.Location = New-Object System.Drawing.Point(620, 188) #y und x Achse
        $DestinationButton.Size = New-Object System.Drawing.Size(75, 23)
        # text of button 
        $DestinationButton.Text = 'Suchen..'
        $DestinationButton.TabIndex = 7
        # define what happens if click
        $DestinationButton.add_Click($handler_2_Click)

        ## Quit button
        $CancelButton = New-Object System.Windows.Forms.Button
        $CancelButton.Location = New-Object System.Drawing.Point(620, 550) #y und x Achse
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
        $start_job_button.Text = 'starte-job'
        $start_job_button.ForeColor = "green"
        $start_job_button.TabIndex = 8
        $start_job_button.add_Click($handler_3_Click)

        ## stop job button definition
        $stop_job_button = New-Object System.Windows.Forms.Button
        $stop_job_button.Location = New-Object System.Drawing.Point(424, 550 ) #Y und x Achse
        $stop_job_button.Size = New-Object System.Drawing.Size(75, 23)
        $stop_job_button.Text = 'stoppe-job'
        $stop_job_button.ForeColor = "red"
        $stop_job_button.TabIndex = 9
        $stop_job_button.add_Click($handler_4_Click)

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
        $checkBox4.Text = "Ziel-Ordner Inhalt loeschen"
        $System_Drawing_Point = New-Object System.Drawing.Point
        $System_Drawing_Point.X = 20
        $System_Drawing_Point.Y = 170
        $checkBox4.Location = $System_Drawing_Point
        $checkBox4.DataBindings.DefaultDataSourceUpdateMode = 0
        $checkBox4.Name = "checkBox4"

        #Checkbox 5 wird definiert
        $global:checkBox5 = New-Object System.Windows.Forms.CheckBox
        $checkBox4.UseVisualStyleBackColor = $True
        $System_Drawing_Size = New-Object System.Drawing.Size
        $System_Drawing_Size.Width = 155
        $System_Drawing_Size.Height = 30
        $checkBox5.Size = $System_Drawing_Size
        $checkBox5.TabIndex = 4
        $checkBox5.Text = "Ursprungs-Ordner Inhalt loeschen"
        $System_Drawing_Point = New-Object System.Drawing.Point
        $System_Drawing_Point.X = 20
        $System_Drawing_Point.Y = 220
        $checkBox5.Location = $System_Drawing_Point
        $checkBox5.DataBindings.DefaultDataSourceUpdateMode = 0
        $checkBox5.Name = "checkBox5"
        

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
        
        # implement checkboxes
        $mainform.Controls.Add($checkBox1)
        $mainform.Controls.Add($checkBox2)
        $mainform.Controls.Add($checkBox3)
        $mainform.Controls.Add($checkBox4)
        $mainform.Controls.Add($checkBox5)


        # show the form
        $mainform.ShowDialog() | Out-Null
    }
    FormDefinition
}
# call the main program
MainProgram