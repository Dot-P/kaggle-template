#!/usr/bin/env bash

# kgg: 実験フォルダをコピーし、結果フォルダは新規作成のみ行うスクリプト
# 使い方:
#   ./kgg divert [番号]
#   例:
#     ./kgg divert 002
#       -> experiments/exp002 をコピーし、
#          experiments/exp005 (例) を作成、results/exp005 (空) を作成
#     ./kgg divert
#       -> 最後に作られた実験フォルダをコピーソースとして使用し、
#          最新+1の番号でコピーと空フォルダ作成

COMMAND=$1
SRC_NUMBER=$2

# divert 以外のコマンドが来た場合は終了
if [ "$COMMAND" != "divert" ]; then
  echo "Usage: $0 divert [exp_number]"
  exit 1
fi

# 実験フォルダ名のプレフィックス
PREFIX="exp"
EXPERIMENTS_DIR="experiments"
RESULTS_DIR="results"

# experiments フォルダの中で最大の番号を返す関数
get_last_exp_number() {
  # expNNN の NNN 部分だけを取り出し、数値としてソートして最後を取る
  ls "$EXPERIMENTS_DIR" 2>/dev/null | grep -E "^$PREFIX[0-9]+" \
    | sed -E "s/^$PREFIX([0-9]+)/\1/" \
    | sort -n \
    | tail -n 1
}

# コピー元番号が指定されていない場合、最後に作られた実験フォルダをコピー元とする
if [ -z "$SRC_NUMBER" ]; then
  SRC_NUMBER=$(get_last_exp_number)
  if [ -z "$SRC_NUMBER" ]; then
    echo "コピー元の実験フォルダが存在しません。"
    exit 1
  fi
fi

# 現在の最後の実験番号を取得し、その次の番号を新しい番号とする
LAST_NUMBER=$(get_last_exp_number)
if [ -z "$LAST_NUMBER" ]; then
  # まだ何もない場合は 001 から始める
  NEW_NUMBER="001"
else
  NEXT=$((10#$LAST_NUMBER + 1))         # 先頭ゼロを含む数値を10進数として計算
  NEW_NUMBER=$(printf "%03d" "$NEXT")  # 3桁ゼロ埋め
fi

# コピー元フォルダ
SRC_EXP="$EXPERIMENTS_DIR/${PREFIX}${SRC_NUMBER}"

# コピー先フォルダ (experiments, results)
DST_EXP="$EXPERIMENTS_DIR/${PREFIX}${NEW_NUMBER}"
DST_RES="$RESULTS_DIR/${PREFIX}${NEW_NUMBER}"

# コピー元が存在するかチェック
if [ ! -d "$SRC_EXP" ]; then
  echo "コピー元フォルダがありません: $SRC_EXP"
  exit 1
fi

# experiments フォルダをコピー
echo "Copying $SRC_EXP to $DST_EXP ..."
cp -r "$SRC_EXP" "$DST_EXP"

# results 側はコピーではなく、空フォルダを作成
echo "Creating a new folder for results: $DST_RES ..."
mkdir -p "$DST_RES"

echo "Done."
exit 0