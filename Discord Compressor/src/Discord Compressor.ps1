# TODO: progress bar, changing windows default app for vbs breaks context menu, 25mb installer, auto updating, best codec

# Compresses a video file to less than 8 Mebibyte
$in_file = get-item $args[0]
$out_file = $in_file.DirectoryName + "\" +  $in_file.BaseName + "_8mb" + $in_file.Extension 

# Prompt if out file already exists
if (Test-Path $out_file){
    Add-Type -AssemblyName PresentationCore,PresentationFramework
    $ButtonType = [System.Windows.MessageBoxButton]::YesNo
    $MessageIcon = [System.Windows.MessageBoxImage]::Warning
    $MessageBody = $out_file + " already exists. Would you like to overwrite?"
    $MessageTitle = "Overwrite File?"
    $Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
    if($Result -ne "yes"){
        Exit
    }
}
# Create empty ouput.pm4 file, Not necessary but indicates to user program is running
New-item $out_file 

# Compute target bit rate based on desired output size, all sizes represented in bits
$target_size = 200020896 # 7.5 Mebibyte
$input_duration = ./ffmpeg-5.0-essentials_build/bin/ffprobe.exe -v error -show_entries format=duration -of csv=p=0 $in_file
$audio_rate = ./ffmpeg-5.0-essentials_build/bin/ffprobe.exe  -v error -select_streams a:0 -show_entries stream=bit_rate -of csv=p=0 $in_file
$target_bit_rate = ($target_size / $input_duration) - ($audio_rate)

# generate temporary file for 2 pass encoding
$temp_file = New-TemporaryFile

# Do two pass encoding
./ffmpeg-5.0-essentials_build/bin/ffmpeg.exe  -y -loglevel error -i $args[0] -c:v libx264 -b:v $target_bit_rate -passlogfile $temp_file -pass 1 -an -f mp4 NUL
./ffmpeg-5.0-essentials_build/bin/ffmpeg.exe  -y -loglevel error -i $args[0] -c:v libx264 -b:v $target_bit_rate -passlogfile $temp_file -pass 2 -c:a aac -b:a $audio_rate $out_file

# delete temporary files
Remove-Item -path ($temp_file.FullName + "-0.log")
Remove-Item -path ($temp_file.FullName + "-0.log.mbtree")
Remove-Item -path $temp_file