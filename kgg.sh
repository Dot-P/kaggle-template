#!/usr/bin/env bash

# kgg: 実験フォルダをコピーし、結果フォルダを作成するスクリプト
# また、Kaggle への submit コマンドも実行可能
#
# 使い方:
#   ./kgg.sh divert [exp_number]
#     - 実験フォルダをコピーし、新しい番号で results/ を作成
#   ./kgg.sh submit exp002 "commit message"
#     - results/exp002/submission.csv を Kaggle にアップロード
#
# Example:
#   ./kgg.sh submit exp002 "My experiment submission"

COMMAND=$1

# `submit` コマンドの処理
if [ "$COMMAND" = "submit" ]; then
  EXP_NUMBER=$2
  COMMIT_MESSAGE=$3

  # 必須引数のチェック
  if [ -z "$EXP_NUMBER" ] || [ -z "$COMMIT_MESSAGE" ]; then
    echo "Usage: $0 submit expXXX \"commit message\""
    exit 1
  fi

  # カレントディレクトリの名前を取得（Kaggle コンペ名として使用）
  COMPETITION_NAME=$(basename "$PWD")

  # 提出ファイルのパス
  SUBMISSION_FILE="./results/$EXP_NUMBER/submission.csv"

  # ファイルの存在チェック
  if [ ! -f "$SUBMISSION_FILE" ]; then
    echo "Error: Submission file not found: $SUBMISSION_FILE"
    exit 1
  fi

  # Kaggle に提出
  echo "Submitting $SUBMISSION_FILE to Kaggle competition: $COMPETITION_NAME"
  kaggle competitions submit -c "$COMPETITION_NAME" -f "$SUBMISSION_FILE" -m "$COMMIT_MESSAGE"

  exit 0
fi

# `divert` コマンドの処理
if [ "$COMMAND" = "divert" ]; then
  SRC_NUMBER=$2

  PREFIX="exp"
  EXPERIMENTS_DIR="experiments"
  RESULTS_DIR="results"

  # experiments フォルダの中で最大の番号を返す関数
  get_last_exp_number() {
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
    NEW_NUMBER="001"
  else
    NEXT=$((10#$LAST_NUMBER + 1))
    NEW_NUMBER=$(printf "%03d" "$NEXT")
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

  # config.yaml の experiment_name を新しい番号に更新
  CONFIG_FILE="$DST_EXP/config.yaml"
  if [ -f "$CONFIG_FILE" ]; then
    echo "Updating experiment_name in $CONFIG_FILE to exp$NEW_NUMBER..."
    # experiment_name を新しい番号に置き換え
    sed -i "s/experiment_name: exp[0-9]\+/experiment_name: exp$NEW_NUMBER/" "$CONFIG_FILE"
  else
    echo "Error: config.yaml not found in $DST_EXP"
    exit 1
  fi

  echo "Done."
  exit 0
fi

# どのコマンドにも一致しない場合
echo "Usage: $0 {divert|submit}"
exit 1
