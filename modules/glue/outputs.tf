output "crawler_names" {
  value = {
    for k, v in aws_glue_crawler.crawler :
    k => v.name
  }
}
