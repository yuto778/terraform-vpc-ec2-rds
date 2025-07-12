# Terraform で構築する AWS の VPC, EC2, ALB, RDS 環境

このリポジトリは、Terraform を使用して AWS 上に一般的な Web アプリケーションのインフラストラクチャを構
築するためのサンプルプロジェクトです。

VPC、サブネット、ALB、Auto Scaling Group による EC2、Multi-AZ 構成の RDS といった、基本的かつ重要なコンポーネントを、再利用性の高いモジュール構成で定義しています。

## アーキテクチャ

このプロジェクトでは、主にコストを最適化した以下の構成を構築します。

![構成図](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3930601/4d45cc9f-2978-4d68-9812-9d856e19d1f1.png)

主な特徴:

- コスト最適化: NATGateway を配置せず、EC2 インスタンスをパブリックサブネットに配置することでコストを削減しています。
- セキュリティ: EC2 へのインバウンド通信は ALB からに限定し、インスタンスへの直接アクセスは Session Manager を利用することで、セキュリティを確保しています。
- 高可用性: RDS は Multi-AZ 構成とし、データベースの可用性を高めています。

より一般的なセキュリティベストプラクティスに準拠した構成（EC2 をプライベートサブネットに配置し、NAT
Gateway を利用する構成）については、[こちら](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3930601/39c3f685-697b-4e5a-a5e2-7a66375f04a8.png) を参照してください。

## 主な技術要素と設計思想

- モジュール構成:
  ネットワーク(network)、コンピューティング(compute)、ロードバランサー(alb)、データベース(rds)をそれぞれ独立したモジュールとして定義しています。これにより、コードの再利用性と保守性を高めています。

- リモートステート管理:
  Terraform の State ファイルは S3 バケットに保存し、DynamoDB によるロック機構を導入しています。これにより、チームでの共同作業においても安全に State を管理できます。

- 環境分離:
  terraform workspace と envs/ ディレクトリ以下の .tfvars ファイルを組み合わせることで、dev(開発)、stg (ステージング)、prod (本番)といった環境ごとのインフラを安全に管理・デプロイすることが可能です。

## 前提条件

- Terraform (https://www.terraform.io/downloads.html) (v1.0.0 以降) がインストールされていること
- AWS CLI (https://aws.amazon.com/cli/) がインストールされ、クレデンシャルが設定済みであること
- AWS アカウント

## 利用方法

1. リモートステート(Backend)の準備
   最初に、Terraform の State ファイルを管理するための S3 バケットと DynamoDB テーブルを作成します。

```bash
   # bootstrap ディレクトリに移動

   cd bootstrap

   # 初期化とリソース作成

   terraform init
   terraform apply
```

apply 完了後、出力された bucket と dynamodb_table の名前を控えておきます。

2. Backend 設定ファイルの更新

プロジェクトルートにある backend.tf
を編集し、手順 1 で作成した S3 バケット名と DynamoDB テーブル名を指定します。

```hcl:backend.tf
terraform {
  backend "s3" {
    bucket         = "vpc-ec2-rds-statefile-〇〇〇〇" # 手順1で作成したS3バケット名
    key            = "terraform.tfstate"
    workspace_key_prefix = "envs"
    region         = "ap-northeast-1"
    dynamodb_table = "vpc-ec2-rds-statelock-〇〇〇〇" # 手順1で作成したDynamoDBテーブル名
    encrypt        = true
  }
}
```

3. 環境変数の設定

envs/ ディレクトリに、デプロイしたい環境名のファイルを作成します。ここでは開発環境 dev
を例にします。

envs/dev.tfvars を作成し、内容を記述します。

```hcl:envs/dev.tfvars
project     = "my-web-app-dev"
db_password = "YourSecurePassword123"
```

**注意:**
このファイルに直接パスワードを記述するのは、あくまでサンプルとしてです。実際のプロジェクトでは、AWS Secrets Manager などの利用を強く推奨します。

### 4. インフラのデプロイ

プロジェクトのルートディレクトリで、以下のコマンドを実行します。

```bash
# Terraformの初期化（Backend設定を読み込む）
terraform init

# 'dev'ワークスペースの作成と選択
terraform workspace new dev
terraform workspace select dev

# 実行計画の確認
terraform plan -var-file="envs/dev.tfvars"

# リソースの作成
terraform apply -var-file="envs/dev.tfvars"
```

apply が完了すると、outputs として ALB の DNS 名などが出力されます。

5. リソースの削除

作成したリソースをすべて削除するには、以下のコマンドを実行します。

```bash
 terraform destroy -var-file="envs/dev.tfvars"
```

## ディレクトリ構成

    .
    ├── backend.tf              # リモートステート(S3)の設定
    ├── bootstrap/              # リモートステート用のS3, DynamoDBを作成するTerraformコード
    ├── envs/                   # 環境ごとの変数ファイル(.tfvars)を格納
    │   └── dev.tfvars
    ├── main.tf                 # 各モジュールを呼び出すルートのtfファイル
    ├── modules/                # 再利用可能なモジュール群
    │   ├── alb/
    │   ├── compute/
    │   ├── network/
    │   └── rds/
    ├── outputs.tf              # ルートモジュールの出力
    └── variables.tf            # ルートモジュールで利用する変数を定義
