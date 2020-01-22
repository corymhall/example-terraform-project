output env_account_id {
  value = {
    dev    = var.nonprod_account
    stg    = var.nonprod_account
    nonprd = var.nonprod_account
    prd    = var.prod_account
  }
}
