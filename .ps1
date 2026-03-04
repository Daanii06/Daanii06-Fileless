Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

if (-not ([System.Management.Automation.PSTypeName]'InputSimulator').Type) {
    Add-Type @"
using System;
using System.Runtime.InteropServices;

public class InputSimulator {
    [DllImport("user32.dll")]
    static extern uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);

    [StructLayout(LayoutKind.Sequential)]
    struct INPUT {
        public uint type;
        public MOUSEINPUT mi;
    }

    [StructLayout(LayoutKind.Sequential)]
    struct MOUSEINPUT {
        public int dx;
        public int dy;
        public uint mouseData;
        public uint dwFlags;
        public uint time;
        public IntPtr dwExtraInfo;
    }

    const uint INPUT_MOUSE = 0;
    const uint MOUSEEVENTF_LEFTDOWN = 0x0002;
    const uint MOUSEEVENTF_LEFTUP = 0x0004;
    const uint MOUSEEVENTF_RIGHTDOWN = 0x0008;
    const uint MOUSEEVENTF_RIGHTUP = 0x0010;

    public static void LeftClick() {
        INPUT[] inputs = new INPUT[2];
        inputs[0].type = INPUT_MOUSE;
        inputs[0].mi.dwFlags = MOUSEEVENTF_LEFTDOWN;
        inputs[1].type = INPUT_MOUSE;
        inputs[1].mi.dwFlags = MOUSEEVENTF_LEFTUP;
        SendInput(2, inputs, Marshal.SizeOf(typeof(INPUT)));
    }

    public static void RightClick() {
        INPUT[] inputs = new INPUT[2];
        inputs[0].type = INPUT_MOUSE;
        inputs[0].mi.dwFlags = MOUSEEVENTF_RIGHTDOWN;
        inputs[1].type = INPUT_MOUSE;
        inputs[1].mi.dwFlags = MOUSEEVENTF_RIGHTUP;
        SendInput(2, inputs, Marshal.SizeOf(typeof(INPUT)));
    }
}

public class GlobalHotkey {
    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int vKey);

    public static bool IsKeyPressed(int vKey) {
        return (GetAsyncKeyState(vKey) & 0x8000) != 0;
    }
}
"@
}

$script:leftClickActive = $false
$script:rightClickActive = $false
$script:leftClickKey = 0
$script:rightClickKey = 0
$script:capturingLeftKey = $false
$script:capturingRightKey = $false
$script:leftTimer = $null
$script:rightTimer = $null
$script:keyCheckTimer = $null
$script:leftCPS = 10
$script:rightCPS = 10
$script:isDraggingLeft = $false
$script:isDraggingRight = $false
$script:isDraggingForm = $false
$script:dragStartPoint = $null

$script:keyMap = @{
    'F1' = 0x70; 'F2' = 0x71; 'F3' = 0x72; 'F4' = 0x73; 'F5' = 0x74; 'F6' = 0x75
    'F7' = 0x76; 'F8' = 0x77; 'F9' = 0x78; 'F10' = 0x79; 'F11' = 0x7A; 'F12' = 0x7B
    'A' = 0x41; 'B' = 0x42; 'C' = 0x43; 'D' = 0x44; 'E' = 0x45; 'F' = 0x46
    'G' = 0x47; 'H' = 0x48; 'I' = 0x49; 'J' = 0x4A; 'K' = 0x4B; 'L' = 0x4C
    'M' = 0x4D; 'N' = 0x4E; 'O' = 0x4F; 'P' = 0x50; 'Q' = 0x51; 'R' = 0x52
    'S' = 0x53; 'T' = 0x54; 'U' = 0x55; 'V' = 0x56; 'W' = 0x57; 'X' = 0x58
    'Y' = 0x59; 'Z' = 0x5A
    'D0' = 0x30; 'D1' = 0x31; 'D2' = 0x32; 'D3' = 0x33; 'D4' = 0x34
    'D5' = 0x35; 'D6' = 0x36; 'D7' = 0x37; 'D8' = 0x38; 'D9' = 0x39
    'Space' = 0x20; 'Shift' = 0x10; 'Control' = 0x11; 'Alt' = 0x12
    'XButton1' = 0x05; 'XButton2' = 0x06
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "Sneaky Clicker"
$form.Size = New-Object System.Drawing.Size(360, 360)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 10)
$form.FormBorderStyle = "None"
$form.MaximizeBox = $false
$form.KeyPreview = $true
$form.TopMost = $true

# Panel per il trascinamento della finestra
$dragPanel = New-Object System.Windows.Forms.Panel
$dragPanel.Location = New-Object System.Drawing.Point(0, 0)
$dragPanel.Size = New-Object System.Drawing.Size(360, 40)
$dragPanel.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
$dragPanel.Cursor = [System.Windows.Forms.Cursors]::SizeAll
$form.Controls.Add($dragPanel)

$dragPanel.Add_MouseDown({
    $script:isDraggingForm = $true
    $script:dragStartPoint = New-Object System.Drawing.Point($_.X, $_.Y)
})

$dragPanel.Add_MouseMove({
    if ($script:isDraggingForm) {
        $currentPos = $form.PointToScreen([System.Drawing.Point]::Empty)
        $newX = $currentPos.X + ($_.X - $script:dragStartPoint.X)
        $newY = $currentPos.Y + ($_.Y - $script:dragStartPoint.Y)
        $form.Location = New-Object System.Drawing.Point($newX, $newY)
    }
})

$dragPanel.Add_MouseUp({
    $script:isDraggingForm = $false
})

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
    if ($script:keyCheckTimer) { $script:keyCheckTimer.Stop(); $script:keyCheckTimer.Dispose() }
    $form.Close()
})
$dragPanel.Controls.Add($buttonClose)

# Titolo con effetto glow
$labelTitle = New-Object System.Windows.Forms.Label
$labelTitle.Text = "SNEAKY CLICKER"
$labelTitle.Location = New-Object System.Drawing.Point(40, 5)
$labelTitle.Size = New-Object System.Drawing.Size(240, 30)
$labelTitle.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$labelTitle.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$labelTitle.TextAlign = "MiddleCenter"
$dragPanel.Controls.Add($labelTitle)

# Made by
$madeByLabel = New-Object System.Windows.Forms.Label
$madeByLabel.Text = "By Made Daanii06_ Fileless"
$madeByLabel.Location = New-Object System.Drawing.Point(80, 40)
$madeByLabel.Size = New-Object System.Drawing.Size(200, 20)
$madeByLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
$madeByLabel.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
$madeByLabel.TextAlign = "MiddleCenter"
$form.Controls.Add($madeByLabel)

# Separatore con gradiente
$separator = New-Object System.Windows.Forms.Panel
$separator.Location = New-Object System.Drawing.Point(30, 70)
$separator.Size = New-Object System.Drawing.Size(300, 2)
$separator.BackColor = [System.Drawing.Color]::FromArgb(255, 60, 60)
$form.Controls.Add($separator)

# Left click section
$labelLeftClick = New-Object System.Windows.Forms.Label
$labelLeftClick.Text = "LEFT CLICK"
$labelLeftClick.Location = New-Object System.Drawing.Point(40, 90)
$labelLeftClick.Size = New-Object System.Drawing.Size(100, 25)
$labelLeftClick.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$labelLeftClick.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$form.Controls.Add($labelLeftClick)

$buttonLeftKey = New-Object System.Windows.Forms.Button
$buttonLeftKey.Text = "NONE"
$buttonLeftKey.Location = New-Object System.Drawing.Point(150, 88)
$buttonLeftKey.Size = New-Object System.Drawing.Size(70, 28)
$buttonLeftKey.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$buttonLeftKey.ForeColor = [System.Drawing.Color]::White
$buttonLeftKey.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
$buttonLeftKey.FlatStyle = "Flat"
$buttonLeftKey.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255, 60, 60)
$buttonLeftKey.FlatAppearance.BorderSize = 1
$buttonLeftKey.Cursor = [System.Windows.Forms.Cursors]::Hand
$buttonLeftKey.Add_Click({
    $buttonLeftKey.Text = "..."
    $buttonLeftKey.BackColor = [System.Drawing.Color]::FromArgb(80, 40, 40)
    $script:capturingLeftKey = $true
    $labelStatus.Text = "Press key for LEFT CLICK..."
})
$form.Controls.Add($buttonLeftKey)

$labelLeftCount = New-Object System.Windows.Forms.Label
$labelLeftCount.Text = "10 CPS"
$labelLeftCount.Location = New-Object System.Drawing.Point(235, 90)
$labelLeftCount.Size = New-Object System.Drawing.Size(80, 25)
$labelLeftCount.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$labelLeftCount.ForeColor = [System.Drawing.Color]::FromArgb(255, 100, 100)
$labelLeftCount.TextAlign = "MiddleRight"
$form.Controls.Add($labelLeftCount)

$panelLeftBar = New-Object System.Windows.Forms.Panel
$panelLeftBar.Location = New-Object System.Drawing.Point(40, 125)
$panelLeftBar.Size = New-Object System.Drawing.Size(275, 15)
$panelLeftBar.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$panelLeftBar.Cursor = [System.Windows.Forms.Cursors]::Hand

$panelLeftBar.Add_MouseDown({
    param($sender, $e)
    $script:isDraggingLeft = $true
    $clickX = [math]::Max(0, [math]::Min(275, $e.X))
    $newCPS = [math]::Max(1, [math]::Min(200, [int](($clickX / 275.0) * 200) + 1))
    $script:leftCPS = $newCPS
    $labelLeftCount.Text = "$($script:leftCPS) CPS"
    $newWidth = [int](275 * ($script:leftCPS / 200.0))
    $panelLeftProgress.Width = $newWidth
})

$panelLeftBar.Add_MouseMove({
    param($sender, $e)
    if ($script:isDraggingLeft) {
        $clickX = [math]::Max(0, [math]::Min(275, $e.X))
        $newCPS = [math]::Max(1, [math]::Min(200, [int](($clickX / 275.0) * 200) + 1))
        $script:leftCPS = $newCPS
        $labelLeftCount.Text = "$($script:leftCPS) CPS"
        $newWidth = [int](275 * ($script:leftCPS / 200.0))
        $panelLeftProgress.Width = $newWidth
    }
})

$panelLeftBar.Add_MouseUp({
    param($sender, $e)
    $script:isDraggingLeft = $false
})

$form.Add_MouseUp({
    $script:isDraggingLeft = $false
    $script:isDraggingRight = $false
})

$form.Controls.Add($panelLeftBar)

$panelLeftProgress = New-Object System.Windows.Forms.Panel
$panelLeftProgress.Location = New-Object System.Drawing.Point(0, 0)
$panelLeftProgress.Size = New-Object System.Drawing.Size(14, 15)
$panelLeftProgress.BackColor = [System.Drawing.Color]::FromArgb(255, 80, 80)
$panelLeftBar.Controls.Add($panelLeftProgress)

# Right click section
$labelRightClick = New-Object System.Windows.Forms.Label
$labelRightClick.Text = "RIGHT CLICK"
$labelRightClick.Location = New-Object System.Drawing.Point(40, 160)
$labelRightClick.Size = New-Object System.Drawing.Size(110, 25)
$labelRightClick.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$labelRightClick.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$form.Controls.Add($labelRightClick)

$buttonRightKey = New-Object System.Windows.Forms.Button
$buttonRightKey.Text = "NONE"
$buttonRightKey.Location = New-Object System.Drawing.Point(150, 158)
$buttonRightKey.Size = New-Object System.Drawing.Size(70, 28)
$buttonRightKey.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$buttonRightKey.ForeColor = [System.Drawing.Color]::White
$buttonRightKey.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
$buttonRightKey.FlatStyle = "Flat"
$buttonRightKey.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255, 60, 60)
$buttonRightKey.FlatAppearance.BorderSize = 1
$buttonRightKey.Cursor = [System.Windows.Forms.Cursors]::Hand
$buttonRightKey.Add_Click({
    $buttonRightKey.Text = "..."
    $buttonRightKey.BackColor = [System.Drawing.Color]::FromArgb(80, 40, 40)
    $script:capturingRightKey = $true
    $labelStatus.Text = "Press key for RIGHT CLICK..."
})
$form.Controls.Add($buttonRightKey)

$labelRightCount = New-Object System.Windows.Forms.Label
$labelRightCount.Text = "10 CPS"
$labelRightCount.Location = New-Object System.Drawing.Point(235, 160)
$labelRightCount.Size = New-Object System.Drawing.Size(80, 25)
$labelRightCount.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$labelRightCount.ForeColor = [System.Drawing.Color]::FromArgb(255, 100, 100)
$labelRightCount.TextAlign = "MiddleRight"
$form.Controls.Add($labelRightCount)

$panelRightBar = New-Object System.Windows.Forms.Panel
$panelRightBar.Location = New-Object System.Drawing.Point(40, 195)
$panelRightBar.Size = New-Object System.Drawing.Size(275, 15)
$panelRightBar.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$panelRightBar.Cursor = [System.Windows.Forms.Cursors]::Hand

$panelRightBar.Add_MouseDown({
    param($sender, $e)
    $script:isDraggingRight = $true
    $clickX = [math]::Max(0, [math]::Min(275, $e.X))
    $newCPS = [math]::Max(1, [math]::Min(200, [int](($clickX / 275.0) * 200) + 1))
    $script:rightCPS = $newCPS
    $labelRightCount.Text = "$($script:rightCPS) CPS"
    $newWidth = [int](275 * ($script:rightCPS / 200.0))
    $panelRightProgress.Width = $newWidth
})

$panelRightBar.Add_MouseMove({
    param($sender, $e)
    if ($script:isDraggingRight) {
        $clickX = [math]::Max(0, [math]::Min(275, $e.X))
        $newCPS = [math]::Max(1, [math]::Min(200, [int](($clickX / 275.0) * 200) + 1))
        $script:rightCPS = $newCPS
        $labelRightCount.Text = "$($script:rightCPS) CPS"
        $newWidth = [int](275 * ($script:rightCPS / 200.0))
        $panelRightProgress.Width = $newWidth
    }
})

$panelRightBar.Add_MouseUp({
    param($sender, $e)
    $script:isDraggingRight = $false
})

$form.Controls.Add($panelRightBar)

$panelRightProgress = New-Object System.Windows.Forms.Panel
$panelRightProgress.Location = New-Object System.Drawing.Point(0, 0)
$panelRightProgress.Size = New-Object System.Drawing.Size(14, 15)
$panelRightProgress.BackColor = [System.Drawing.Color]::FromArgb(255, 80, 80)
$panelRightBar.Controls.Add($panelRightProgress)

# Status panel
$statusPanel = New-Object System.Windows.Forms.Panel
$statusPanel.Location = New-Object System.Drawing.Point(40, 235)
$statusPanel.Size = New-Object System.Drawing.Size(275, 50)
$statusPanel.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
$form.Controls.Add($statusPanel)

$labelStatus = New-Object System.Windows.Forms.Label
$labelStatus.Text = "READY"
$labelStatus.Location = New-Object System.Drawing.Point(10, 15)
$labelStatus.Size = New-Object System.Drawing.Size(255, 20)
$labelStatus.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$labelStatus.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
$labelStatus.TextAlign = "MiddleCenter"
$statusPanel.Controls.Add($labelStatus)

# Status indicator
$statusIndicator = New-Object System.Windows.Forms.Panel
$statusIndicator.Location = New-Object System.Drawing.Point(5, 20)
$statusIndicator.Size = New-Object System.Drawing.Size(8, 8)
$statusIndicator.BackColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
$statusPanel.Controls.Add($statusIndicator)

# Key mapping functions
function Toggle-LeftClick {
    $script:leftClickActive = -not $script:leftClickActive
    if ($script:leftClickActive) {
        $buttonLeftKey.BackColor = [System.Drawing.Color]::FromArgb(120, 40, 40)
        $buttonLeftKey.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255, 150, 150)
        $labelStatus.Text = "LEFT CLICK ACTIVE"
        $labelStatus.ForeColor = [System.Drawing.Color]::FromArgb(255, 100, 100)
        $statusIndicator.BackColor = [System.Drawing.Color]::FromArgb(255, 80, 80)
        
        $interval = [math]::Max(1, [int](1000 / $script:leftCPS))
        if ($script:leftTimer) {
            $script:leftTimer.Stop()
            $script:leftTimer.Dispose()
        }
        $script:leftTimer = New-Object System.Windows.Forms.Timer
        $script:leftTimer.Interval = $interval
        $script:leftTimer.Add_Tick({
            [InputSimulator]::LeftClick()
        })
        $script:leftTimer.Start()
    } else {
        $buttonLeftKey.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
        $buttonLeftKey.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255, 60, 60)
        if (-not $script:rightClickActive) {
            $labelStatus.Text = "READY"
            $labelStatus.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
            $statusIndicator.BackColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
        }
        if ($script:leftTimer) {
            $script:leftTimer.Stop()
        }
    }
}

function Toggle-RightClick {
    $script:rightClickActive = -not $script:rightClickActive
    if ($script:rightClickActive) {
        $buttonRightKey.BackColor = [System.Drawing.Color]::FromArgb(120, 40, 40)
        $buttonRightKey.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255, 150, 150)
        $labelStatus.Text = "RIGHT CLICK ACTIVE"
        $labelStatus.ForeColor = [System.Drawing.Color]::FromArgb(255, 100, 100)
        $statusIndicator.BackColor = [System.Drawing.Color]::FromArgb(255, 80, 80)
        
        $interval = [math]::Max(1, [int](1000 / $script:rightCPS))
        if ($script:rightTimer) {
            $script:rightTimer.Stop()
            $script:rightTimer.Dispose()
        }
        $script:rightTimer = New-Object System.Windows.Forms.Timer
        $script:rightTimer.Interval = $interval
        $script:rightTimer.Add_Tick({
            [InputSimulator]::RightClick()
        })
        $script:rightTimer.Start()
    } else {
        $buttonRightKey.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
        $buttonRightKey.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255, 60, 60)
        if (-not $script:leftClickActive) {
            $labelStatus.Text = "READY"
            $labelStatus.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
            $statusIndicator.BackColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
        }
        if ($script:rightTimer) {
            $script:rightTimer.Stop()
        }
    }
}

$form.Add_KeyDown({
    param($sender, $e)
    if ($script:capturingLeftKey) {
        $keyString = $e.KeyCode.ToString()
        if ($script:keyMap.ContainsKey($keyString)) {
            $script:leftClickKey = $script:keyMap[$keyString]
            $buttonLeftKey.Text = $keyString
            $buttonLeftKey.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
            $labelStatus.Text = "Left key set: $keyString"
            $labelStatus.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
            $script:capturingLeftKey = $false
            $script:ignoreNextLeftPress = $true
        }
    } elseif ($script:capturingRightKey) {
        $keyString = $e.KeyCode.ToString()
        if ($script:keyMap.ContainsKey($keyString)) {
            $script:rightClickKey = $script:keyMap[$keyString]
            $buttonRightKey.Text = $keyString
            $buttonRightKey.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
            $labelStatus.Text = "Right key set: $keyString"
            $labelStatus.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
            $script:capturingRightKey = $false
            $script:ignoreNextRightPress = $true
        }
    }
})

$script:keyCheckTimer = New-Object System.Windows.Forms.Timer
$script:keyCheckTimer.Interval = 50
$script:leftKeyWasPressed = $false
$script:rightKeyWasPressed = $false
$script:ignoreNextLeftPress = $false
$script:ignoreNextRightPress = $false

$script:keyCheckTimer.Add_Tick({
    if ($script:leftClickKey -ne 0) {
        $isPressed = [GlobalHotkey]::IsKeyPressed($script:leftClickKey)
        if ($isPressed -and -not $script:leftKeyWasPressed) {
            if (-not $script:ignoreNextLeftPress) {
                Toggle-LeftClick
            } else {
                $script:ignoreNextLeftPress = $false
            }
            $script:leftKeyWasPressed = $true
        } elseif (-not $isPressed) {
            $script:leftKeyWasPressed = $false
        }
    }
    
    if ($script:rightClickKey -ne 0) {
        $isPressed = [GlobalHotkey]::IsKeyPressed($script:rightClickKey)
        if ($isPressed -and -not $script:rightKeyWasPressed) {
            if (-not $script:ignoreNextRightPress) {
                Toggle-RightClick
            } else {
                $script:ignoreNextRightPress = $false
            }
            $script:rightKeyWasPressed = $true
        } elseif (-not $isPressed) {
            $script:rightKeyWasPressed = $false
        }
    }
})

$script:keyCheckTimer.Start()

$form.Add_FormClosing({
    if ($script:leftTimer) { $script:leftTimer.Stop(); $script:leftTimer.Dispose() }
    if ($script:rightTimer) { $script:rightTimer.Stop(); $script:rightTimer.Dispose() }
    if ($script:keyCheckTimer) { $script:keyCheckTimer.Stop(); $script:keyCheckTimer.Dispose() }
})

Write-Host "Sneaky Clicker v2.0 - Made by Daanii06_ Fileless" -ForegroundColor Red
Write-Host "Theme: Red & Black Edition" -ForegroundColor White
[void]$form.ShowDialog()
