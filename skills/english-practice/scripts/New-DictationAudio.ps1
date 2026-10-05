param(
    [Parameter(Mandatory=$true)][ValidateRange(1,2147483647)][int]$ListNumber,
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string[]]$Words,
    [string]$OutputRoot = (Get-Location).Path,
    [string]$VoiceName = 'Microsoft Zira Desktop',
    [string]$TimeZoneId = 'China Standard Time'
)
$ErrorActionPreference = 'Stop'
foreach ($word in $Words) {
    if ([string]::IsNullOrWhiteSpace($word)) { throw 'Words must not contain empty entries.' }
}
Add-Type -AssemblyName System.Speech
$projectRoot = [System.IO.Path]::GetFullPath($OutputRoot)
$localNow = [TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTime]::UtcNow, $TimeZoneId)
$datedDirectory = Join-Path $projectRoot ('Artifacts\Dictation\' + $localNow.ToString('yyyy-MM-dd'))
$outputDirectory = Join-Path $datedDirectory $localNow.ToString('HHmmssfff')
if (Test-Path -LiteralPath $outputDirectory) { throw 'Output run already exists; retry with a new timestamp.' }
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
$outputPath = Join-Path $outputDirectory "Word list $ListNumber.wav"
$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
$pcm = New-Object System.IO.MemoryStream
$writer = $null
try {
    $synth.SelectVoice($VoiceName)
    $synth.Rate = -2
    $format = New-Object System.Speech.AudioFormat.SpeechAudioFormatInfo(16000, [System.Speech.AudioFormat.AudioBitsPerSample]::Sixteen, [System.Speech.AudioFormat.AudioChannel]::Mono)
    $repeatGap = New-Object byte[] 32000
    $wordGap = New-Object byte[] 96000
    for ($i = 0; $i -lt $Words.Count; $i++) {
        $clip = New-Object System.IO.MemoryStream
        try {
            $synth.SetOutputToAudioStream($clip, $format)
            $escaped = [System.Security.SecurityElement]::Escape($Words[$i].Trim())
            $synth.SpeakSsml('<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="en-US"><prosody rate="+25%">' + $escaped + '</prosody></speak>')
            # SetOutputToAudioStream yields raw PCM, without a RIFF header.
            $data = $clip.ToArray()
            if ($data.Length -eq 0) { throw 'Synthesis returned empty audio.' }
            $pcm.Write($data, 0, $data.Length)
            $pcm.Write($repeatGap, 0, $repeatGap.Length)
            $pcm.Write($data, 0, $data.Length)
            if ($i -lt $Words.Count - 1) { $pcm.Write($wordGap, 0, $wordGap.Length) }
        } finally { $synth.SetOutputToNull(); $clip.Dispose() }
    }
    $writer = New-Object System.IO.BinaryWriter([System.IO.File]::Open($outputPath, [System.IO.FileMode]::CreateNew))
    $writer.Write([System.Text.Encoding]::ASCII.GetBytes('RIFF'))
    $writer.Write([int](36 + $pcm.Length))
    $writer.Write([System.Text.Encoding]::ASCII.GetBytes('WAVEfmt '))
    $writer.Write([int]16)
    $writer.Write([int16]1)
    $writer.Write([int16]1)
    $writer.Write([int]16000)
    $writer.Write([int]32000)
    $writer.Write([int16]2)
    $writer.Write([int16]16)
    $writer.Write([System.Text.Encoding]::ASCII.GetBytes('data'))
    $writer.Write([int]$pcm.Length)
    $writer.Write($pcm.ToArray())
    $writer.Dispose()
    $writer = $null
    [pscustomobject]@{ Path=$outputPath; WordCount=$Words.Count; ReadingCount=2*$Words.Count; DurationSeconds=$pcm.Length/32000 } | ConvertTo-Json
} finally {
    if ($null -ne $writer) { $writer.Dispose() }
    $synth.Dispose()
    $pcm.Dispose()
}
