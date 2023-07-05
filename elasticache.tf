resource "aws_elasticache_subnet_group" "redis_subnet" {
  name       = "${format("%s-redis-subnet", var.project)}"
  subnet_ids = "${aws_subnet.prv_sub.*.id}"
  tags = {
    Name    = "${format("%s-redis-subnet", var.project)}"
    Tier    = "Private"
    Project = var.project
  }
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${format("%s-redis", var.project)}"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis5.0"
  engine_version       = "5.0.6"
  port                 = 6379

  subnet_group_name   = "${aws_elasticache_subnet_group.redis_subnet.name}"
  security_group_ids  = [aws_security_group.redis_sg.id]

  snapshot_retention_limit    = 5
  snapshot_window             = "00:00-05:00"

  tags = {
    Name    = "${format("%s-redis", var.project)}"
    Project = var.project
  }
}

# resource "aws_elasticache_replication_group" "redis_replication_group" {
#   # preferred_cache_cluster_azs = ["us-west-2a", "us-west-2b"]
#   replication_group_id        = "${format("%s-redis-repl-group", var.project)}"
#   description                 = "Redis Replaction Group for Hub-App"
#   node_type                   = "cache.t3.micro"
#   num_cache_clusters          = 2
#   parameter_group_name        = "default.redis3.2"
#   port                        = 6379

#   snapshot_retention_limit    = 5
#   snapshot_window             = "00:00-05:00"

#   subnet_group_name           = "${aws_elasticache_subnet_group.redis_subnet.name}"

#   tags = {
#     Name    = "${format("%s-redis-repl-group", var.project)}"
#     Project = var.project
#   }

#   lifecycle {
#     ignore_changes = [num_cache_clusters]
#   }
# }

# resource "aws_elasticache_cluster" "redis_replica" {
#   count = 1

#   cluster_id           = "${format("%s-redis-repl-group-node-%03d", var.project, count.index)}"
#   replication_group_id = aws_elasticache_replication_group.redis_replication_group.id

#   tags = {
#     Name    = "${format("%s-redis-replica", var.project)}"
#     Project = var.project
#   }
# }

