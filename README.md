# EnglishFlow｜英语练习流

把听写、词汇和口语串起来的 AI 英语练习助手。

EnglishFlow 是一个可复用的 AI agent skill，包含练习流程、学习记录规范和 Windows 离线听写音频脚本。它不是独立 App，也不自带语音通话或图片识别模型。

## 能做什么

- **听写照片整理**：在支持图片理解的环境中，整理确认后的单词与词义薄弱点，模糊笔迹等待确认。
- **复听音频**：从确认的错词生成 WAV；每词读两遍，两遍间隔 1 秒，词间间隔 3 秒。
- **可选错词本**：开启后记录需要复习的正确单词、来源和实际复习结果，默认不保存错误拼写。
- **词汇激活**：词义回忆 → 常见搭配 → 自己造句 → 情景翻译 → 纠错与整段重译。
- **口语陪练**：日常交流、词汇练习、可选雅思话题；纠错后继续提问。
- **跨对话续练**：记录实际表现与下一步，从保存的检查点继续。

认识单词、跟读成功、独立说出单词是不同的证据。不会把导入照片当成已掌握，也不会凭文字转写评价发音。

## 快速开始

1. 克隆仓库：

   ```bash
   git clone https://github.com/Caspainnn/englishflow.git
   ```

2. 将整个 `skills/english-practice` 文件夹放入支持该 skill 格式的 agent 的技能目录。也可以直接让 agent 读取 [SKILL.md](skills/english-practice/SKILL.md)，按其流程执行。
3. 创建一个自己的学习文件夹，将 [模板](skills/english-practice/assets/templates)中的 `SETTINGS.md` 和 `LEARNING.md` 复制进去，调整目标、语言和复习设置。学习数据放在自己的文件夹。
4. 告诉 agent 学习文件夹的路径：

   > 使用 $english-practice，学习目录是我的 EnglishLearning 文件夹。先读取 SETTINGS.md 和 LEARNING.md，开始今天的英语练习。

首次使用尚无词表，可以先日常对话，也可以上传词表照片。语音练习需要运行环境支持语音；照片整理需要图片理解；保存记录需要文件访问。只有文本时可进行文字练习，发音不评分。

## 听写与复听

上传照片时先说明标记含义，例如“三角形表示词义不熟，红色是订正”。确认模糊单词后，可说：

> 把这张照片里订正的单词生成听写音频。开启错词记录，方便下次复听。

默认 `dictation_history: off`，错词选择只用于本次音频。改为 `on` 后，agent 将确认的正确单词保存到 `Dictation/review.md`。生成音频不会自动标记复习完成。

当前音频 helper 支持 Windows PowerShell、System.Speech 和 Microsoft Zira Desktop，无需在线 TTS API。图片识别与教学由所在 AI 环境完成，可能涉及该环境的费用。其他系统仍可使用练习流程，但需自行提供适配的音频工具；本项目不自动安装替代服务。

从仓库根目录手动生成：

```powershell
& .\skills\english-practice\scripts\New-DictationAudio.ps1 -ListNumber 1 -Words @('engage','athlete') -OutputRoot C:\EnglishLearning
```

在 PowerShell 中也可直接调用脚本并传入 `-Words @('engage','athlete')`。如从其他 shell 调用，推荐使用这种数组方式的 PowerShell 命令，避免参数解析差异。可通过 `-VoiceName` 和 `-TimeZoneId` 指定已安装语音和 Windows 时区。

音频保存在学习目录的 `Artifacts/Dictation/日期/运行时间/Word list 1.wav`，不同运行保留不同版本。默认语速为 Rate -2 加 SSML +25%，并非精确的播放速度倍数。脚本不识别图片；输入必须是确认后的正确单词。

## 学习记录

```text
EnglishLearning/
  SETTINGS.md
  LEARNING.md
  WordLists/WordList-01/
    summary.md
    intake/
    source/
    practice/
  Sessions/
  Dictation/review.md       # 开启错词记录时
  Artifacts/Dictation/
  REVIEW_PLAN.md           # 可选：自己的复习日程
```

词表数量与每表大小不限。照片导入不产生口语评分；未测试保持未测试。中断时保留未完成任务，下一次读取文件继续。只有实际产生记录时才创建会话日志。

## 范围与限制

- 默认用英语练习与反馈，可按要求切换语言；中文情景翻译可换为学习者的母语。
- 雅思是可选模式；自编题会标明练习题，词汇等级不等于雅思分数。
- 音频或文件能力取决于 agent 环境，不保证不同产品之间自动共享状态。
- 学习照片、录音与记录留在自己的学习目录；本仓库不包含作者的个人练习数据。使用 AI 环境时，数据处理遵循该环境的规则。

欢迎通过 Issue 反馈流程问题，或提交改进与其他系统的音频适配。

## License

MIT，见 [LICENSE](LICENSE)。
