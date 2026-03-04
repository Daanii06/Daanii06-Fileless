Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Creazione del form principale
$form = New-Object System.Windows.Forms.Form
$form.Text = "Daanii06_ Fileless Clicker"
$form.Size = New-Object System.Drawing.Size(360, 360)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None"
$form.BackColor = [System.Drawing.Color]::FromArgb(15, 15, 15)
$form.TopMost = $true
$form.KeyPreview = $true

# Pannello di trascinamento
$dragPanel = New-Object System.Windows.Forms.Panel
$dragPanel.Location = New-Object System.Drawing.Point(0, 0)
$dragPanel.Size = New-Object System.Drawing.Size(360, 40)
$dragPanel.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
$dragPanel.Cursor = [System.Windows.Forms.Cursors]::SizeAll

# Eventi per il trascinamento
$dragPanel.Add_MouseDown({
    param($sender, $e)
    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        $script:dragging = $true
        $script:offsetX = $e.X
        $script:offsetY = $e.Y
    }
})

$dragPanel.Add_MouseMove({
    param($sender, $e)
    if ($script:dragging) {
        $form.Location = New-Object System.Drawing.Point(
            ($form.Location.X + $e.X - $script:offsetX),
            ($form.Location.Y + $e.Y - $script:offsetY)
        )
    }
})

$dragPanel.Add_MouseUp({
    param($sender, $e)
    $script:dragging = $false
})

$form.Controls.Add($dragPanel)

# Pulsante chiusura
$buttonClose = New-Object System.Windows.Forms.Button
$buttonClose.Text = "×"
$buttonClose.Location = New-Object System.Drawing.Point(325, 5)
$buttonClose.Size = New-Object System.Drawing.Size(30, 30)
$buttonClose.FlatStyle = "Flat"
$buttonClose.FlatAppearance.BorderSize = 0
$buttonClose.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
$buttonClose.ForeColor = [System.Drawing.Color]::FromArgb(255, 60, 60)
$buttonClose.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$buttonClose.Cursor = [System.Windows.Forms.Cursors]::Hand
$buttonClose.Add_MouseEnter({ $buttonClose.ForeColor = [System.Drawing.Color]::FromArgb(255, 120, 120) })
$buttonClose.Add_MouseLeave({ $buttonClose.ForeColor = [System.Drawing.Color]::FromArgb(255, 60, 60) })
$buttonClose.Add_Click({
    if ($script:leftTimer) { $script:leftTimer.Stop(); $script:leftTimer.Dispose() }
    if ($script:rightTimer) { $script:rightTimer.Stop(); $script:rightTimer.Dispose() }
    $form.Close()
})
$dragPanel.Controls.Add($buttonClose)

# Titolo
$labelTitle = New-Object System.Windows.Forms.Label
$labelTitle.Text = "Daanii06_ Fileless"
$labelTitle.Location = New-Object System.Drawing.Point(40, 5)
$labelTitle.Size = New-Object System.Drawing.Size(240, 30)
$labelTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$labelTitle.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$labelTitle.TextAlign = "MiddleCenter"
$dragPanel.Controls.Add($labelTitle)

# Separatore con gradiente
$separator = New-Object System.Windows.Forms.Panel
$separator.Location = New-Object System.Drawing.Point(30, 70)
$separator.Size = New-Object System.Drawing.Size(300, 2)
$separator.BackColor = [System.Drawing.Color]::FromArgb(255, 60, 60)
$form.Controls.Add($separator)

# Left click button
$leftClickBtn = New-Object System.Windows.Forms.Button
$leftClickBtn.Text = "LEFT CLICK"
$leftClickBtn.Location = New-Object System.Drawing.Point(40, 100)
$leftClickBtn.Size = New-Object System.Drawing.Size(130, 40)
$leftClickBtn.FlatStyle = "Flat"
$leftClickBtn.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255, 60, 60)
$leftClickBtn.FlatAppearance.BorderSize = 2
$leftClickBtn.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
$leftClickBtn.ForeColor = [System.Drawing.Color]::White
$leftClickBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$leftClickBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
$leftClickBtn.Add_Click({
    if ($script:leftTimer -and $script:leftTimer.Enabled) {
        $script:leftTimer.Stop()
        $leftClickBtn.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
        $leftClickBtn.ForeColor = [System.Drawing.Color]::White
        $leftClickBtn.Text = "LEFT CLICK"
        $leftClickBtn.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255, 60, 60)
    } else {
        $script:leftTimer = New-Object System.Windows.Forms.Timer
        $script:leftTimer.Interval = $trackbar.Value
        $script:leftTimer.Add_Tick({
            [System.Windows.Forms.Cursor]::Position = [System.Windows.Forms.Cursor]::Position
            Add-Type -AssemblyName System.Windows.Forms
            $signature = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, CallingConvention=CallingConvention.StdCall)]
public static extern void mouse_event(long dwFlags, long dx, long dy, long cButtons, long dwExtraInfo);
'@
            $SendMouseClick = Add-Type -memberDefinition $signature -name "Win32MouseEventNew" -namespace Win32Functions -passthru
            $SendMouseClick::mouse_event(0x00000002, 0, 0, 0, 0)
            $SendMouseClick::mouse_event(0x00000004, 0, 0, 0, 0)
        })
        $script:leftTimer.Start()
        $leftClickBtn.BackColor = [System.Drawing.Color]::FromArgb(255, 60, 60)
        $leftClickBtn.ForeColor = [System.Drawing.Color]::Black
        $leftClickBtn.Text = "LEFT ON"
        $leftClickBtn.FlatAppearance.BorderColor = [System.Drawing.Color]::White
    }
})
$form.Controls.Add($leftClickBtn)

# Right click button
$rightClickBtn = New-Object System.Windows.Forms.Button
$rightClickBtn.Text = "RIGHT CLICK"
$rightClickBtn.Location = New-Object System.Drawing.Point(190, 100)
$rightClickBtn.Size = New-Object System.Drawing.Size(130, 40)
$rightClickBtn.FlatStyle = "Flat"
$rightClickBtn.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255, 60, 60)
$rightClickBtn.FlatAppearance.BorderSize = 2
$rightClickBtn.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
$rightClickBtn.ForeColor = [System.Drawing.Color]::White
$rightClickBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$rightClickBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
$rightClickBtn.Add_Click({
    if ($script:rightTimer -and $script:rightTimer.Enabled) {
        $script:rightTimer.Stop()
        $rightClickBtn.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
        $rightClickBtn.ForeColor = [System.Drawing.Color]::White
        $rightClickBtn.Text = "RIGHT CLICK"
        $rightClickBtn.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255, 60, 60)
    } else {
        $script:rightTimer = New-Object System.Windows.Forms.Timer
        $script:rightTimer.Interval = $trackbar.Value
        $script:rightTimer.Add_Tick({
            [System.Windows.Forms.Cursor]::Position = [System.Windows.Forms.Cursor]::Position
            Add-Type -AssemblyName System.Windows.Forms
            $signature = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, CallingConvention=CallingConvention.StdCall)]
public static extern void mouse_event(long dwFlags, long dx, long dy, long cButtons, long dwExtraInfo);
'@
            $SendMouseClick = Add-Type -memberDefinition $signature -name "Win32MouseEventNew" -namespace Win32Functions -passthru
            $SendMouseClick::mouse_event(0x00000008, 0, 0, 0, 0)
            $SendMouseClick::mouse_event(0x00000010, 0, 0, 0, 0)
        })
        $script:rightTimer.Start()
        $rightClickBtn.BackColor = [System.Drawing.Color]::FromArgb(255, 60, 60)
        $rightClickBtn.ForeColor = [System.Drawing.Color]::Black
        $rightClickBtn.Text = "RIGHT ON"
        $rightClickBtn.FlatAppearance.BorderColor = [System.Drawing.Color]::White
    }
})
$form.Controls.Add($rightClickBtn)

# Speed control label
$speedLabel = New-Object System.Windows.Forms.Label
$speedLabel.Text = "CLICK SPEED (MS)"
$speedLabel.Location = New-Object System.Drawing.Point(40, 160)
$speedLabel.Size = New-Object System.Drawing.Size(280, 20)
$speedLabel.ForeColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
$speedLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$speedLabel.TextAlign = "MiddleCenter"
$form.Controls.Add($speedLabel)

# Speed display
$speedDisplay = New-Object System.Windows.Forms.Label
$speedDisplay.Text = "50"
$speedDisplay.Location = New-Object System.Drawing.Point(40, 180)
$speedDisplay.Size = New-Object System.Drawing.Size(280, 30)
$speedDisplay.ForeColor = [System.Drawing.Color]::FromArgb(255, 60, 60)
$speedDisplay.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
$speedDisplay.TextAlign = "MiddleCenter"
$form.Controls.Add($speedDisplay)

# Speed trackbar
$trackbar = New-Object System.Windows.Forms.TrackBar
$trackbar.Location = New-Object System.Drawing.Point(40, 220)
$trackbar.Size = New-Object System.Drawing.Size(280, 45)
$trackbar.Minimum = 10
$trackbar.Maximum = 200
$trackbar.Value = 50
$trackbar.TickFrequency = 10
$trackbar.BackColor = [System.Drawing.Color]::FromArgb(15, 15, 15)
$trackbar.ForeColor = [System.Drawing.Color]::FromArgb(255, 60, 60)
$trackbar.Add_ValueChanged({
    $speedDisplay.Text = $trackbar.Value.ToString()
    if ($script:leftTimer) { $script:leftTimer.Interval = $trackbar.Value }
    if ($script:rightTimer) { $script:rightTimer.Interval = $trackbar.Value }
})
$form.Controls.Add($trackbar)

# Hotkeys info
$hotkeysLabel = New-Object System.Windows.Forms.Label
$hotkeysLabel.Text = "HOTKEYS: F6 (LEFT) | F7 (RIGHT) | F8 (STOP)"
$hotkeysLabel.Location = New-Object System.Drawing.Point(40, 280)
$hotkeysLabel.Size = New-Object System.Drawing.Size(280, 30)
$hotkeysLabel.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
$hotkeysLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$hotkeysLabel.TextAlign = "MiddleCenter"
$form.Controls.Add($hotkeysLabel)

# Gestione eventi tastiera - NUOVA VERSIONE
$form.Add_KeyDown({
    param($sender, $e)
    switch ($e.KeyCode) {
        'F6' {
            if (-not $script:leftTimer -or -not $script:leftTimer.Enabled) {
                $leftClickBtn.PerformClick()
            }
            $e.SuppressKeyPress = $true
        }
        'F7' {
            if (-not $script:rightTimer -or -not $script:rightTimer.Enabled) {
                $rightClickBtn.PerformClick()
            }
            $e.SuppressKeyPress = $true
        }
        'F8' {
            if (($script:leftTimer -and $script:leftTimer.Enabled) -or ($script:rightTimer -and $script:rightTimer.Enabled)) {
                if ($script:leftTimer -and $script:leftTimer.Enabled) { $leftClickBtn.PerformClick() }
                if ($script:rightTimer -and $script:rightTimer.Enabled) { $rightClickBtn.PerformClick() }
            }
            $e.SuppressKeyPress = $true
        }
    }
})

# Footer
$footer = New-Object System.Windows.Forms.Label
$footer.Text = "Charrizard Filless"
$footer.Location = New-Object System.Drawing.Point(0, 320)
$footer.Size = New-Object System.Drawing.Size(360, 20)
$footer.ForeColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
$footer.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$footer.TextAlign = "MiddleCenter"
$form.Controls.Add($footer)

# Messaggio di avvio
Write-Host "Daanii06_ Fileless Clicker" -ForegroundColor Red
Write-Host "Loaded successfully!" -ForegroundColor White

# Mostra il form
[void]$form.ShowDialog()
