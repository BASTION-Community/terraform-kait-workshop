# =============================================================================
# Backend Configuration - Stg Environment
# =============================================================================
# 사용 전 organization을 본인의 Terraform Cloud 조직명으로 변경하세요
# =============================================================================

terraform {
  cloud {
    organization = ""    # TODO: 본인의 organization으로 변경 - e.g. meiko_Org

    workspaces {
      name = ""     # TODO: Terraform Cloud에서 사용할 workspace 이름 - e.g. kait-terraform-dev
    }
  }
}

# =============================================================================
# S3 Backend 사용 시 예를 들어 이런 블록을 사용합니다
# =============================================================================

# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "vpc/stg/terraform.tfstate"
#     region         = "ap-northeast-2"
#     encrypt        = true
#     dynamodb_table = "terraform-lock"
#   }
# }
