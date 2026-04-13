# 目的

シンプル掲示板

# 機能

- 投稿機能
- 一覧表示
  - 投稿された一覧
    - 各親記事に返信できる
    - 返信はスレッドで表示

# 技術

- ruby 3.2.2
- sinatra
  - puma
- active_record
  - SQLite

# 実行環境

- port 8000
- 2 worker
  - 1 thread
- pumactl start で起動させる
