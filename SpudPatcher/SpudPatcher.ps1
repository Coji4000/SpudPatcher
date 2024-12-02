##Spuds filePatcher Deploy/Update Script
##Author: Spud
##Date: 12/1/24
##!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
##!!!WARNING: This script can be destructive if configured improperly!!!
##!!!                 It Prompts the user before it destroys.        !!!
##!!!            By running this script you assume all liability.    !!!
##!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
##Desc: Moves $Payload to your Arma 3 directory $ArmaRoot with cfg!
##      Helps with sharing filePatches to Users and Collaborators       

using namespace System.xml.linq

###PrepVars
$ArmaRoot =  "FAIL"
$BlackList = "FAIL"
$Payload = "FAIL"
$Sprefs = "$PSScriptRoot\sprefs.xml" #Only needs this "absolute" path for InitSprefs Out-File.
$PatchRoot = "$PSScriptRoot\payload"

Function InitSprefs
    {
        ###Set  ArmaRoot
        if(Test-Path 'HKLM:\SOFTWARE\WOW6432Node\bohemia interactive\arma 32\' -ErrorAction SilentlyContinue)
            {
                $ArmaRoot = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\bohemia interactive\arma 3\').main
            } else {
                ###Needs Sanity/Scrub for User Cancel or bad data
                [void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
                $ArmaFinder = New-Object System.Windows.Forms.FolderBrowserDialog
                $ArmaFinder.Description = "Select Your Arma 3 Directory"
                $ArmaFinder.rootfolder = "MyComputer"
                $ArmaFinder.SelectedPath = "MyComputer"
                if($ArmaFinder.ShowDialog() -eq "OK")
                    {
                        $ArmaRoot += $ArmaFinder.SelectedPath
                    }
            }

        $Blacklist = (Get-ChildItem -Directory $ArmaRoot).Name -join ','
        ###I Think this needs a check in it too in case PatchRoot is set wrongly
        $Payload = (Get-ChildItem -Directory $PatchRoot).Name -join ','

        ###Building/Writing ugly XML
        [void][Reflection.Assembly]::LoadWithPartialName("System.Xml.Linq")
        $mkSprefs = [system.xml.linq.XDocument]::new(
            [system.xml.linq.XElement]::new("Vars",
                [system.xml.linq.XElement]::new("Sprefs","$Sprefs"),
                [system.xml.linq.XElement]::new("PatchRoot","$PatchRoot"),
                [system.xml.linq.XElement]::new("ArmaRoot","$ArmaRoot"),
                [system.xml.linq.XElement]::new("BlackList","$BlackList"),
                [system.xml.linq.XElement]::new("Payload","$Payload")
            )
        );
        $mkSprefs.ToString() | Out-File "$Sprefs";
    }

###Needs some catch for bad data
Function GetSprefs
    {
        ###Import Sprefs XML
        $gcSprexml = [xml](get-content $Sprefs)

        ###Set Variables from XML
        $Sprefs = $gcSprexml.Vars.Sprefs.InnerText
        $PatchRoot = $gcSprexml.Vars.PatchRoot.InnerText
        $ArmaRoot = $gcSprexml.Vars.ArmaRoot.InnerText
        $BlackList = $gcSprexml.Vars.BlackList.InnerText
        $PayLoad = $gcSprexml.Vars.PayLoad.InnerText
    }

Function Get-FormVariables
    {
        write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
        get-variable WPF*
    }


Function RunForm
    {
        ###XAML import/clean (picky about indent, if your eye is twitching after reading this far into my code you are too :D)
        $inputXML = @"
<Window x:Name="SpudPatcherMain" x:Class="SpudPatcher.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:SpudPatcher"
        mc:Ignorable="d"
        Title="SpudPatcher: Confirm Your Expectations" Height="560" Width="760" WindowStartupLocation="CenterScreen" Background="#FF5F5F5F" Foreground="#FF003200" MinWidth="760" MinHeight="545" WindowStyle="ThreeDBorderWindow" MaxWidth="1024" MaxHeight="2160">
    <Grid x:Name="GridMain">
        <Grid.RowDefinitions>
            <RowDefinition x:Name="Row_0" Height="130*"/>
            <RowDefinition x:Name="Row_1" Height="300*"/>
            <RowDefinition x:Name="Row_2" Height="130*"/>
        </Grid.RowDefinitions>
        <Grid.ColumnDefinitions>
            <ColumnDefinition x:Name="Col_0" Width="380*"/>
            <ColumnDefinition x:Name="Col_1" Width="380*"/>
        </Grid.ColumnDefinitions>
        <Button x:Name="ArmaDirBtn" Content="..." Margin="0,0,5,65" VerticalAlignment="Bottom" Height="30" FontFamily="Segoe UI Variable Small Semibold" Grid.Row="2" HorizontalAlignment="Right" Width="20"/>
        <Button x:Name="PLoadDirBtn" Content="..." Margin="0,0,5,10" FontFamily="Segoe UI Variable Small Semibold" Grid.Row="2" Height="30" VerticalAlignment="Bottom" HorizontalAlignment="Right" Width="20"/>
        <Button x:Name="BlistEditBtn" Grid.Column="1" Content="Edit..." Margin="0,5,5,0" VerticalAlignment="Top" Height="20" FontFamily="Segoe UI Variable Small Semibold" HorizontalAlignment="Right" Width="40" Grid.Row="1"/>
        <Button x:Name="Exec_Btn" Content="!Execute!" Margin="0,0,5,10" Grid.Row="2" Grid.Column="1" Background="#FF679F69" Height="30" VerticalAlignment="Bottom" HorizontalAlignment="Right" Width="80" FontFamily="Segoe UI Variable Small Semibold" FontWeight="Bold" FontSize="16"/>
        <Button x:Name="Abort_Btn" Content="!Abort!" Margin="0,0,5,45" Grid.Row="2" Grid.Column="1" IsCancel="True" Background="#FFFC4F4F" IsDefault="True" HorizontalAlignment="Right" Width="80" FontFamily="Segoe UI Variable Small Semibold" FontWeight="Bold" FontSize="16" Height="55" VerticalAlignment="Bottom"/>
        <ListBox x:Name="IgnoreDir_List" Grid.Column="1" Margin="5,30,5,5" Grid.Row="1" FontWeight="Bold" FontFamily="Segoe UI Variable Display Semilight"/>
        <ListBox x:Name="ToDeploy_List" Margin="5,30,5,5" Grid.Row="1" FontWeight="Bold" FontFamily="Segoe UI Variable Display Semilight"/>
        <TextBox x:Name="ArmaDir_TxBx" Margin="5,0,30,65" TextWrapping="Wrap" FontWeight="Bold" FontFamily="Segoe UI Variable Display Semilight" Grid.Row="2" Height="30" VerticalAlignment="Bottom"/>
        <TextBox x:Name="PLoad_TxBx" TextWrapping="Wrap" Margin="5,0,30,10" FontWeight="Bold" FontFamily="Segoe UI Variable Display Semilight" Grid.Row="2" VerticalAlignment="Bottom" Height="30"/>
        <TextBlock x:Name="ToDeploy_Lbl" Margin="5,5,5,0" TextWrapping="Wrap" Text="Folders to Deploy" FontWeight="Bold" FontFamily="Segoe UI Black" TextDecorations="Underline" Grid.Row="1" MinWidth="370" MinHeight="25" MaxHeight="25" VerticalAlignment="Top" Height="25"/>
        <TextBlock x:Name="Welcome_TBlk" Margin="5,5,5,5" Foreground="White" TextAlignment="Center" FontFamily="Segoe UI Variable Display Semilight" TextWrapping="Wrap" Grid.Column="1" FontSize="14" IsEnabled="False"><Run/><LineBreak/><Run/></TextBlock>
        <TextBlock x:Name="ArmaDir_Lbl" TextWrapping="Wrap" Text="Arma 3 Directory" FontWeight="Bold" TextDecorations="Underline" TextAlignment="Center" FontFamily="Segoe UI Black" Grid.Row="2" Margin="5,0,5,90" Height="25" VerticalAlignment="Bottom"/>
        <TextBlock x:Name="Pload_Lbl" Margin="5,0,5,35" TextWrapping="Wrap" Text="Payload Directory" FontWeight="Bold" TextDecorations="Underline" TextAlignment="Center" FontFamily="Segoe UI Black" Grid.Row="2" Height="25" VerticalAlignment="Bottom"/>
        <TextBlock x:Name="Blist_Lbl" Grid.Column="1" Margin="5,5,5,0" TextWrapping="Wrap" Text="Folders to Ignore" FontWeight="Bold" TextDecorations="Underline" Grid.Row="1" FontFamily="Segoe UI Black" Height="25" VerticalAlignment="Top" MinWidth="370" MinHeight="25" MaxHeight="24"/>
        <TextBlock x:Name="Action_Lbl" Margin="5,0,90,35" TextWrapping="Wrap" Text="Select an Option:" FontWeight="Bold" TextDecorations="Underline" TextAlignment="Center" FontFamily="Segoe UI Black" Grid.Row="2" Grid.Column="1" Height="25" VerticalAlignment="Bottom"/>
        <ComboBox x:Name="Actions_Combo" Margin="5,0,90,10" VerticalAlignment="Bottom" Grid.Column="1" Grid.Row="2" Height="30" Text="Select a way forward" FontFamily="Segoe UI Variable Small Semibold" RenderTransformOrigin="0.5,0.5">
            <ComboBoxItem Content="Open Config with Notepad"/>
            <ComboBoxItem Content="Re-Initialize Config"/>
            <ComboBoxItem Content="Remove Payload from Arma 3 Dir"/>
            <ComboBoxItem Content="Install Payload to Arma 3 Dir"/>
        </ComboBox>
        <Image x:Name="Logo_Img" Margin="10,30,10,30" Source="$PSScriptRoot\Banner.png"/>
    </Grid>
</Window>
"@ 
 
    $inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
    [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
    [xml]$XAML = $inputXML

    ###Read XAML
    $reader=(New-Object System.Xml.XmlNodeReader $xaml)
        try
        {
            $Form=[Windows.Markup.XamlReader]::Load( $reader )
        }
        catch{
            Write-Warning "Unable to parse XML, with error: $($Error[0])`n Ensure that there are NO SelectionChanged or TextChanged properties in your textboxes (PowerShell cannot process them)"
            throw
        }
 
    $xaml.SelectNodes("//*[@Name]") | %{
        try
        {
            Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name) -ErrorAction Stop
        }
        catch{
            throw
        }
    }

    <# Uncomment to console write interactable hooks /#>
    Get-FormVariables 

    ###Form Hooks

    ###Reference  
    ###Adding items to a dropdown/combo box
    ###$vmpicklistView.items.Add([pscustomobject]@{'VMName'=($_).Name;Status=$_.Status;Other="Yes"})     
    ###Setting the text of a text box to the current PC name    
    ###$WPFtextBox.Text = $env:COMPUTERNAME
    ###Adding code to a button, so that when clicked, it pings a system
    ### $WPFbutton.Add_Click({ Test-connection -count 1 -ComputerName $WPFtextBox.Text
    ### })

    $Form.ShowDialog() | out-null
    } 

Function Startup
    {
        if(Test-Path $Sprefs -ErrorAction SilentlyContinue)
            {
                GetSprefs
                RunForm
            } else {
                InitSprefs
                GetSprefs
                RunForm
            }
    }

Startup