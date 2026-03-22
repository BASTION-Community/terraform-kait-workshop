# =============================================================================
# Main Configuration - Dev Environment
# =============================================================================

module "vpc" {
  source = "../../modules/vpc" # 공유 모듈 경로 (상대경로로 참조)

  environment        = var.environment        # 환경 이름 → 리소스 네이밍에 사용 (dev-vpc, dev-igw 등)
  vpc_cidr           = var.vpc_cidr            # VPC IP 대역 (10.10.0.0/16)
  public_subnet_cidr = var.public_subnet_cidr  # 퍼블릭 서브넷 IP 대역 (10.10.1.0/24)
  availability_zone  = var.availability_zone   # 가용영역 (ap-northeast-2a)

  tags = {}
}
