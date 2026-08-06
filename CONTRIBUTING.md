# 如何上架插件（提 PR）

GBot 主程序仓库是**私有**的。第三方作者**不需要**访问主仓，按下面做即可。

## 总流程

1. 用公开契约开发插件  
2. 打成符合规范的 zip，算 sha256  
3. Fork 本仓库 → 放入 `packages/` + 改 `marketplace.json` → 提 Pull Request  
4. 维护者审核合并后，用户刷新市场即可安装  

---

## 1. 开发插件

克隆公开契约：

https://github.com/a1515333102/GBot.PluginAbstractions

在插件 `.csproj` 里引用，且 **不要**复制 Abstractions DLL：

```xml
<ProjectReference Include="路径\GBot.PluginAbstractions.csproj">
  <Private>false</Private>
</ProjectReference>
```

`PluginInfo.Id` 用稳定英文，例如 `my_weather`（不要用中文当 id）。

`abstractionsMajor` 必须为 **1**（与当前契约主版本一致）。

---

## 2. 打 zip

Release 编译后，把**入口 DLL**（以及你自己的私有依赖 DLL，若有）打成扁平 zip：

```
my_weather-1.0.0.zip
  ├─ MyWeather.dll          ← 入口
  ├─ SomePrivateDep.dll     ← 可选
  └─ plugin.json            ← 可选，建议带
```

**禁止打进 zip：**

- `GBot.PluginAbstractions.dll`
- `Avalonia*.dll`
- 宿主 / `GBot.Core` 等

可用本仓脚本（已有编译好的 DLL 目录时）：

```powershell
.\tools\make-package.ps1 `
  -DllDir ".\bin\Release" `
  -Id "my_weather" `
  -Name "天气" `
  -Version "1.0.0" `
  -Author "你的名字" `
  -Description "查天气" `
  -EntryDll "MyWeather.dll" `
  -MinAppVersion "0.1.15"
```

会生成 `packages/my_weather-1.0.0.zip`，并打印 sha256；也可自动改 `marketplace.json`。

手动算哈希（PowerShell）：

```powershell
(Get-FileHash -Algorithm SHA256 .\packages\my_weather-1.0.0.zip).Hash.ToLowerInvariant()
```

---

## 3. 改 marketplace.json

在 `plugins` 数组里增加一项（或更新同 `id` 的版本）：

```json
{
  "id": "my_weather",
  "name": "天气",
  "version": "1.0.0",
  "author": "你的名字",
  "description": "查天气",
  "homepage": "https://github.com/你/仓库",
  "minAppVersion": "0.1.15",
  "abstractionsMajor": 1,
  "downloadUrl": "packages/my_weather-1.0.0.zip",
  "sha256": "（小写 hex）",
  "entryDll": "MyWeather.dll"
}
```

`downloadUrl` 用相对路径 `packages/xxx.zip` 即可。

同步改顶层 `updatedAt`（UTC）。

---

## 4. 提 Pull Request

1. Fork https://github.com/a1515333102/GBot-PluginMarketplace  
2. 提交：
   - `packages/你的插件-版本.zip`
   - 更新后的 `marketplace.json`
3. 打开 PR，说明插件做什么、测试过的 GBot 版本  
4. 等维护者合并  

合并后用户：**GBot → 插件 → 市场 → 刷新清单 → 安装**（安装后默认关闭，需手动开开关）。

---

## 审核会看什么

- zip 能否解压、有入口 DLL、无禁止程序集  
- sha256 是否匹配  
- `id` 是否稳定、是否与已有插件冲突  
- `minAppVersion` / `abstractionsMajor` 是否合理  
- 是否明显恶意 / 不可信  

插件与宿主**同进程**，无沙箱——请只提交你信任、可维护的代码。
