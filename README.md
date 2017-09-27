# README

## Install

```
$ npm install -g pm2
$ npm install
```

## Start development

```
$ npm run dev
```

## Start production

```
$ npm start
```

## Docker 開発環境

Docker関連設定は `/docker` ディレクトリで管理しています。

```
$ cd docker
```

### 事前準備

#### ① Docker install
ローカル環境に Dockerをインストールします。
インストール手順は [Docker公式サイト](https://www.docker.com/) をご参照ください。


### Docker image build
初回、または Dockerfile の修正がある場合は build してください。

```
$ docker-compose build
```

### Docker container 起動 ( -d: バックグラウンド起動 )
以下のコマンドで Docker container が起動されます。
```
$ docker-compose up -d
```
起動完了したら
ブラウザで `http://localhost` へアクセスします。
正常に表示されない場合は log を確認しながら、必要な設定を行います。

### Docker container 停止

```
$ docker-compose stop
```

### Docker container 停止＆削除

```
$ docker-compose down
```

### Docker Container 確認

```
$ docker ps -a
```

### Docker Container に接続

```
$ docker exec -it [imagename] bash
```

### Docker log 確認

```
$ docker logs [imagename]
```
