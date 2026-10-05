# Dictation audio

Use this only after the learner accepts the post-intake audio offer or directly requests audio. Select the incorrect entries from the actual photo before calling the helper; the helper does not perform image recognition.

Run Windows PowerShell without loading the user's profile:

```powershell
& .\skills\english-practice\scripts\New-DictationAudio.ps1 -ListNumber 5 -Words @('engage','athlete') -OutputRoot 'C:\EnglishLearning'
```

The helper uses offline Windows System.Speech and Microsoft Zira Desktop, with no API charges or additional packages. It outputs under `Artifacts/Dictation/YYYY-MM-DD/HHmmssfff/Word list x.wav`, using the configured Windows timezone (default Asia/Shanghai). Distinct run folders preserve previous versions. Persist canonical review words only when dictation_history is enabled in SETTINGS.md. The returned JSON gives the absolute path, word count, reading count and measured duration.

Only speech is accelerated: synth Rate -2 with SSML rate +25%. This is a synthesis speed setting, not an exact 1.25 playback time stretch. Each generated word clip is repeated twice. Explicit PCM silence is 1 second between repeats and 3 seconds between pairs; natural pauses inside a synthesizer clip can add to perceived silence. There is no inserted 3-second tail after the last word.

Check that generation succeeds, the WAV is readable, duration is positive and reading count is twice the selected count. Render using an absolute path: `![Word list 5](/absolute/path/Word list 5.wav)` and provide a download link with its target wrapped in angle brackets because the name contains spaces. Report duration from the generated file, not an estimate. If the voice or System.Speech is unavailable, report the limitation rather than installing a replacement or switching services automatically.
