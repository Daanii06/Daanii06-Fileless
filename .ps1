Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Funzione per convertire base64 a immagine (Zekrom)
function Convert-Base64ToImage {
    param([string]$base64String)
    $bytes = [Convert]::FromBase64String($base64String)
    $ms = New-Object System.IO.MemoryStream($bytes, 0, $bytes.Length)
    $ms.Write($bytes, 0, $bytes.Length)
    $img = [System.Drawing.Image]::FromStream($ms, $true)
    return $img
}

# Base64 dell'immagine Zekrom (versione minimal in bianco e nero)
$zekromBase64 = "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAA7AAAAOwBeShxvQAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAUFSURBVFiFzZdbbBRVGMf/s7szW7rd7ZYCpVwK2CY1YIhY2iiaaHzRB4m+KEZiNBofNJCYKBE1vkgw0Rc0vuiL94co3mh8MBriAzG1iTFNaGJslFhrY2tLpS3d3Z2d2Zk53g/T7bbd7g7b4kP/ybycOd/5nzP/mfOdbwR8+PDhw4cPHz58eIwYEYC3lxQpAgAeK9wbsFQAILP52ToLgPNPrucL91rHbyo8/fptC1m90pWry08Grz+V7n1k5r0WAMCbR1rE1o+zI22Hc6k1T19O3/7QQPqWfZfTt6y6nL51IJ+8OZZL3AqA32QB2PpU42Qsk/5l9Y0zF1Y3zFxa1TBzeVXD7OXKhplgZf1MMJzLBMO5TLA2nw3Gc5lgPJcJNl7uTd/Q0J+5MQBgo39NFq1pnr7Y2DRzubpx5kp1w8yVqoYZqK6fRah+FuF8NlgLAJX0rq6fQRiAaKphMrKucyxS1XgJQM0WQRU7P7oZ8dau4etN3ZciTd2XItFdZxHNpALRRFOouj8VqO7PBiL9uUAgmQ4G7GtBIJkOBpLpUGAgn6s60pPeGoBzCwCgY0M9+sz62qXLay5dXVZz6eqy6sarlyvrriFUPwEzmQpGAdhO5zOBcD4TCOczgXA+EwjnM4FwPp8JpvKZYGNmOn1TY34mCgBPzwcAgN27d+PFF1/Ehx9+iC+//BIbN25ES0uLp8KJRGKeAACe2tGOD1/fgY/e2I7drz6BzS0hT2M9+XS7Z6tYW1uLZ599Fu3t7Th37hzOnj2Lvr4+9Pf349ixY1i+fLmn8Tt33IZIxUzMZRlVK6rU1Yt9/fXXaGlpwenTp7Fjxw4cPnwYXV1d6O7uxq5du7Bp0ybP5KPRKJqamrB582a8//77yGazeP7559Hb24tr166ht7cXmzZtQjQa9US+d/cvB2bPHjWyuZz0VN7R0YG1a9eir68PH3/8Ma5cuYJ0Oo2+vj58+eWXaGpq8lS+rq4OqVQK6XQa6XQayWQSZ86cwd69e3Hs2DF0dXXh6tWrmJmZ8UR+76YVx4EacNZZW0sybwVffvkl1q1bh/HxcTz//PMYGBjA5OQkJicn0d/fj5deegkDAwOeyT/44IMYGBhAJpPBuXPnMDk5iWQyicnJSUxOTuKDDz7A2rVrPZHfs3H5z8qT6Jw1o/X2pQhqPJQfHR3FiRMnMDIyglQqBdu2Yds2RkZGcOLECYyNjXkiv2P9stNYXYmDq+rRWWMr32JRq9di27Zt2LJlCzZv3ozW1lY0NjYil8uho6MDW7ZswebNm9Ha2gqllCfy7WvCvwPYj3tuQKjSwuBkFkNhC+8GzHkCbW1taGpqQmNjI5RSsCwLwWAQjY2NaGpqQltbG4LBoCfyqyJzAPDnYhNc1TCDsYyNWJWNb6tNvBMw8fm/PvF8/T4AHP/0VixdZM2VTBkbN9YaWGTM19+1a5e8+uqr8uijj8rDDz8sW7dulR07dsiOHTvk0Ucflddee02y2awr8tlLk/Ld4B35Z2ZOYv/+/XLw4EHp6uqSY8eOSTKZdEW+Z2PdAXANgI5sCpvX3eCqgKqqKqxZswZKKQghoJSCZVlYvXo1qqurXZOP1gXXAohms6iuNmHbtsRiMQSDQYTDYdTW1iKXyyEej7siv2hBZS5S8zRGAQBlZSHMzs4im81ifHwcpmliZmYGs7OzyGazmJiYwOzsrCvyS0MVTwGgrV4hWj6N1c0P4KPT31fcDyGEB+ryBcDn3z6GYgMh5l5T9hP5gmn4AODDhw8fPnz48OEDwH8u1B8mLp5T2gAAAABJRU5ErkJggg=="

# Creazione del form principale
$form = New-Object System.Windows.Forms.Form
$form.Text = "By Made Daanii06_ "
$form.Size = New-Object System.Drawing.Size(380, 380)  # Leggermente più grande
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None"
$form.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 10)
$form.TopMost = $true
$form.KeyPreview = $true

# Pannello di trascinamento
$dragPanel = New-Object System.Windows.Forms.Panel
$dragPanel.Location = New-Object System.Drawing.Point(0, 0)
$dragPanel.Size = New-Object System.Drawing.Size(380, 60)  # Più alto per l'immagine più grande
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
$buttonClose.Location = New-Object System.Drawing.Point(345, 15)  # Aggiustato per le nuove dimensioni
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

# Immagine Zekrom (PIÙ GRANDE)
$pictureBox = New-Object System.Windows.Forms.PictureBox
$pictureBox.Location = New-Object System.Drawing.Point(15, 10)  # Leggermente spostato
$pictureBox.Size = New-Object System.Drawing.Size(48, 40)  # AUMENTATO da 32x32 a 48x40
$pictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom  # Cambiato in Zoom per mantenere le proporzioni
$pictureBox.Image = Convert-Base64ToImage -base64String $zekromBase64
$dragPanel.Controls.Add($pictureBox)

# Titolo (aggiustato per l'immagine più grande)
$labelTitle = New-Object System.Windows.Forms.Label
$labelTitle.Text = "ZEKROM FILELESS"
$labelTitle.Location = New-Object System.Drawing.Point(70, 15)  # Spostato più a destra
$labelTitle.Size = New-Object System.Drawing.Size(230, 30)
$labelTitle.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)  # Font più grande
$labelTitle.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$labelTitle.TextAlign = "MiddleLeft"
$dragPanel.Controls.Add($labelTitle)

# Separatore con gradiente (bianco) - aggiustato per le nuove dimensioni
$separator = New-Object System.Windows.Forms.Panel
$separator.Location = New-Object System.Drawing.Point(40, 90)
$separator.Size = New-Object System.Drawing.Size(300, 2)
$separator.BackColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$form.Controls.Add($separator)

# Left click button (aggiustato)
$leftClickBtn = New-Object System.Windows.Forms.Button
$leftClickBtn.Text = "LEFT CLICK"
$leftClickBtn.Location = New-Object System.Drawing.Point(40, 120)
$leftClickBtn.Size = New-Object System.Drawing.Size(140, 45)  # Leggermente più grandi
$leftClickBtn.FlatStyle = "Flat"
$leftClickBtn.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$leftClickBtn.FlatAppearance.BorderSize = 1
$leftClickBtn.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 10)
$leftClickBtn.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$leftClickBtn.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)  # Font più grande
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
        $leftClickBtn.BackColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
        $leftClickBtn.ForeColor = [System.Drawing.Color]::FromArgb(10, 10, 10)
        $leftClickBtn.Text = "LEFT ON"
        $leftClickBtn.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(10, 10, 10)
    }
})
$form.Controls.Add($leftClickBtn)

# Right click button (aggiustato)
$rightClickBtn = New-Object System.Windows.Forms.Button
$rightClickBtn.Text = "RIGHT CLICK"
$rightClickBtn.Location = New-Object System.Drawing.Point(200, 120)  # Aggiustato
$rightClickBtn.Size = New-Object System.Drawing.Size(140, 45)  # Leggermente più grandi
$rightClickBtn.FlatStyle = "Flat"
$rightClickBtn.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$rightClickBtn.FlatAppearance.BorderSize = 1
$rightClickBtn.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 10)
$rightClickBtn.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$rightClickBtn.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)  # Font più grande
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
        $rightClickBtn.BackColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
        $rightClickBtn.ForeColor = [System.Drawing.Color]::FromArgb(10, 10, 10)
        $rightClickBtn.Text = "RIGHT ON"
        $rightClickBtn.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(10, 10, 10)
    }
})
$form.Controls.Add($rightClickBtn)

# Speed control label (aggiustato)
$speedLabel = New-Object System.Windows.Forms.Label
$speedLabel.Text = "CLICK SPEED (MS)"
$speedLabel.Location = New-Object System.Drawing.Point(40, 185)
$speedLabel.Size = New-Object System.Drawing.Size(300, 20)
$speedLabel.ForeColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
$speedLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$speedLabel.TextAlign = "MiddleCenter"
$form.Controls.Add($speedLabel)

# Speed display (aggiustato)
$speedDisplay = New-Object System.Windows.Forms.Label
$speedDisplay.Text = "50"
$speedDisplay.Location = New-Object System.Drawing.Point(40, 205)
$speedDisplay.Size = New-Object System.Drawing.Size(300, 35)
$speedDisplay.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$speedDisplay.Font = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)  # Font più grande
$speedDisplay.TextAlign = "MiddleCenter"
$form.Controls.Add($speedDisplay)

# Speed trackbar (aggiustato)
$trackbar = New-Object System.Windows.Forms.TrackBar
$trackbar.Location = New-Object System.Drawing.Point(40, 250)
$trackbar.Size = New-Object System.Drawing.Size(300, 45)
$trackbar.Minimum = 10
$trackbar.Maximum = 200
$trackbar.Value = 50
$trackbar.TickFrequency = 10
$trackbar.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 10)
$trackbar.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$trackbar.Add_ValueChanged({
    $speedDisplay.Text = $trackbar.Value.ToString()
    if ($script:leftTimer) { $script:leftTimer.Interval = $trackbar.Value }
    if ($script:rightTimer) { $script:rightTimer.Interval = $trackbar.Value }
})
$form.Controls.Add($trackbar)

# Hotkeys info (aggiustato)
$hotkeysLabel = New-Object System.Windows.Forms.Label
$hotkeysLabel.Text = "HOTKEYS: F6 (LEFT) | F7 (RIGHT) | F8 (STOP)"
$hotkeysLabel.Location = New-Object System.Drawing.Point(40, 310)
$hotkeysLabel.Size = New-Object System.Drawing.Size(300, 25)
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

# Footer (aggiustato)
$footer = New-Object System.Windows.Forms.Label
$footer.Text = "BY DAANII06_"
$footer.Location = New-Object System.Drawing.Point(0, 350)
$footer.Size = New-Object System.Drawing.Size(380, 20)
$footer.ForeColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
$footer.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$footer.TextAlign = "MiddleCenter"
$form.Controls.Add($footer)

# Messaggio di avvio
Write-Host "╔════════════════════════════════════╗" -ForegroundColor White
Write-Host "║     ZEKROM FILELESS CLICKER       ║" -ForegroundColor White
Write-Host "║         BY DAANII06_               ║" -ForegroundColor White
Write-Host "╚════════════════════════════════════╝" -ForegroundColor White
Write-Host "Loaded successfully!" -ForegroundColor Green

# Mostra il form
[void]$form.ShowDialog()
