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
  backup_window              = "15:10-15:40" #UTC�Ŏ��Ԃ�ݒ���s���B���L���Ă͓��{��0:10�`0:40�ƂȂ�
  backup_retention_period    = 30
  maintenance_window         = "sun:16:10-sun:16:40"
  auto_minor_version_upgrade = false
  deletion_protection        = false  #�ʏ�͌����RDS�C���X�^���X���폜���Ȃ��悤��true���w�肵�܂����A����͊w�K�̂��ߍ쐬/�폜���J��Ԃ�����false�ɂ��Ă��܂��B
  skip_final_snapshot        = true   #�ʏ��RDS�C���X�^���X�폜���ɃX�i�b�v�V���b�g���擾���폜��������\�ɂ��邽�߂�false���w�肷��ꍇ���������A�X�i�b�v�V���b�g���c���Ă���ƕR�Â�aws_db_option_group���폜�ł��Ȃ��Ȃ邽�߁A�����true�ɂ��Ă��܂��B
  #final_snapshot_identifier  = "final_snapshot" #skip_final_snapshot��false�ɂ����ꍇ��snapshot�̖��O���w�肵�܂��B����̓X�i�b�v�V���b�g���擾���Ȃ����߃R�����g�A�E�g���Ă��܂��B
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
