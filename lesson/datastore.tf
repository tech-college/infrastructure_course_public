# RDS settings
resource "aws_db_parameter_group" "example" {
  name   = "YOUR-DB-NAME"
  family = "mysql8.0"

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}

resource "aws_db_option_group" "example" {
  name                 = "YOUR-DB-OPTION-NAME"
  engine_name          = "mysql"
  major_engine_version = "8.0"

  option {
    option_name = "MARIADB_AUDIT_PLUGIN"
  }
}

resource "aws_db_subnet_group" "example" {
  name = "YOUR-DB-SUBNET-NAME"
  subnet_ids = [
    aws_subnet.private_0.id,
    aws_subnet.private_1.id,
  ]
}

module "mysql_sg" {
  source = "./security_group"

  name   = "YOUR-MYSQL-SG-NAME"
  vpc_id = aws_vpc.example.id
  port   = 3306
  cidr_blocks = [
    aws_vpc.example.cidr_block,
  ]
}

resource "aws_db_instance" "example" {
  identifier                 = "YOUR-RDS-NAME"
  engine                     = "mysql"
  engine_version             = "8.0"
  instance_class             = "db.t3.small"
  allocated_storage          = 20
  max_allocated_storage      = 100
  storage_encrypted          = true
  kms_key_id                 = aws_kms_key.example.arn
  username                   = "admin"
  password                   = aws_ssm_parameter.rds_admin_password.value
  multi_az                   = true
  publicly_accessible        = false
  backup_window              = "15:10-15:40" #UTCで時間を設定を行う。左記しては日本で0:10～0:40となる
  backup_retention_period    = 30
  maintenance_window         = "sun:16:10-sun:16:40"
  auto_minor_version_upgrade = false
  deletion_protection        = false  #通常は誤ってRDSインスタンスを削除しないようにtrueを指定しますが、今回は学習のため作成/削除を繰り返すためfalseにしています。
  skip_final_snapshot        = true   #通常はRDSインスタンス削除時にスナップショットを取得し削除後も復元可能にするためにfalseを指定する場合が多いが、スナップショットが残っていると紐づくaws_db_option_groupが削除できなくなるため、今回はtrueにしています。
  #final_snapshot_identifier  = "final_snapshot" #skip_final_snapshotをfalseにした場合はsnapshotの名前を指定します。今回はスナップショットを取得しないためコメントアウトしています。
  port                       = 3306
  apply_immediately          = false
  vpc_security_group_ids = [
    module.mysql_sg.security_group_id
  ]
  parameter_group_name = aws_db_parameter_group.example.name
  option_group_name    = aws_db_option_group.example.name
  db_subnet_group_name = aws_db_subnet_group.example.name

  lifecycle {
    ignore_changes = [
      password
    ]
  }
}

# Elasti Cache settings
resource "aws_elasticache_parameter_group" "example" {
  name   = "YOUR-ELASTICACHE-NAME"
  family = "redis5.0"

  parameter {
    name  = "cluster-enabled"
    value = "no"
  }
}

resource "aws_elasticache_subnet_group" "example" {
  name = "YOUR-ELASTICACHE-SUBNET-GROUP-NAME"
  subnet_ids = [
    aws_subnet.private_0.id,
    aws_subnet.private_1.id,
  ]
}

module "redis_sg" {
  source = "./security_group"
  name   = "YOUR-REDIS-SG-NAME"
  vpc_id = aws_vpc.example.id
  port   = 6379
  cidr_blocks = [
    aws_vpc.example.cidr_block
  ]
}

resource "aws_elasticache_replication_group" "example" {
  replication_group_id       = "YOUR-REPLICATION-GROUP-NAME"
  description                = "Cluster Disabled"
  engine                     = "redis"
  engine_version             = "5.0.6"
  num_cache_clusters         = 3
  node_type                  = "cache.t4g.micro"
  snapshot_window            = "15:10-16:10"
  snapshot_retention_limit   = 7
  maintenance_window         = "sum:16:40-sun:17:40"
  automatic_failover_enabled = true
  port                       = 6379
  apply_immediately          = false
  security_group_ids = [
    module.redis_sg.security_group_id,
  ]
  parameter_group_name = aws_elasticache_parameter_group.example.name
  subnet_group_name    = aws_elasticache_subnet_group.example.name
}
