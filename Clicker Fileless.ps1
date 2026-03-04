Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Creazione del form principale
$form = New-Object System.Windows.Forms.Form
$form.Text = "By Made Daanii06_ "
$form.Size = New-Object System.Drawing.Size(360, 400)  # Altezza aumentata per i nuovi controlli
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None"
$form.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 10)  # Nero più profondo
$form.TopMost = $true
$form.KeyPreview = $true

# Variabili per il trascinamento
$script:dragging = $false
$script:offsetX = 0
$script:offsetY = 0

# Variabili per il click rate
$script:clickCount = 0
$script:lastCpsUpdate = (Get-Date)

# Eventi per il trascinamento su tutto il form
$form.Add_MouseDown({
    param($sender, $e)
    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        $script:dragging = $true
        $script:offsetX = $e.X
        $script:offsetY = $e.Y
    }
})

$form.Add_MouseMove({
    param($sender, $e)
    if ($script:dragging) {
        $form.Location = New-Object System.Drawing.Point(
            ($form.Location.X + $e.X - $script:offsetX),
            ($form.Location.Y + $e.Y - $script:offsetY)
        )
    }
})

$form.Add_MouseUp({
    param($sender, $e)
    $script:dragging = $false
})

# Pannello di trascinamento superiore
$dragPanel = New-Object System.Windows.Forms.Panel
$dragPanel.Location = New-Object System.Drawing.Point(0, 0)
$dragPanel.Size = New-Object System.Drawing.Size(360, 40)
$dragPanel.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
$dragPanel.Cursor = [System.Windows.Forms.Cursors]::SizeAll

# Eventi per il trascinamento dal pannello
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
$buttonClose.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$buttonClose.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$buttonClose.Cursor = [System.Windows.Forms.Cursors]::Hand
$buttonClose.Add_MouseEnter({ $buttonClose.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180) })
$buttonClose.Add_MouseLeave({ $buttonClose.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255) })
$buttonClose.Add_Click({
    if ($script:leftTimer) { $script:leftTimer.Stop(); $script:leftTimer.Dispose() }
    if ($script:rightTimer) { $script:rightTimer.Stop(); $script:rightTimer.Dispose() }
    $form.Close()
})
$dragPanel.Controls.Add($buttonClose)

# Titolo
$labelTitle = New-Object System.Windows.Forms.Label
$labelTitle.Text = "ZEKROM FILELESS"
$labelTitle.Location = New-Object System.Drawing.Point(0, 5)
$labelTitle.Size = New-Object System.Drawing.Size(360, 30)
$labelTitle.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$labelTitle.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$labelTitle.TextAlign = "MiddleCenter"
$dragPanel.Controls.Add($labelTitle)

# Separatore
$separator = New-Object System.Windows.Forms.Panel
$separator.Location = New-Object System.Drawing.Point(30, 70)
$separator.Size = New-Object System.Drawing.Size(300, 2)
$separator.BackColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$form.Controls.Add($separator)

# Pannello per i controlli CPS
$cpsPanel = New-Object System.Windows.Forms.Panel
$cpsPanel.Location = New-Object System.Drawing.Point(40, 80)
$cpsPanel.Size = New-Object System.Drawing.Size(280, 60)
$cpsPanel.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
$form.Controls.Add($cpsPanel)

# Label CPS
$cpsLabel = New-Object System.Windows.Forms.Label
$cpsLabel.Text = "CPS (Click Per Second)"
$cpsLabel.Location = New-Object System.Drawing.Point(10, 5)
$cpsLabel.Size = New-Object System.Drawing.Size(260, 20)
$cpsLabel.ForeColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
$cpsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$cpsLabel.TextAlign = "MiddleCenter"
$cpsPanel.Controls.Add($cpsLabel)

# Display CPS
$cpsDisplay = New-Object System.Windows.Forms.Label
$cpsDisplay.Text = "10"
$cpsDisplay.Location = New-Object System.Drawing.Point(10, 25)
$cpsDisplay.Size = New-Object System.Drawing.Size(80, 30)
$cpsDisplay.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$cpsDisplay.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
$cpsDisplay.TextAlign = "MiddleCenter"
$cpsPanel.Controls.Add($cpsDisplay)

# Trackbar CPS
$cpsTrackbar = New-Object System.Windows.Forms.TrackBar
$cpsTrackbar.Location = New-Object System.Drawing.Point(100, 25)
$cpsTrackbar.Size = New-Object System.Drawing.Size(170, 45)
$cpsTrackbar.Minimum = 1
$cpsTrackbar.Maximum = 50
$cpsTrackbar.Value = 10
$cpsTrackbar.TickFrequency = 5
$cpsTrackbar.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
$cpsTrackbar.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$cpsTrackbar.Add_ValueChanged({
    $cpsDisplay.Text = $cpsTrackbar.Value.ToString()
    $trackbar.Value = [math]::Round(1000 / $cpsTrackbar.Value)
    $speedDisplay.Text = $trackbar.Value
    if ($script:leftTimer) { $script:leftTimer.Interval = $trackbar.Value }
    if ($script:rightTimer) { $script:rightTimer.Interval = $trackbar.Value }
})
$cpsPanel.Controls.Add($cpsTrackbar)

# Left click button
$leftClickBtn = New-Object System.Windows.Forms.Button
$leftClickBtn.Text = "LEFT CLICK"
$leftClickBtn.Location = New-Object System.Drawing.Point(40, 150)
$leftClickBtn.Size = New-Object System.Drawing.Size(130, 40)
$leftClickBtn.FlatStyle = "Flat"
$leftClickBtn.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$leftClickBtn.FlatAppearance.BorderSize = 1
$leftClickBtn.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 10)
$leftClickBtn.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$leftClickBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$leftClickBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
$leftClickBtn.Add_MouseEnter({ $leftClickBtn.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30) })
$leftClickBtn.Add_MouseLeave({ $leftClickBtn.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 10) })
$leftClickBtn.Add_Click({
    if ($script:leftTimer -and $script:leftTimer.Enabled) {
        $script:leftTimer.Stop()
        $leftClickBtn.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 10)
        $leftClickBtn.ForeColor = [System.Drawing.Color]::White
        $leftClickBtn.Text = "LEFT CLICK"
        $leftClickBtn.FlatAppearance.BorderColor = [System.Drawing.Color]::White
    } else {
        $script:leftTimer = New-Object System.Windows.Forms.Timer
        $script:leftTimer.Interval = $trackbar.Value
        $script:leftTimer.Add_Tick({
            $script:clickCount++
            [System.Windows.Forms.Cursor]::Position = [System.Windows.Forms.Cursor]::Position
            Add-Type -AssemblyName System.Windows.Forms
            $signature = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, CallingConvention=CallingConvention.StdCall)]
public static extern void mouse_event(long dwFlags, long dx, long dy, long cButtons, long dwExtraInfo);
'@
            $SendMouseClick = Add-Type -memberDefinition $signature -name "Win32MouseEventNew" -namespace Win32Functions -passthru
            $SendMouseClick::mouse_event(0x00000002, 0, 0, 0, 0)
            $SendMouseClick::mouse_event(0x00000004, 0, 0, 0, 0)
            
            # Aggiorna CPS in tempo reale
            $now = Get-Date
            $elapsed = ($now - $script:lastCpsUpdate).TotalSeconds
            if ($elapsed -ge 1) {
                $realTimeCps = [math]::Round($script:clickCount / $elapsed, 1)
                $leftClickBtn.Text = "LEFT ($realTimeCps CPS)"
                $script:clickCount = 0
                $script:lastCpsUpdate = $now
            }
        })
        $script:leftTimer.Start()
        $leftClickBtn.BackColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
        $leftClickBtn.ForeColor = [System.Drawing.Color]::FromArgb(10, 10, 10)
        $leftClickBtn.Text = "LEFT ON (0 CPS)"
        $leftClickBtn.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(10, 10, 10)
        $script:clickCount = 0
        $script:lastCpsUpdate = Get-Date
    }
})
$form.Controls.Add($leftClickBtn)

# Right click button
$rightClickBtn = New-Object System.Windows.Forms.Button
$rightClickBtn.Text = "RIGHT CLICK"
$rightClickBtn.Location = New-Object System.Drawing.Point(190, 150)
$rightClickBtn.Size = New-Object System.Drawing.Size(130, 40)
$rightClickBtn.FlatStyle = "Flat"
$rightClickBtn.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$rightClickBtn.FlatAppearance.BorderSize = 1
$rightClickBtn.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 10)
$rightClickBtn.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$rightClickBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$rightClickBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
$rightClickBtn.Add_MouseEnter({ $rightClickBtn.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30) })
$rightClickBtn.Add_MouseLeave({ $rightClickBtn.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 10) })
$rightClickBtn.Add_Click({
    if ($script:rightTimer -and $script:rightTimer.Enabled) {
        $script:rightTimer.Stop()
        $rightClickBtn.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 10)
        $rightClickBtn.ForeColor = [System.Drawing.Color]::White
        $rightClickBtn.Text = "RIGHT CLICK"
        $rightClickBtn.FlatAppearance.BorderColor = [System.Drawing.Color]::White
    } else {
        $script:rightTimer = New-Object System.Windows.Forms.Timer
        $script:rightTimer.Interval = $trackbar.Value
        $script:rightTimer.Add_Tick({
            $script:clickCount++
            [System.Windows.Forms.Cursor]::Position = [System.Windows.Forms.Cursor]::Position
            Add-Type -AssemblyName System.Windows.Forms
            $signature = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, CallingConvention=CallingConvention.StdCall)]
public static extern void mouse_event(long dwFlags, long dx, long dy, long cButtons, long dwExtraInfo);
'@
            $SendMouseClick = Add-Type -memberDefinition $signature -name "Win32MouseEventNew" -namespace Win32Functions -passthru
            $SendMouseClick::mouse_event(0x00000008, 0, 0, 0, 0)
            $SendMouseClick::mouse_event(0x00000010, 0, 0, 0, 0)
            
            # Aggiorna CPS in tempo reale
            $now = Get-Date
            $elapsed = ($now - $script:lastCpsUpdate).TotalSeconds
            if ($elapsed -ge 1) {
                $realTimeCps = [math]::Round($script:clickCount / $elapsed, 1)
                $rightClickBtn.Text = "RIGHT ($realTimeCps CPS)"
                $script:clickCount = 0
                $script:lastCpsUpdate = $now
            }
        })
        $script:rightTimer.Start()
        $rightClickBtn.BackColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
        $rightClickBtn.ForeColor = [System.Drawing.Color]::FromArgb(10, 10, 10)
        $rightClickBtn.Text = "RIGHT ON (0 CPS)"
        $rightClickBtn.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(10, 10, 10)
        $script:clickCount = 0
        $script:lastCpsUpdate = Get-Date
    }
})
$form.Controls.Add($rightClickBtn)

# Speed control label
$speedLabel = New-Object System.Windows.Forms.Label
$speedLabel.Text = "CLICK SPEED (MS)"
$speedLabel.Location = New-Object System.Drawing.Point(40, 210)
$speedLabel.Size = New-Object System.Drawing.Size(280, 20)
$speedLabel.ForeColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
$speedLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$speedLabel.TextAlign = "MiddleCenter"
$form.Controls.Add($speedLabel)

# Speed display
$speedDisplay = New-Object System.Windows.Forms.Label
$speedDisplay.Text = "100"
$speedDisplay.Location = New-Object System.Drawing.Point(40, 230)
$speedDisplay.Size = New-Object System.Drawing.Size(280, 30)
$speedDisplay.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$speedDisplay.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
$speedDisplay.TextAlign = "MiddleCenter"
$form.Controls.Add($speedDisplay)

# Speed trackbar
$trackbar = New-Object System.Windows.Forms.TrackBar
$trackbar.Location = New-Object System.Drawing.Point(40, 270)
$trackbar.Size = New-Object System.Drawing.Size(280, 45)
$trackbar.Minimum = 20
$trackbar.Maximum = 1000
$trackbar.Value = 100
$trackbar.TickFrequency = 50
$trackbar.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 10)
$trackbar.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$trackbar.Add_ValueChanged({
    $speedDisplay.Text = $trackbar.Value.ToString()
    $cpsValue = [math]::Round(1000 / $trackbar.Value, 1)
    $cpsDisplay.Text = $cpsValue
    $cpsTrackbar.Value = [math]::Round($cpsValue)
    if ($script:leftTimer) { $script:leftTimer.Interval = $trackbar.Value }
    if ($script:rightTimer) { $script:rightTimer.Interval = $trackbar.Value }
})
$form.Controls.Add($trackbar)

# Hotkeys info
$hotkeysLabel = New-Object System.Windows.Forms.Label
$hotkeysLabel.Text = "HOTKEYS: F6 (LEFT) | F7 (RIGHT) | F8 (STOP)"
$hotkeysLabel.Location = New-Object System.Drawing.Point(40, 330)
$hotkeysLabel.Size = New-Object System.Drawing.Size(280, 30)
$hotkeysLabel.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
$hotkeysLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$hotkeysLabel.TextAlign = "MiddleCenter"
$form.Controls.Add($hotkeysLabel)

# Gestione eventi tastiera
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
$footer.Text = "BY DAANII06_"
$footer.Location = New-Object System.Drawing.Point(0, 370)
$footer.Size = New-Object System.Drawing.Size(360, 20)
$footer.ForeColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
$footer.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$footer.TextAlign = "MiddleCenter"
$form.Controls.Add($footer)

# Messaggio di avvio
Write-Host "╔════════════════════════════════════╗" -ForegroundColor White
Write-Host "║     ZEKROM FILELESS CLICKER       ║" -ForegroundColor White
Write-Host "║         BY DAANII06_               ║" -ForegroundColor White
Write-Host "╚════════════════════════════════════╝" -ForegroundColor White
Write-Host "Loaded successfully! (CPS: 1-50 | Trascina da qualsiasi punto)" -ForegroundColor Green

# Mostra il form
[void]$form.ShowDialog()
