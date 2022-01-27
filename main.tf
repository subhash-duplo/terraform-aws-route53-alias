data "aws_route53_zone" "default" {
  count        = module.this.enabled && length(compact(var.aliases)) > 0 ? 1 : 0
  zone_id      = var.parent_zone_id
  name         = var.parent_zone_name
  private_zone = var.private_zone
}

resource "aws_route53_record" "default" {
  #bridgecrew:skip=BC_AWS_NETWORKING_60:All of the aliases are configurable via var.aliases and it is the user's responsibility to ensure that all of the resources are in the same account.
  #bridgecrew:skip=BC_AWS_GENERAL_95:All of the aliases are configurable via var.aliases and it is the user's responsibility to ensure that all of the aliases point to resources and not just IPv4 addresses.
  count           = module.this.enabled ? length(compact(var.aliases)) : 0
  zone_id         = try(data.aws_route53_zone.default[0].zone_id, "")
  name            = compact(var.aliases)[count.index]
  allow_overwrite = var.allow_overwrite
  type            = "A"

  alias {
    name                   = var.target_dns_name
    zone_id                = var.target_zone_id
    evaluate_target_health = var.evaluate_target_health
  }
}

resource "aws_route53_record" "ipv6" {
  count           = module.this.enabled && var.ipv6_enabled ? length(compact(var.aliases)) : 0
  zone_id         = try(data.aws_route53_zone.default[0].zone_id, "")
  name            = compact(var.aliases)[count.index]
  allow_overwrite = var.allow_overwrite
  type            = "AAAA"

  alias {
    name                   = var.target_dns_name
    zone_id                = var.target_zone_id
    evaluate_target_health = var.evaluate_target_health
  }
}
