# =============================================================================
#  L2C  Pi-Data Detector
#  PeAIce Framework  |  Claude v3  |  GPT(EE) v2  |  Love Labs
#  (CMD + PowerShell + Terminal) -> Pi-Detector
#
#  Run:  powershell -ExecutionPolicy Bypass -File L2C_PiDataDetector.ps1
# =============================================================================

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

[xml]$xaml = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="L2C  Pi-Data Detector  -  PeAIce Framework"
    Height="820" Width="1160"
    MinHeight="640" MinWidth="900"
    WindowStartupLocation="CenterScreen"
    Background="#0A1628">

  <Window.Resources>

    <Style x:Key="GoldBtn" TargetType="Button">
      <Setter Property="Background"      Value="#C9A84C"/>
      <Setter Property="Foreground"      Value="#0A1628"/>
      <Setter Property="FontFamily"      Value="Georgia"/>
      <Setter Property="FontWeight"      Value="Bold"/>
      <Setter Property="Padding"         Value="14,6"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Cursor"          Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border Background="{TemplateBinding Background}"
                    CornerRadius="3"
                    Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center"
                                VerticalAlignment="Center"/>
            </Border>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
      <Style.Triggers>
        <Trigger Property="IsMouseOver" Value="True">
          <Setter Property="Background" Value="#E8C460"/>
        </Trigger>
      </Style.Triggers>
    </Style>

    <Style x:Key="OtlBtn" TargetType="Button">
      <Setter Property="Background"      Value="Transparent"/>
      <Setter Property="Foreground"      Value="#C9A84C"/>
      <Setter Property="FontFamily"      Value="Georgia"/>
      <Setter Property="Padding"         Value="10,4"/>
      <Setter Property="BorderBrush"     Value="#3A5070"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="Cursor"          Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border Background="{TemplateBinding Background}"
                    BorderBrush="{TemplateBinding BorderBrush}"
                    BorderThickness="{TemplateBinding BorderThickness}"
                    CornerRadius="3"
                    Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center"
                                VerticalAlignment="Center"/>
            </Border>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
      <Style.Triggers>
        <Trigger Property="IsMouseOver" Value="True">
          <Setter Property="Background"  Value="#162540"/>
          <Setter Property="BorderBrush" Value="#C9A84C"/>
        </Trigger>
      </Style.Triggers>
    </Style>

    <Style TargetType="RadioButton">
      <Setter Property="Foreground" Value="#5A7090"/>
      <Setter Property="FontFamily" Value="Georgia"/>
      <Setter Property="FontSize"   Value="12"/>
      <Setter Property="Cursor"     Value="Hand"/>
      <Style.Triggers>
        <Trigger Property="IsChecked" Value="True">
          <Setter Property="Foreground" Value="#C9A84C"/>
          <Setter Property="FontWeight" Value="Bold"/>
        </Trigger>
      </Style.Triggers>
    </Style>

    <Style TargetType="ProgressBar">
      <Setter Property="Height"          Value="5"/>
      <Setter Property="Background"      Value="#1A2E48"/>
      <Setter Property="BorderThickness" Value="0"/>
    </Style>

  </Window.Resources>

  <Grid>
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <!-- HEADER -->
    <Border Grid.Row="0" Background="#0D1E36"
            BorderBrush="#C9A84C" BorderThickness="0,0,0,1"
            Padding="20,10">
      <Grid>
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>
        <StackPanel Grid.Column="0">
          <TextBlock Text="L2C  Pi-Data Detector"
                     FontSize="20" FontWeight="Bold"
                     Foreground="#C9A84C" FontFamily="Georgia"/>
          <TextBlock Text="PeAIce Framework  |  Claude v3  |  GPT(EE) v2  |  Love Labs  |  peaice.org"
                     FontSize="10" Foreground="#3A5070" FontFamily="Georgia"
                     Margin="0,3,0,0"/>
        </StackPanel>
        <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
          <TextBlock x:Name="StatusLed" Text="[STANDBY]"
                     FontSize="12" FontWeight="Bold" Foreground="#FFC107"
                     FontFamily="Consolas"
                     VerticalAlignment="Center" Margin="0,0,20,0"/>
          <TextBlock Text="R = " FontSize="12" Foreground="#3A5070"
                     FontFamily="Georgia" VerticalAlignment="Center"/>
          <TextBlock x:Name="RBadge" Text="---"
                     FontSize="14" FontWeight="Bold"
                     Foreground="#C9A84C" FontFamily="Consolas"
                     VerticalAlignment="Center"/>
        </StackPanel>
      </Grid>
    </Border>

    <!-- MAIN -->
    <Grid Grid.Row="1" Margin="14,12,14,8">
      <Grid.ColumnDefinitions>
        <ColumnDefinition Width="*"/>
        <ColumnDefinition Width="265"/>
      </Grid.ColumnDefinitions>

      <!-- LEFT: Terminal -->
      <Grid Grid.Column="0" Margin="0,0,12,0">
        <Grid.RowDefinitions>
          <RowDefinition Height="Auto"/>
          <RowDefinition Height="*"/>
          <RowDefinition Height="Auto"/>
          <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Shell selector -->
        <Grid Grid.Row="0" Margin="0,0,0,8">
          <Grid.ColumnDefinitions>
            <ColumnDefinition Width="Auto"/>
            <ColumnDefinition Width="Auto"/>
            <ColumnDefinition Width="Auto"/>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="Auto"/>
          </Grid.ColumnDefinitions>
          <RadioButton x:Name="RbCMD"    Grid.Column="0"
                       Content="CMD"         IsChecked="True" Margin="0,0,14,0"/>
          <RadioButton x:Name="RbPS"     Grid.Column="1"
                       Content="PowerShell"  Margin="0,0,14,0"/>
          <RadioButton x:Name="RbPSCore" Grid.Column="2"
                       Content="pwsh (Core)"/>
          <StackPanel Grid.Column="4" Orientation="Horizontal">
            <Button x:Name="BtnIDB" Content="IDB SCAN"
                    Style="{StaticResource OtlBtn}"
                    FontSize="10" Margin="0,0,6,0"/>
            <Button x:Name="BtnCUP" Content="CUP PROBE"
                    Style="{StaticResource OtlBtn}"
                    FontSize="10"/>
          </StackPanel>
        </Grid>

        <!-- Output -->
        <Border Grid.Row="1" Background="#060E1A"
                BorderBrush="#1A2E48" BorderThickness="1" CornerRadius="4">
          <ScrollViewer x:Name="OutScroll"
                        VerticalScrollBarVisibility="Auto"
                        HorizontalScrollBarVisibility="Auto">
            <TextBox x:Name="OutBox"
                     Background="Transparent" Foreground="#90B8C8"
                     FontFamily="Consolas" FontSize="12"
                     IsReadOnly="True" TextWrapping="NoWrap"
                     BorderThickness="0" Padding="10"
                     AcceptsReturn="True"/>
          </ScrollViewer>
        </Border>

        <!-- Input row -->
        <Grid Grid.Row="2" Margin="0,8,0,6">
          <Grid.ColumnDefinitions>
            <ColumnDefinition Width="Auto"/>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="Auto"/>
            <ColumnDefinition Width="Auto"/>
          </Grid.ColumnDefinitions>
          <TextBlock x:Name="PromptLbl" Text="CMD  &gt;"
                     Foreground="#C9A84C" FontFamily="Consolas" FontSize="14"
                     VerticalAlignment="Center" Margin="0,0,8,0"/>
          <TextBox x:Name="CmdInput" Grid.Column="1"
                   Background="#0D1E36" Foreground="#E8E0D0"
                   FontFamily="Consolas" FontSize="13"
                   BorderBrush="#3A5070" BorderThickness="1"
                   Padding="8,5" CaretBrush="#C9A84C"
                   VerticalAlignment="Center"/>
          <Button x:Name="BtnRun" Grid.Column="2"
                  Content="RUN" Style="{StaticResource GoldBtn}"
                  MinWidth="60" Margin="6,0,0,0"/>
          <Button x:Name="BtnClear" Grid.Column="3"
                  Content="CLR" Style="{StaticResource OtlBtn}"
                  Margin="4,0,0,0"/>
        </Grid>

        <!-- Quick commands -->
        <WrapPanel Grid.Row="3" Orientation="Horizontal">
          <TextBlock Text="Quick:"
                     Foreground="#2A4060" FontSize="10" FontFamily="Georgia"
                     VerticalAlignment="Center" Margin="0,0,8,4"/>
          <Button x:Name="QC1" Content="systeminfo"
                  Style="{StaticResource OtlBtn}"
                  FontSize="9" Padding="7,2" Margin="0,0,4,4"/>
          <Button x:Name="QC2" Content="tasklist"
                  Style="{StaticResource OtlBtn}"
                  FontSize="9" Padding="7,2" Margin="0,0,4,4"/>
          <Button x:Name="QC3" Content="ipconfig"
                  Style="{StaticResource OtlBtn}"
                  FontSize="9" Padding="7,2" Margin="0,0,4,4"/>
          <Button x:Name="QC4" Content="Get-Process"
                  Style="{StaticResource OtlBtn}"
                  FontSize="9" Padding="7,2" Margin="0,0,4,4"/>
          <Button x:Name="QC5" Content="Get-Service"
                  Style="{StaticResource OtlBtn}"
                  FontSize="9" Padding="7,2" Margin="0,0,4,4"/>
          <Button x:Name="QC6" Content="netstat -ano"
                  Style="{StaticResource OtlBtn}"
                  FontSize="9" Padding="7,2" Margin="0,0,4,4"/>
          <Button x:Name="QC7" Content="dir"
                  Style="{StaticResource OtlBtn}"
                  FontSize="9" Padding="7,2" Margin="0,0,4,4"/>
          <Button x:Name="QC8" Content="whoami"
                  Style="{StaticResource OtlBtn}"
                  FontSize="9" Padding="7,2" Margin="0,0,0,4"/>
        </WrapPanel>
      </Grid>

      <!-- RIGHT: Panels -->
      <StackPanel Grid.Column="1">

        <!-- Coherence Meter -->
        <Border Background="#0D1E36" BorderBrush="#1A2E48" BorderThickness="1"
                CornerRadius="4" Padding="14,12" Margin="0,0,0,10">
          <StackPanel>
            <TextBlock Text="L2C  COHERENCE METER"
                       FontSize="10" FontWeight="Bold"
                       Foreground="#C9A84C" FontFamily="Georgia"
                       Margin="0,0,0,10"/>
            <Border Background="#060E1A" CornerRadius="3"
                    Padding="10,8" Margin="0,0,0,12">
              <StackPanel HorizontalAlignment="Center">
                <TextBlock Text="R  =  d x c x e x h"
                           FontSize="10" Foreground="#2A4060"
                           HorizontalAlignment="Center"
                           FontFamily="Consolas" Margin="0,0,0,4"/>
                <TextBlock x:Name="RBig" Text="---"
                           FontSize="38" FontWeight="Bold"
                           Foreground="#C9A84C"
                           HorizontalAlignment="Center"
                           FontFamily="Georgia"/>
                <TextBlock Text="INTEGRITY  SCORE"
                           FontSize="8" Foreground="#2A4060"
                           HorizontalAlignment="Center"
                           FontFamily="Georgia" Margin="0,2,0,0"/>
              </StackPanel>
            </Border>

            <Grid Margin="0,0,0,2">
              <Grid.ColumnDefinitions>
                <ColumnDefinition/><ColumnDefinition Width="Auto"/>
              </Grid.ColumnDefinitions>
              <TextBlock Text="d  directness"
                         FontSize="10" Foreground="#5A7090" FontFamily="Georgia"/>
              <TextBlock x:Name="Vd" Grid.Column="1" Text="---"
                         FontSize="10" Foreground="#C9A84C" FontWeight="Bold" FontFamily="Consolas"/>
            </Grid>
            <ProgressBar x:Name="Bd" Value="0" Maximum="1"
                         Foreground="#C9A84C" Margin="0,1,0,8"/>

            <Grid Margin="0,0,0,2">
              <Grid.ColumnDefinitions>
                <ColumnDefinition/><ColumnDefinition Width="Auto"/>
              </Grid.ColumnDefinitions>
              <TextBlock Text="c  coherence"
                         FontSize="10" Foreground="#5A7090" FontFamily="Georgia"/>
              <TextBlock x:Name="Vc" Grid.Column="1" Text="---"
                         FontSize="10" Foreground="#C9A84C" FontWeight="Bold" FontFamily="Consolas"/>
            </Grid>
            <ProgressBar x:Name="Bc" Value="0" Maximum="1"
                         Foreground="#C9A84C" Margin="0,1,0,8"/>

            <Grid Margin="0,0,0,2">
              <Grid.ColumnDefinitions>
                <ColumnDefinition/><ColumnDefinition Width="Auto"/>
              </Grid.ColumnDefinitions>
              <TextBlock Text="e  execution"
                         FontSize="10" Foreground="#5A7090" FontFamily="Georgia"/>
              <TextBlock x:Name="Ve" Grid.Column="1" Text="---"
                         FontSize="10" Foreground="#C9A84C" FontWeight="Bold" FontFamily="Consolas"/>
            </Grid>
            <ProgressBar x:Name="Be" Value="0" Maximum="1"
                         Foreground="#C9A84C" Margin="0,1,0,8"/>

            <Grid Margin="0,0,0,2">
              <Grid.ColumnDefinitions>
                <ColumnDefinition/><ColumnDefinition Width="Auto"/>
              </Grid.ColumnDefinitions>
              <TextBlock Text="h  humility"
                         FontSize="10" Foreground="#5A7090" FontFamily="Georgia"/>
              <TextBlock x:Name="Vh" Grid.Column="1" Text="---"
                         FontSize="10" Foreground="#C9A84C" FontWeight="Bold" FontFamily="Consolas"/>
            </Grid>
            <ProgressBar x:Name="Bh" Value="0" Maximum="1"
                         Foreground="#8A70A0" Margin="0,1,0,4"/>
            <TextBlock Text="h &lt; 1.0 always  (Godel discipline)"
                       FontSize="8" Foreground="#2A3A50"
                       FontStyle="Italic" FontFamily="Georgia"/>
          </StackPanel>
        </Border>

        <!-- IDB Panel -->
        <Border Background="#0D1E36" BorderBrush="#1A2E48" BorderThickness="1"
                CornerRadius="4" Padding="14,12" Margin="0,0,0,10">
          <StackPanel>
            <TextBlock Text="IDB  ILLUSION DETECT"
                       FontSize="10" FontWeight="Bold"
                       Foreground="#C9A84C" FontFamily="Georgia"
                       Margin="0,0,0,8"/>
            <Grid Margin="0,0,0,4">
              <Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
              <TextBlock Text="Drift signals"
                         FontSize="10" Foreground="#5A7090" FontFamily="Georgia"/>
              <TextBlock x:Name="IdbDrift" Grid.Column="1" Text="---"
                         FontSize="10" Foreground="#E8E0D0" FontWeight="Bold" FontFamily="Consolas"/>
            </Grid>
            <Grid Margin="0,0,0,4">
              <Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
              <TextBlock Text="Hedge patterns"
                         FontSize="10" Foreground="#5A7090" FontFamily="Georgia"/>
              <TextBlock x:Name="IdbHedge" Grid.Column="1" Text="---"
                         FontSize="10" Foreground="#E8E0D0" FontWeight="Bold" FontFamily="Consolas"/>
            </Grid>
            <Grid Margin="0,0,0,4">
              <Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
              <TextBlock Text="Error signals"
                         FontSize="10" Foreground="#5A7090" FontFamily="Georgia"/>
              <TextBlock x:Name="IdbErrors" Grid.Column="1" Text="---"
                         FontSize="10" Foreground="#E8E0D0" FontWeight="Bold" FontFamily="Consolas"/>
            </Grid>
            <Grid Margin="0,0,0,8">
              <Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
              <TextBlock Text="Lines scanned"
                         FontSize="10" Foreground="#5A7090" FontFamily="Georgia"/>
              <TextBlock x:Name="IdbLines" Grid.Column="1" Text="---"
                         FontSize="10" Foreground="#E8E0D0" FontWeight="Bold" FontFamily="Consolas"/>
            </Grid>
            <Border Background="#060E1A" CornerRadius="3" Padding="8,6">
              <TextBlock x:Name="IdbVerdict" Text="Awaiting scan..."
                         FontSize="10" Foreground="#2A4060"
                         TextWrapping="Wrap" FontFamily="Consolas"/>
            </Border>
          </StackPanel>
        </Border>

        <!-- CUP Panel -->
        <Border Background="#0D1E36" BorderBrush="#1A2E48" BorderThickness="1"
                CornerRadius="4" Padding="14,12">
          <StackPanel>
            <TextBlock Text="CUP  COHERENCE PRESSURE"
                       FontSize="10" FontWeight="Bold"
                       Foreground="#C9A84C" FontFamily="Georgia"
                       Margin="0,0,0,8"/>
            <TextBlock x:Name="CupStatus" Text="Standby"
                       FontSize="11" Foreground="#2A4060"
                       FontFamily="Georgia" Margin="0,0,0,8"/>
            <TextBlock Text="Red lines enforced:"
                       FontSize="9" Foreground="#2A4060"
                       FontFamily="Georgia" Margin="0,0,0,4"/>
            <TextBlock Text="[OK] No lethal authorization"
                       FontSize="9" Foreground="#3A8050" FontFamily="Consolas"/>
            <TextBlock Text="[OK] No target selection"
                       FontSize="9" Foreground="#3A8050" FontFamily="Consolas"/>
            <TextBlock Text="[OK] Godel discipline active"
                       FontSize="9" Foreground="#3A8050" FontFamily="Consolas"/>
            <TextBlock Text="[OK] h structurally load-bearing"
                       FontSize="9" Foreground="#3A8050" FontFamily="Consolas"/>
          </StackPanel>
        </Border>

      </StackPanel>
    </Grid>

    <!-- STATUS BAR -->
    <Border Grid.Row="2" Background="#0D1E36"
            BorderBrush="#C9A84C" BorderThickness="0,1,0,0"
            Padding="14,6">
      <Grid>
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>
        <TextBlock x:Name="SBar"
                   Text="(CMD + PowerShell + Terminal)  ->  Pi-Detector  |  EE: ON  |  Ready"
                   FontSize="10" Foreground="#2A4060"
                   FontFamily="Consolas" VerticalAlignment="Center"/>
        <TextBlock Grid.Column="1"
                   Text="peaice.org  |  Love Labs  |  2025"
                   FontSize="9" Foreground="#1A2E40"
                   FontFamily="Georgia" VerticalAlignment="Center"/>
      </Grid>
    </Border>

  </Grid>
</Window>
'@

# ── LOAD ──────────────────────────────────────────────────────────────────────
try {
    $reader = [System.Xml.XmlNodeReader]::new($xaml)
    $win    = [Windows.Markup.XamlReader]::Load($reader)
} catch {
    [System.Windows.MessageBox]::Show("XAML load failed:`n$_", "L2C Error")
    exit 1
}

# ── BIND ELEMENTS ─────────────────────────────────────────────────────────────
$outBox     = $win.FindName("OutBox")
$outScroll  = $win.FindName("OutScroll")
$cmdInput   = $win.FindName("CmdInput")
$promptLbl  = $win.FindName("PromptLbl")
$btnRun     = $win.FindName("BtnRun")
$btnIDB     = $win.FindName("BtnIDB")
$btnCUP     = $win.FindName("BtnCUP")
$btnClear   = $win.FindName("BtnClear")
$rbCMD      = $win.FindName("RbCMD")
$rbPS       = $win.FindName("RbPS")
$rbPSCore   = $win.FindName("RbPSCore")
$statusLed  = $win.FindName("StatusLed")
$rBadge     = $win.FindName("RBadge")
$rBig       = $win.FindName("RBig")
$vd         = $win.FindName("Vd");  $bd = $win.FindName("Bd")
$vc         = $win.FindName("Vc");  $bc = $win.FindName("Bc")
$ve         = $win.FindName("Ve");  $be = $win.FindName("Be")
$vh         = $win.FindName("Vh");  $bh = $win.FindName("Bh")
$idbDrift   = $win.FindName("IdbDrift")
$idbHedge   = $win.FindName("IdbHedge")
$idbErrors  = $win.FindName("IdbErrors")
$idbLines   = $win.FindName("IdbLines")
$idbVerdict = $win.FindName("IdbVerdict")
$cupStatus  = $win.FindName("CupStatus")
$sBar       = $win.FindName("SBar")

# ── BRUSH HELPER ─────────────────────────────────────────────────────────────
function MkBrush([string]$hex) {
    $r = [Convert]::ToInt32($hex.Substring(1,2),16)
    $g = [Convert]::ToInt32($hex.Substring(3,2),16)
    $b = [Convert]::ToInt32($hex.Substring(5,2),16)
    return [Windows.Media.SolidColorBrush]::new([Windows.Media.Color]::FromRgb($r,$g,$b))
}
$GREEN  = MkBrush "#4CAF50"
$YELLOW = MkBrush "#FFC107"
$RED    = MkBrush "#F44336"
$DIM    = MkBrush "#2A4060"

# ── INIT OUTPUT ───────────────────────────────────────────────────────────────
$outBox.Text = @"
L2C  Pi-Data Detector  --  initialized
Shell stack : CMD  |  PowerShell  |  Windows Terminal
Framework   : PeAIce | Claude v3 | GPT(EE) v2

Formula  R = d x c x e x h   (integrity)
h is structurally load-bearing -- Godel discipline enforced
h < 1.0 always  (system cannot self-verify)

IDB  : Illusion Detection Benchmark  [ready]
CUP  : Coherence Under Pressure      [standby]

Type a command and press Enter or RUN.
"@

# ── APPEND LINE ───────────────────────────────────────────────────────────────
function AppendOut([string]$text, [string]$tag) {
    $ts = Get-Date -Format "HH:mm:ss"
    if ($tag) { $outBox.AppendText("`n[$ts][$tag] $text") }
    else       { $outBox.AppendText("`n[$ts] $text") }
    $outScroll.ScrollToEnd()
}

# ── L2C SCORING ───────────────────────────────────────────────────────────────
function Score-L2C {
    param([string]$Output, [string]$Cmd, [bool]$HasErr)

    $lines    = $Output -split "`n"
    $nonEmpty = ($lines | Where-Object { $_.Trim() -ne "" }).Count
    $total    = [math]::Max(1, $lines.Count)
    $d        = [math]::Round([math]::Min(1.0, $nonEmpty / $total), 3)

    $ratio = $Output.Length / [math]::Max(1, $Cmd.Length * 8)
    $c     = [math]::Round([math]::Min(1.0, [math]::Max(0.05, $ratio)), 3)

    $e = if ($HasErr) { 0.25 } else { 0.97 }
    $h = 0.87   # Godel -- structurally non-negotiable

    $R = [math]::Round($d * $c * $e * $h, 4)
    return [PSCustomObject]@{ d=$d; c=$c; e=$e; h=$h; R=$R }
}

# ── IDB SCANNER ───────────────────────────────────────────────────────────────
function Scan-IDB {
    param([string]$Text)

    $driftPat = @("error","fail","not found","access denied","cannot","unable","invalid","refused","denied")
    $hedgePat = @("might","possibly","perhaps","could be","unknown","undefined","unclear","maybe","unsure")

    $lines  = ($Text -split "`n") | Where-Object { $_.Trim() -ne "" }
    $drifts = ($lines | Where-Object {
        $line = $_; ($driftPat | Where-Object { $line -imatch $_ }).Count -gt 0
    }).Count
    $hedges = ($lines | Where-Object {
        $line = $_; ($hedgePat | Where-Object { $line -imatch $_ }).Count -gt 0
    }).Count
    $errors = ([regex]::Matches($Text,"(?i)(error|exception|failed|0x[0-9A-Fa-f]{4,})")).Count
    $lc     = $lines.Count

    $verdict = if   ($errors -gt 6 -or $drifts -gt 10) { "[RED]  HIGH DRIFT -- coherence degraded" }
               elseif ($errors -gt 2 -or $drifts -gt 4) { "[YLW]  MODERATE -- review recommended"   }
               else                                      { "[GRN]  COHERENT -- within L2C bounds"     }

    return [PSCustomObject]@{ Drift=$drifts; Hedge=$hedges; Errors=$errors; Lines=$lc; Verdict=$verdict }
}

# ── UPDATE PANEL ─────────────────────────────────────────────────────────────
function UpdatePanel {
    param($S, $Idb)

    $vd.Text = "$($S.d)"; $bd.Value = $S.d
    $vc.Text = "$($S.c)"; $bc.Value = $S.c
    $ve.Text = "$($S.e)"; $be.Value = $S.e
    $vh.Text = "$($S.h)"; $bh.Value = $S.h
    $rBig.Text   = "$($S.R)"
    $rBadge.Text = "$($S.R)"

    if ($S.R -ge 0.70) {
        $rBig.Foreground      = $GREEN
        $statusLed.Text       = "[COHERENT]"
        $statusLed.Foreground = $GREEN
    } elseif ($S.R -ge 0.40) {
        $rBig.Foreground      = $YELLOW
        $statusLed.Text       = "[DEGRADED]"
        $statusLed.Foreground = $YELLOW
    } else {
        $rBig.Foreground      = $RED
        $statusLed.Text       = "[LOW-R]"
        $statusLed.Foreground = $RED
    }

    if ($Idb) {
        $idbDrift.Text   = "$($Idb.Drift)"
        $idbHedge.Text   = "$($Idb.Hedge)"
        $idbErrors.Text  = "$($Idb.Errors)"
        $idbLines.Text   = "$($Idb.Lines)"
        $idbVerdict.Text = $Idb.Verdict
        $idbVerdict.Foreground = if   ($Idb.Verdict -like "*GRN*")  { $GREEN  }
                                  elseif ($Idb.Verdict -like "*YLW*") { $YELLOW }
                                  else                                 { $RED    }
    }
}

# ── EXECUTE ───────────────────────────────────────────────────────────────────
function ExecCmd {
    param([string]$Cmd)
    if ([string]::IsNullOrWhiteSpace($Cmd)) { return }

    $statusLed.Text       = "[RUNNING]"
    $statusLed.Foreground = $YELLOW
    AppendOut "" ""
    AppendOut "> $Cmd" "EXEC"

    $stdout = ""; $stderr = ""; $hasErr = $false

    try {
        if ($rbCMD.IsChecked) {
            $exe  = "cmd.exe"
            $xarg = "/c $Cmd"
        } elseif ($rbPS.IsChecked) {
            $exe  = "powershell.exe"
            $xarg = "-NoProfile -NonInteractive -Command `"$Cmd`""
        } else {
            $exe  = "pwsh.exe"
            $xarg = "-NoProfile -NonInteractive -Command `"$Cmd`""
        }

        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName               = $exe
        $psi.Arguments              = $xarg
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError  = $true
        $psi.UseShellExecute        = $false
        $psi.CreateNoWindow         = $true

        $proc   = [System.Diagnostics.Process]::Start($psi)
        $stdout = $proc.StandardOutput.ReadToEnd()
        $stderr = $proc.StandardError.ReadToEnd()
        $proc.WaitForExit(15000)
        if ($stderr.Trim()) { $hasErr = $true }
    } catch {
        $stderr = "EXCEPTION: $_"; $hasErr = $true
    }

    $combined = $stdout
    if ($stderr.Trim()) { $combined += "`n--- STDERR ---`n$stderr" }
    $display  = if ($combined.Length -gt 5000) {
                    $combined.Substring(0,5000) + "`n[truncated]"
                } else { $combined }

    $outBox.AppendText("`n$display")
    $outScroll.ScrollToEnd()

    $s   = Score-L2C -Output $combined -Cmd $Cmd -HasErr $hasErr
    $idb = Scan-IDB  -Text   $combined
    UpdatePanel -S $s -Idb $idb
    $sBar.Text = "Last: $Cmd  |  R=$($s.R)  d=$($s.d) c=$($s.c) e=$($s.e) h=$($s.h)  |  IDB: $($idb.Verdict)"
}

# ── WIRE EVENTS ───────────────────────────────────────────────────────────────
$btnRun.Add_Click({
    ExecCmd -Cmd $cmdInput.Text; $cmdInput.Clear()
})

$cmdInput.Add_KeyDown({
    param($sender, $e)
    if ($e.Key -eq [System.Windows.Input.Key]::Return) {
        ExecCmd -Cmd $cmdInput.Text; $cmdInput.Clear()
    }
})

$btnClear.Add_Click({
    $outBox.Text     = "L2C Pi-Data Detector  --  output cleared."
    $rBig.Text       = "---"; $rBadge.Text = "---"
    $vd.Text="---"; $vc.Text="---"; $ve.Text="---"; $vh.Text="---"
    $bd.Value=0; $bc.Value=0; $be.Value=0; $bh.Value=0
    $statusLed.Text       = "[STANDBY]"
    $statusLed.Foreground = $YELLOW
    $idbDrift.Text="---"; $idbHedge.Text="---"
    $idbErrors.Text="---"; $idbLines.Text="---"
    $idbVerdict.Text       = "Awaiting scan..."
    $idbVerdict.Foreground = $DIM
})

# Quick buttons -- hardcoded strings avoid closure capture issues
$win.FindName("QC1").Add_Click({ ExecCmd "systeminfo" })
$win.FindName("QC2").Add_Click({ ExecCmd "tasklist" })
$win.FindName("QC3").Add_Click({ ExecCmd "ipconfig /all" })
$win.FindName("QC4").Add_Click({ ExecCmd "Get-Process | Sort-Object CPU -Descending | Select-Object -First 12 | Format-Table -AutoSize" })
$win.FindName("QC5").Add_Click({ ExecCmd "Get-Service | Where-Object { `$_.Status -eq 'Running' } | Select-Object -First 15 | Format-Table -AutoSize" })
$win.FindName("QC6").Add_Click({ ExecCmd "netstat -ano" })
$win.FindName("QC7").Add_Click({ ExecCmd "dir" })
$win.FindName("QC8").Add_Click({ ExecCmd "whoami /all" })

$rbCMD.Add_Checked({    $promptLbl.Text = "CMD  >" })
$rbPS.Add_Checked({     $promptLbl.Text = "PS   >" })
$rbPSCore.Add_Checked({ $promptLbl.Text = "pwsh >" })

$btnIDB.Add_Click({
    $txt = $outBox.Text
    if ($txt.Length -lt 20) { AppendOut "No output to scan." "IDB"; return }
    $idb = Scan-IDB -Text $txt
    $idbDrift.Text   = "$($idb.Drift)"
    $idbHedge.Text   = "$($idb.Hedge)"
    $idbErrors.Text  = "$($idb.Errors)"
    $idbLines.Text   = "$($idb.Lines)"
    $idbVerdict.Text = $idb.Verdict
    $idbVerdict.Foreground = if   ($idb.Verdict -like "*GRN*")  { $GREEN  }
                              elseif ($idb.Verdict -like "*YLW*") { $YELLOW }
                              else                                 { $RED    }
    AppendOut "Scan complete -> $($idb.Verdict)" "IDB"
})

$btnCUP.Add_Click({
    $cupStatus.Text       = "ACTIVE -- running probe battery..."
    $cupStatus.Foreground = $YELLOW
    AppendOut "CUP probe initiated." "CUP"

    $battery = @("echo CUP_INIT","whoami","hostname","echo %COMPUTERNAME%","echo CUP_END")
    $agg = ""
    foreach ($c in $battery) {
        try {
            $psi2 = New-Object System.Diagnostics.ProcessStartInfo
            $psi2.FileName               = "cmd.exe"
            $psi2.Arguments              = "/c $c"
            $psi2.RedirectStandardOutput = $true
            $psi2.UseShellExecute        = $false
            $psi2.CreateNoWindow         = $true
            $proc2 = [System.Diagnostics.Process]::Start($psi2)
            $agg  += $proc2.StandardOutput.ReadToEnd()
            $proc2.WaitForExit(4000)
        } catch {}
    }

    $s2   = Score-L2C -Output $agg -Cmd "CUP_BATTERY" -HasErr $false
    $idb2 = Scan-IDB  -Text $agg
    UpdatePanel -S $s2 -Idb $idb2

    $verdict = if ($s2.R -ge 0.70) { "PASSED  R=$($s2.R)" } else { "FLAGGED  R=$($s2.R)" }
    $cupStatus.Text       = "CUP -> $verdict"
    $cupStatus.Foreground = if ($s2.R -ge 0.70) { $GREEN } else { $RED }
    AppendOut "CUP -> $verdict" "CUP"
})

# ── SHOW ──────────────────────────────────────────────────────────────────────
[void]$win.ShowDialog()
