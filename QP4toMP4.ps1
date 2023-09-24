#╔=================================================╗
#║     QP4 to MP4 SCH matrix converter by Angus    ║
#╚====╦==============================╦=============╝
#     ║ Feel free to make it better. ║
#     ╚==============================╝

#Unpack ffmpeg.exe if it hasn't been unpacked yet
if(!(Test-Path "./ffmpeg.exe"))
{
    Write-Output "ffmpeg.exe kitömörítése...
    
    "
    Expand-Archive .\ffmpeg.zip -DestinationPath .\
    cls
}

Write-Output "   ____  _____  _  _     _          __  __ _____  _  _   
  / __ \|  __ \| || |   | |        |  \/  |  __ \| || |  
 | |  | | |__) | || |_  | |_ ___   | \  / | |__) | || |_ 
 | |  | |  ___/|__   _| | __/ _ \  | |\/| |  ___/|__   _|
 | |__| | |       | |   | || (_) | | |  | | |       | |  
  \___\_\_|       |_|    \__\___/  |_|  |_|_|       |_|  
 | |               /\                                    
 | |__  _   _     /  \   _ __   __ _ _   _ ___           
 | '_ \| | | |   / /\ \ | '_ \ / _` | | | / __|          
 | |_) | |_| |  / ____ \| | | | (_| | |_| \__ \          
 |_.__/ \__, | /_/    \_\_| |_|\__, |\__,_|___/          
         __/ |                  __/ |                    
        |___/                  |___/                     
        
        "

#Check for source files to convert
if(!(Test-Path "./matrix.qp4"))
{
    Write-Output "Nincs mit konvertálni, a matrix.qp4 fájl nem található.
    
    A konvertáláshoz helyezd az animációdat matrix.qp4 és a hozzá tartozó hangot matrix.mp3 néven ebbe a mappába!

    "
    pause
    exit
}

if(!(Test-Path "./matrix.mp4"))
{
    Write-Output "Nem található a matrix.mp3 fájl. Az animáció konvertálásához másold ide a szükséges hanganyagot is ezen a néven!

    "
    pause
    exit
}

Add-Type -Assembly System.Drawing

#Set decimal separator to dot from comma as ffmpeg will only accept that format
$culture = Get-Culture
$culture.NumberFormat.NumberGroupSeparator = ','
$culture.NumberFormat.NumberDecimalSeparator = '.'

#Open files that will be used in the project

$bitmap = [System.Drawing.Bitmap]::FromFile("./mask.png")
[string]$qp4 = Get-Content "./matrix.qp4"

#Init some shite
$frameindex=0
[string]$videolist = ""
$delay_remainder = 0

#Define window coordinates maps
$xcoordsmap = 753,779,810,835,864,890,920,944,977,1000,1030,1057,1087,1111,1142,1167
$ycoordsmap = 156,200,244,288,332,376,421,465,509,553,597,641,686

#Give the user some time estimate to scare him off
[regex]$regex = 'frame'
$howlong = $regex.matches($qp4).count

if ($howlong -gt 300){
    Write-Output ("The conversion will take around " + $howlong + " seconds to finish. You'll have time to open a cold one...")
}else{
    Write-Output ("The conversion will take around " + $howlong + "seconds to finish.")
}

Start-Sleep 10

#Loop thru all the frames in the qp4 animation

while($qp4.IndexOf('frame') -ne -1){

#Remove everything until the starting point of next frame

$qp4 = $qp4.Remove(0,($qp4.IndexOf('frame')))
$qp4 = $qp4.Remove(0,($qp4.IndexOf('0')))


#Extract frame pixel data
$frame_pixels = $qp4
$frame_pixels = $frame_pixels.Substring(0,($qp4.IndexOf('}')))
$pixel_data = $frame_pixels.Split(',')

#Find frame length, throw away already parsed pixel data
$qp4 = $qp4.Remove(0,($qp4.IndexOf('}'))+2)
$frame_length = $qp4.Substring(0,$qp4.IndexOf(')'))

#Calculate frame length for FFMPEG video generation. As mp4 will be 25fps, we work with multiples of 0.04 sec
$delay = [int32]$frame_length

#Add earlier remainder to current delay needed
$delay += $delay_remainder

#Save remainder for next frame
$delay_remainder = $delay%40

#Cut delay to multiple of 0.04s and convert it to sec from ms
$delay = $delay - $delay%40
$delay = $delay/1000

#Create array for ARGB values
$colors = New-Object 'Int32[,,]' 4,26,32
$pixelindex = 0;


#fill ARGB array with pixel
for($y=0;$y -lt 26; $y++){
    for ($x = 0; $x -lt 32; $x++){
        [int64]$argb = [int64]$pixel_data[$pixelindex]
        $colors[0,$y,$x] = [int][Math]::Floor($argb/16777216)
        $colors[1,$y,$x] = [int][Math]::Floor(($argb%16777216)/65536)
        $colors[2,$y,$x] = [int][Math]::Floor(($argb%65536)/256)
        $colors[3,$y,$x] = [int][Math]::Floor($argb%256)
        $pixelindex++
    }
}



$row_index = 0
    #Start drawing the windows row by row
    for ($l = 0; $l -lt 13; $l++){
        
        #Top left pixels of row
        $start_y = $ycoordsmap[($l)]
        for ($k = 0; $k -lt 16 ; $k++){
            $start_x = $xcoordsmap[$k]
            $color = [System.Drawing.Color]::FromArgb( ($colors[0,($l*2),($k*2)]), ($colors[1,($l*2),($k*2)]), ($colors[2,($l*2),($k*2)]), ($colors[3,($l*2),($k*2)]))
            for ($i=0; $i -lt 10; $i++){
                for ($j=0; $j -lt 10; $j++){
                    $bitmap.SetPixel($start_x+$i, $start_y+$j, $color)
                }
            }

            #Top right pixels of row
            $start_x += 10
            $color = [System.Drawing.Color]::FromArgb(($colors[0,($l*2),($k*2+1)]), ($colors[1,($l*2),($k*2+1)]), ($colors[2,($l*2),($k*2+1)]), ($colors[3,($l*2),($k*2+1)]))
            
            for ($i=0; $i -lt 10; $i++){
                for ($j=0; $j -lt 10; $j++){
                    $bitmap.SetPixel($start_x+$i, $start_y+$j, $color)
                }
            }
        }

        #Bottom left pixels of row
        $start_y += 10

        for ($k = 0; $k -lt 16 ; $k++){
            $start_x = $xcoordsmap[$k]
            $color = [System.Drawing.Color]::FromArgb(($colors[0,($l*2+1),($k*2)]), ($colors[1,($l*2+1),($k*2)]), ($colors[2,($l*2+1),($k*2)]), ($colors[3,($l*2+1),($k*2)]))
            for ($i=0; $i -lt 10; $i++){
                for ($j=0; $j -lt 10; $j++){
                    $bitmap.SetPixel($start_x+$i, $start_y+$j, $color)
                }
            }


            #Bottom right pixels of row
            $start_x += 10
            $color = [System.Drawing.Color]::FromArgb(($colors[0,($l*2+1),($k*2+1)]), ($colors[1,($l*2+1),($k*2+1)]), ($colors[2,($l*2+1),($k*2+1)]), ($colors[3,($l*2+1),($k*2+1)]))
            
            for ($i=0; $i -lt 10; $i++){
                for ($j=0; $j -lt 10; $j++){
                    $bitmap.SetPixel($start_x+$i, $start_y+$j, $color)
                }
            }
        }
    }

#Export bitmap and generate video of exact length. Add video filename to list for later compilation
$bitmap.Save("./bitmap.bmp")
[string]$filename = "frame" + $frameindex + ".mp4"
./ffmpeg.exe -loop 1 -i bitmap.bmp -c:v libx264 -t $delay -y $filename
$videolist = $videolist + "file './frame" + $frameindex + ".mp4'`r`n"
$frameindex++
Write-Output ("Done with " + $frameindex + "frame`r`n")

}

#Compile video from pieces
Set-Content -Path ".\video_parts_list.txt" -Value $videolist -Force

#Add audio stream
./ffmpeg -f concat -safe 0 -i video_parts_list.txt -c copy compiled.mp4 -y
./ffmpeg -i compiled.mp4 -i matrix.mp3 -c copy -map 0:v:0 -map 1:a:0 -acodec aac -ar 48000 -ab 320000 -shortest matrix.mp4 -y

#Do some cleanup
Remove-Item ".\video_parts_list.txt"
Remove-Item ".\compiled.mp4"
Remove-Item "./bitmap.bmp"
for($pina = 0;$pina -lt $frameindex;$pina++){
    Remove-Item (".\frame" + $pina + ".mp4")
}

Write-Output All done.