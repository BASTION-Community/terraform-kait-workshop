# =============================================================================
# Backend 설정 — Terraform Cloud
# =============================================================================
# State 파일을 어디에 저장할 것인지 정의한다.
#
# cloud 블록을 사용하면:
#   - State가 Terraform Cloud에 저장됨 (로컬 PC에 남지 않음)
#   - plan/apply가 Terraform Cloud 서버에서 실행됨
#   - 팀원 간 State 공유 및 동시 작업 시 Lock 기능 제공
#
# 사용 전 organization을 본인의 Terraform Cloud 조직명으로 변경하세요.
# =============================================================================

terraform {
  cloud {
    organization = ""    # TODO: 본인의 organization으로 변경 - e.g. meiko_Org

    workspaces {
      name = ""     # TODO: Terraform Cloud에서 사용할 workspace 이름 - e.g. kait-terraform
    }
  }
}
