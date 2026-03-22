# =============================================================================
# Backend Configuration - Step 2
# =============================================================================
# 사용 전 organization을 본인의 Terraform Cloud 조직명으로 변경하세요
# =============================================================================

terraform {
  cloud {
    organization = ""    # TODO: 본인의 organization으로 변경 - e.g. meiko_Org

    workspaces {
      name = ""     # TODO: Terraform Cloud에서 사용할 workspace 이름 - e.g. kait-terraform
    }
  }
}
