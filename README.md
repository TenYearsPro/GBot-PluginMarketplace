# GBot 插件市场

GBot 官方插件目录仓库。客户端默认从此仓库拉取清单并下载插件包。

## 目录

| 路径 | 说明 |
|------|------|
| `marketplace.json` | 市场清单 |
| `packages/*.zip` | 插件包（扁平 DLL） |

## 默认清单 URL

`https://raw.githubusercontent.com/a1515333102/GBot-PluginMarketplace/master/marketplace.json`

## 给别人用（上架）

1. 在 GBot 主仓库打插件包：
   `powershell
   .\scripts\pack-plugin.ps1 -Project "插件.csproj" -Id "my_plugin" -Name "名字" -Version "1.0.0" -Author "你" -Description "说明" -EntryDll "插件.dll" -MarketRoot "D:\GBot-PluginMarketplace"
   `
2. 进入本仓库，提交并推送 `marketplace.json` 与 `packages/*.zip`
3. 用户打开 GBot → 插件 → 市场 → 刷新清单 → 安装

## 包规范

- zip 内为入口 DLL + 私有依赖（扁平，无子目录）
- **禁止**包含 `GBot.PluginAbstractions.dll` / Avalonia / 宿主程序集
- 清单必须带 `sha256`；`id` 用稳定英文
- 详见 GBot 主仓 `docs/开发文档.md` 第 9 节

## 安全提示

插件与宿主同进程运行，请只上架可信来源的插件。
