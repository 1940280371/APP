# 云端编译枫叶影视 APK（不用你电脑、不用装 Android Studio）

> 思路：把本文件夹推到 GitHub，用 GitHub 的**免费服务器**替你把真·CatVod 引擎 APK 编出来。
> 你全程只需建个仓库、传文件、点一下"运行"，等几十分钟去下载 APK。
> 生成的 APK 已用调试密钥自动签名，**手机可直接安装**。
>
> 编译时 `bake.sh` 会自动把 APP **改名为「枫叶影视」+ 换成枫红主题 + 换"枫"字图标 + 换启动图**，
> 并烧入枫叶片源配置，成品就是一个打着你自己标的影视APP。

---

## 你需要做的（纯网页操作，不用命令行）

### 1. 注册 GitHub 账号
打开 https://github.com 注册一个（免费）。

### 2. 新建一个空仓库
- 点右上角 **"+" → New repository**
- 名字随便起，比如 `fengye-build`
- 选 **Public**（私有也行，但公有更省事）
- **不要**勾 "Add a README"（保持空仓库）
- 点 **Create repository**

### 3. 把本文件夹的内容传上去
最简单：在新建好的仓库页面，点 **"uploading an existing file" / 拖拽上传**，
把本文件夹里的**所有内容**（`fengye-catvod/` 文件夹 + `.github/` 文件夹）拖进去，
写个提交说明（随便写），点 **Commit changes**。

> 也可以用 GitHub Desktop 之类的工具，本质一样：把本目录推成仓库根目录。

### 4. 点一下开始编译
- 进仓库顶部的 **Actions** 标签
- 第一次会提示 "enable workflows"，点 **I understand / 启用**
- 左侧选 **"编译枫叶影视APK"** → 右侧 **Run workflow** → 再点一次 **Run workflow**
- （其实你第 3 步一提交，它也会自动触发编译）

### 5. 等 + 下载
- 编译一般 **10–30 分钟**，页面上能看到实时日志
- 编完后在本次运行的页面底部 **Artifacts** 区，点 **fengye-app-debug** 下载
- 解压得到 `app-debug.apk`

### 6. 装手机
把 `app-debug.apk` 传到手机 → 允许"安装未知来源" → 安装。
打开首页即是「枫叶[py]」，能搜片、选集、走解析播放。

---

## 常见问题
- **编译失败/红叉**：点进运行看红色日志。最常见是网络或 SDK 版本问题，把报错发我，我改 `build.yml` 再让你重跑。
- **安装提示"已损坏/无法安装"**：确认下载的是 `app-debug.apk`（已签名）。若你改用 release，需要自己配签名。
- **想换源/加源**：改 `fengye-catvod/assets/box.json` 的 `sites`，重新传仓库、重跑。
- **完全免费**：GitHub Actions 免费额度对个人足够，编译完可删仓库。

## 文件夹说明
| 路径 | 作用 |
|------|------|
| `.github/workflows/build.yml` | 云端编译脚本（自动拉源码+烧配置+编译+上传） |
| `fengye-catvod/assets/box.json` | 枫叶片源配置（`api` 已设 `assets://py/maple.py` 随包） |
| `fengye-catvod/assets/py/maple.py` | 采集脚本，随包打包 |
| `fengye-catvod/bake.sh` | 烧入配置的脚本（被 workflow 调用） |
