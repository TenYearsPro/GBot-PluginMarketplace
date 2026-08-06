# GBot 插件市场

公开的插件目录与包分发仓库。GBot 客户端默认从此拉取清单并安装插件。

- 市场仓：https://github.com/a1515333102/GBot-PluginMarketplace  
- 插件契约（公开）：https://github.com/a1515333102/GBot.PluginAbstractions  

> GBot 主程序可为私有；上架**不需要**主仓库权限。

## 用户怎么装

打开 GBot → **插件** → **市场** → **刷新清单** → **安装** → 在「已安装」打开开关。

清单地址：

`https://raw.githubusercontent.com/a1515333102/GBot-PluginMarketplace/master/marketplace.json`

## 作者怎么发布（提 PR）

详细步骤见 **[CONTRIBUTING.md](./CONTRIBUTING.md)**。

一句话：

1. 引用公开的 `GBot.PluginAbstractions` 写插件  
2. 打 zip（勿含 Abstractions / Avalonia）  
3. Fork 本仓 → 放进 `packages/` + 改 `marketplace.json` → 提 PR  
4. 合并后即可被用户安装  

## 目录

| 路径 | 说明 |
|------|------|
| `marketplace.json` | 市场清单 |
| `packages/*.zip` | 插件包 |
| `tools/make-package.ps1` | 从 DLL 目录打 zip 并更新清单 |
| `CONTRIBUTING.md` | 上架规范 |

## 安全

插件与宿主同进程，无沙箱。请只安装 / 只合并可信来源。
