#!/bin/bash
# 把"枫叶"配置 + 品牌（名字/图标/主题色/启动图）烧进 CatVod 手机版引擎仓库。
# 用法（Windows 用 Git Bash / WSL）:
#   bash bake.sh /d/maple/CatVod app
#   参数1: 克隆下来的仓库根目录
#   参数2: 模块名，手机竖屏版用 app（默认）；电视盒子用 tv
set -e

REPO="${1:-../CatVod}"
MODULE="${2:-app}"
HERE="$(cd "$(dirname "$0")" && pwd)"
RES="$REPO/$MODULE/src/main/res"
ASSETS_DIR="$REPO/$MODULE/src/main/assets"
BRAND="$HERE/assets/branding"

APP_NAME="枫叶影视"
C_PRIMARY="#E2533B"
C_PRIMARY_DARK="#962E1E"
C_ACCENT="#F59E42"

if [ ! -d "$REPO" ]; then
  echo "✗ 找不到仓库目录: $REPO"
  echo "  先执行: git clone https://github.com/FongMi/CatVod"
  exit 1
fi

echo "=== [1/6] 拷贝片源配置与脚本 ==="
mkdir -p "$ASSETS_DIR/py"
cp "$HERE/assets/box.json"    "$ASSETS_DIR/box.json"
cp "$HERE/assets/py/maple.py" "$ASSETS_DIR/py/maple.py"
echo "  ✓ $ASSETS_DIR/box.json"
echo "  ✓ $ASSETS_DIR/py/maple.py"

echo "=== [2/6] 换启动图标 (mipmap) ==="
if [ -d "$BRAND" ]; then
  for d in "$BRAND"/mipmap-*; do
    [ -d "$d" ] || continue
    name="$(basename "$d")"
    mkdir -p "$RES/$name"
    cp "$d"/*.png "$RES/$name/"
    echo "  ✓ $RES/$name/"
  done
fi

echo "=== [3/6] APP 改名 -> $APP_NAME ==="
SX=$(grep -rIl --include=strings.xml "app_name" "$RES" 2>/dev/null || true)
if [ -n "$SX" ]; then
  for f in $SX; do
    sed -i -E "s#(<string name=\"app_name\"[^>]*>)[^<]*(</string>)#\1${APP_NAME}\2#" "$f"
    echo "  ✓ $f"
  done
else
  echo "  (没找到 app_name，跳过)"
fi

echo "=== [4/6] 换主题色 ==="
COLORS=$(grep -rIl --include=colors.xml -e colorPrimary -e colorAccent "$RES" 2>/dev/null || true)
if [ -n "$COLORS" ]; then
  for f in $COLORS; do
    sed -i -E "s|(<color name=\"colorPrimary\">)[^<]*(</color>)|\1${C_PRIMARY}\2|g" "$f"
    sed -i -E "s|(<color name=\"colorPrimaryVariant\">)[^<]*(</color>)|\1${C_PRIMARY_DARK}\2|g" "$f"
    sed -i -E "s|(<color name=\"colorPrimaryDark\">)[^<]*(</color>)|\1${C_PRIMARY_DARK}\2|g" "$f"
    sed -i -E "s|(<color name=\"colorAccent\">)[^<]*(</color>)|\1${C_ACCENT}\2|g" "$f"
    echo "  ✓ $f"
  done
else
  echo "  (没找到 colors.xml 主题色，跳过)"
fi

echo "=== [5/6] 换启动图 (尽力替换) ==="
mkdir -p "$RES/drawable-nodpi"
cp "$BRAND/drawable-nodpi/splash.png" "$RES/drawable-nodpi/fy_splash.png" 2>/dev/null || true
FOUND=0
# a) 名为 splash/launch 的 drawable xml -> 重写为引用我们的启动图
for f in $(find "$RES" -path '*drawable*' \( -iname '*splash*.xml' -o -iname '*launch*.xml' \) 2>/dev/null || true); do
  cat > "$f" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<bitmap xmlns:android="http://schemas.android.com/apk/res/android"
    android:src="@drawable/fy_splash"
    android:gravity="center" />
XML
  echo "  ✓ 重写启动图 xml: $f"
  FOUND=1
done
# b) 名为 splash 的 png -> 直接覆盖
for f in $(find "$RES" -path '*drawable*' -iname '*splash*.png' 2>/dev/null || true); do
  cp "$BRAND/drawable-nodpi/splash.png" "$f"
  echo "  ✓ 覆盖启动图 png: $f"
  FOUND=1
done
[ "$FOUND" = "0" ] && echo "  (未找到显式启动图，已放入 fy_splash.png；若启动页没变化，把启动页截图发我精确改)"

echo "=== [6/6] 默认配置地址 -> assets://box.json ==="
JAVA_HITS=$(grep -rIn --include=*.java --include=*.kt \
  -E "loadConfig|setUrl\(|\"https?://[^\"]*json\"|clun\.top|box\.json" \
  "$REPO/$MODULE/src/main" 2>/dev/null | head -20 || true)
if [ -n "$SX" ]; then
  for f in $SX; do
    if grep -qE "<string[^>]*>https?://[^<]*json" "$f"; then
      sed -i -E 's#(<string[^>]*>)https?://[^<]*json(</string>)#\1assets://box.json\2#' "$f"
      echo "  ✓ 已自动改: $f  (http...json -> assets://box.json)"
    fi
  done
fi
if [ -n "$JAVA_HITS" ]; then
  echo "  源码中可能的默认配置引用（若上面没自动改，请把加载配置的那行地址改成 assets://box.json）："
  echo "$JAVA_HITS"
else
  echo "  (未在源码找到显式远程配置地址 —— 该 fork 可能默认就读 assets/box.json)"
fi

echo
echo "=== 下一步 ==="
echo "Android Studio 打开: $REPO  (选 $MODULE 模块)"
echo "  → Build → Generate Signed Bundle / APK → APK → 生成/选用签名 key → release"
echo "或命令行: cd $REPO && ./gradlew :$MODULE:assembleRelease"
echo "产物: $REPO/$MODULE/build/outputs/apk/release/*.apk"
