# 把真正的 CatVod 引擎打进手机版 APK（含"枫叶影视"品牌）

> `fengye-release.apk`(25KB) 只是 WebView 网址壳。要得到和"大师兄/王子/猫头鹰/火花"一样的**真·影视APP**，必须把 **CatVod 引擎**（Python 运行时 + 爬虫框架 + 播放器内核）编译进 APK。本环境装不全 NDK，故需在你**本地电脑**编译，或用 GitHub **云端编译**（见 `fengye-build/`）。

目标：一个**带完整引擎的竖屏手机 APK**，**打开即「枫叶影视」**（自定义名字 + 图标 + 红色主题 + 启动图），首页是「枫叶[py]」片源（zzztool / maihaolian / cd-zj），自带 21 个解析接口；配置与 `maple.py` 随包（`assets://`），离线可用。

---

## 选的底座
- **手机竖屏版：`FongMi/CatVod`** 的 `app` 模块（`tv` 模块是电视盒子版）。
- 它是很多"烂大街壳子"的同源开源底座，自带 Python 解释器(.so) + 爬虫框架 + 播放器。
- 仓库：`https://github.com/FongMi/CatVod`

---

## bake.sh 会做什么（6 步，自动完成）
1. 把 `assets/box.json`、`assets/py/maple.py` 拷进引擎 `assets/`（片源随包）
2. **换启动图标**：把我们做的"枫"字图标（各分辨率 + 圆形）覆盖到 `res/mipmap-*`
3. **改名**：`strings.xml` 的 `app_name` → **枫叶影视**
4. **换主题色**：`colors.xml` 的 `colorPrimary` → 枫红 `#E2533B`（深色 `#962E1E`、强调 `#F59E42`）
5. **换启动图**：重写启动 drawable 指向我们的启动图（尽力替换）
6. **默认配置地址** → `assets://box.json`

---

## 本地编译（Windows，三步出包）
### 1. 克隆手机版引擎
Git Bash：
```bash
cd /d/maple
git clone https://github.com/FongMi/CatVod
```
### 2. 一键烧入（配置 + 品牌）
```bash
cd /d/maple/fengye-catvod
bash bake.sh /d/maple/CatVod app
```
### 3. 编译
Android Studio 打开 `D:\maple\CatVod` → Build → Generate Signed APK → release
或命令行：`cd /d/maple/CatVod && ./gradlew :app:assembleRelease`
产物：`CatVod/app/build/outputs/apk/release/app-release.apk`

---

## 云端编译（不用装 Android Studio）
见同级 `../fengye-build/README.md`：把本目录 + `.github/` 上传到 GitHub，点一下 Actions 就出包。

---

## 文件清单（本目录）
| 文件 | 说明 |
|------|------|
| `assets/box.json` | 片源配置（仅枫叶源 + 21 解析，`api=assets://py/maple.py`） |
| `assets/py/maple.py` | 枫叶采集脚本，随包 |
| `assets/branding/` | 品牌图标（mipmap-*）+ 启动图（drawable-*），`bake.sh` 会拷入工程 |
| `bake.sh` | 一键烧录（配置 + 名字 + 图标 + 主题色 + 启动图） |
| `gen_branding.py` | 生成上面品牌图片的脚本（仅留档，运行时不需要） |

---

## 说明 / 排错
- **spider** 默认指向 `https://clun.top/jar/xs.jar`（运行时拉取）。想 100% 离线：把该 jar 放进 `assets/`，在 `box.json` 改 `assets://spider.jar`。
- **换源/加源**：编 `assets/box.json` 的 `sites[0].ext.sites`，重新 `bake.sh` + 编译。
- **启动图没变化**：不同 fork 的启动页实现不同，脚本是"尽力替换"。把首次构建后的启动页截图发我，我按实际文件精确改。
- **图标没变化（较新系统）**：若该 fork 用了自适应图标（`mipmap-anydpi-v26/ic_launcher.xml`），可能需要另处理，告诉我即可。
- **打开后首页空白**：默认配置没被自动改到。进 App 设置 → 配置 → 填 `assets://box.json`，或按 `bake.sh` 打印的 Java 行手动改一处。
