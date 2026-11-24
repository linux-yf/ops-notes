# Typora + Git 同步笔记至 GitHub 全流程指南（Windows）

适用环境：Windows 10/11 + Typora + GitHub 私有仓库
本文档记录最终验证可用的完整配置，按顺序执行即可复现



## 一、前置准备

### 1.1 安装并配置 Git

安装 Git 后，配置提交者身份（换成自己的信息）：

```
git config --global user.name "你的GitHub用户名"
git config --global user.email "你的邮箱"
git config --global init.defaultBranch main
```

> 邮箱可用 GitHub 的 noreply 邮箱（GitHub → Settings → Emails 页面查看）保护隐私。
> 验证：`git config --global --list`

### 1.2 配置 SSH 密钥（关键，必须在 Windows 标准位置）

**注意**：如果平时用 MobaXterm 等工具操作 SSH，它的配置和 Windows 系统的是隔离的。Typora 调起的 Git 只认 Windows 标准位置的密钥，务必按下面操作。

在**纯 cmd**（Win+R → cmd）中生成密钥：

```
ssh-keygen -t ed25519 -C "你的邮箱"
```

一路回车，密钥生成在 `C:\Users\你的用户名\.ssh\` 下。

复制公钥内容并添加到 GitHub（**Settings → SSH and GPG keys → New SSH key**）：

```
type %USERPROFILE%\.ssh\id_ed25519.pub
```

创建 `C:\Users\你的用户名\.ssh\config` 文件（用记事本，保存时选"所有文件"类型、文件名写 `config`，避免变成 config.txt）：

```
Host github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
```

> 常见坑：MobaXterm 里的 ssh 配置（`~/.ssh/config`）对 Typora 无效，密钥必须放在 `%USERPROFILE%\.ssh\` 下。

验证（在纯 cmd 中执行）：

```
ssh -T git@github.com
```

看到 `Hi 你的用户名! You've successfully authenticated` 即成功。

### 1.3 初始化仓库

```
git clone git@github.com:用户名/ops-notes.git
# 或本地已有目录时：
cd F:\ops-notes
git init
git add .
git commit -m "init"
git branch -M main
git remote add origin git@github.com:用户名/ops-notes.git
git push -u origin main
```

> 易错点：`git init` 后必须先 `add` + `commit` 成功，分支才真正存在；否则 `branch -M` 和 `push` 都会报错。



## 二、Typora 图片设置（保证图片跟随仓库同步）

**文件 → 偏好设置 → 图像**，配置如下：

| 配置项                       | 设置值                  |
| ---------------------------- | ----------------------- |
| 插入图片时                   | **复制到指定路径**      |
| 路径                         | `./assets`              |
| 对本地位置的图片应用上述规则 | ✅                       |
| 对网络位置的图片应用上述规则 | ✅                       |
| 优先使用相对路径             | ✅                       |
| 插入时自动转义图片 URL       | ✅（图片名含中文时必需） |
| 上传服务                     | 无                      |

**要点**：

- 路径必须以 `./` 开头（相对路径），**不要用绝对路径**（如 `F:\ops-notes\photo`），否则 Git 仓库外的图片无法同步，换电脑必裂图
- 「优先使用相对路径」和「复制到指定路径」**必须同时开启**，只开前者图片仍指向临时文件
- 所有文档的图片统一进仓库根目录的 `assets/` 文件夹，Markdown 链接由 Typora 自动生成（根目录文档 `./assets/x.png`，子目录文档 `../assets/x.png`）
- 遗留的旧图片：菜单 **格式 → 图像** 里用批量处理选项迁移；旧的同名 `.assets` 文件夹可删除



## 三、同步脚本配置

### 3.1 创建 git-sync.bat

在仓库根目录创建 `git-sync.bat`（注意保存为 ANSI 或 UTF-8 编码的 bat，不要带 .txt 后缀）：

```
@echo off
cd /d F:\ops-notes
git add .
git diff --cached --quiet
if %errorlevel% equ 0 exit /b 0
git commit -m "sync %date:/=-% %time%"
git push origin main
```

> **关键点**：
>
> - 必须用 `git add .`（提交整个目录），不能用 `git add "${currentPath}"`——后者只提交当前 md 文件，新插入的图片不会进仓库（这是实际踩过的坑）
> - `git diff --cached --quiet` 退出码 **0=无改动、1=有改动**，所以判断条件是 `equ 0` 时直接退出（跳过空提交）
> - `cd /d` 切换到仓库根目录，路径按实际修改

### 3.2 配置 Typora 自定义导出

**文件 → 偏好设置 → 导出 → "+" → Custom（自定义）**：

- 命名：`Git Sync`（随意）
- 命令行：`call F:\ops-notes\git-sync.bat`
- **勾选「导出后显示命令行输出」**——方便看到执行结果，出错不盲



## 四、日常使用与验证

每次写完笔记，**文件 → 导出 → Git Sync**（可绑定快捷键），一键完成 add → commit → push。

完整链路验证清单：

1. 插入图片后按 `Ctrl + /` 源码模式确认链接是 `./assets/xxx.png` 相对路径
2. 本地 Typora 图片正常显示
3. 点导出，命令行输出显示 push 成功
4. GitHub 网页打开该 md，图片正常显示（GitHub 渲染图片靠仓库内文件 + 相对路径，无需图床）



## 五、常见问题速查

| 现象                                       | 原因与解决                                                   |
| ------------------------------------------ | ------------------------------------------------------------ |
| `Permission denied (publickey)`            | Typora 进程没读到密钥。确认密钥在 `%USERPROFILE%\.ssh\`，config 文件名正确（非 config.txt），纯 cmd 里 `ssh -T git@github.com` 通过 |
| 图片本地能显示、GitHub 裂图                | `git add` 没包含 assets（确认脚本用 `git add .`）；或 md 里链接是绝对路径 |
| GitHub 上看不到 assets 文件夹              | 图片未被提交（git 不跟踪空文件夹）；用 `git status` 确认状态 |
| 脚本输出 "No changes, skip" 但文件明明改了 | 检查脚本判断条件是否写反：`equ 0` = 无改动才跳过             |
| 导出无任何反馈                             | 勾选「导出后显示命令行输出」；或手动在 cmd 里跑一次 bat 看输出 |
| push 卡住不动                              | HTTPS 模式下认证弹窗被挡；换 SSH 或在任务栏找 Credential Manager 窗口 |
| 文档挪目录后图片裂图                       | 在 Typora 侧边栏文件树里移动文件（自动更新链接），不要用资源管理器移动 |
| config 变成 config.txt                     | 记事本保存时选"所有文件"类型，文件名只写 `config`            |