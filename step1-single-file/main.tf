# =============================================================================
# Step 1: 단일 파일로 VPC 구성
# =============================================================================
# 학습 목표: Terraform 기본 문법과 리소스 정의 방법을 익힌다.
#
# 이 파일에서 배우는 것:
#   1. provider  — 어떤 클라우드에 연결할 것인가
#   2. resource  — 어떤 인프라를 만들 것인가
#   3. output    — 생성 결과를 어떻게 확인할 것인가
#   4. 리소스 참조 — 리소스끼리 어떻게 연결하는가 (aws_vpc.main.id)
#
# 실습:
#   terraform init    — 프로바이더 다운로드 및 초기화
#   terraform plan    — 생성될 리소스 미리보기 (실제 생성 안 함)
#   terraform apply   — 실제 AWS에 리소스 생성
#   terraform destroy — 생성한 리소스 삭제
#
# 이 단계의 한계:
#   - 모든 값이 하드코딩되어 있어 환경(dev, stg)을 바꾸려면 파일을 복사해야 함
#   - CIDR, 이름 등을 일일이 수동 수정해야 하므로 실수 가능성이 높음
#   → 이 문제를 2교시에서 Variable과 Module로 해결한다.
# =============================================================================


# -----------------------------------------------------------------------------
# Provider 블록
# -----------------------------------------------------------------------------
# Terraform에게 "AWS를 사용할 것이며, 서울 리전에 리소스를 만들겠다"고 선언한다.
# provider 블록이 없으면 Terraform은 어떤 클라우드에 연결할지 알 수 없다.
provider "aws" {
  region = "ap-northeast-2"    # ap-northeast-2 = 서울 리전
}


# -----------------------------------------------------------------------------
# VPC (Virtual Private Cloud)
# -----------------------------------------------------------------------------
# AWS에서 논리적으로 격리된 네트워크를 생성한다.
# 모든 서브넷, 게이트웨이, 라우트 테이블은 이 VPC 안에 존재한다.
#
# resource "리소스타입" "이름" 형식:
#   - "aws_vpc"  → AWS VPC를 만들겠다 (리소스 타입)
#   - "main"     → 이 코드 안에서 이 VPC를 부르는 별칭 (AWS에는 보이지 않음)
resource "aws_vpc" "main" {
  cidr_block           = "10.10.0.0/16"    # VPC의 IP 대역: 10.10.0.0 ~ 10.10.255.255 (65,536개)
  enable_dns_hostnames = true              # VPC 내 리소스에 DNS 호스트명 부여
  enable_dns_support   = true              # VPC 내 DNS 확인 활성화

  tags = {
    Name = "my-vpc"    # AWS 콘솔에서 보이는 이름
  }
}


# -----------------------------------------------------------------------------
# Public Subnet
# -----------------------------------------------------------------------------
# VPC 안에 서브넷(하위 네트워크)을 생성한다.
# Public Subnet = 인터넷과 직접 통신 가능한 서브넷
#
# ★ 리소스 참조: vpc_id = aws_vpc.main.id
#   - "aws_vpc" → 리소스 타입
#   - "main"    → 위에서 정의한 리소스 이름
#   - "id"      → AWS가 VPC 생성 후 부여한 고유 ID (vpc-0abc1234...)
#   → Terraform이 이 참조를 보고 "VPC를 먼저 만들어야 한다"는 순서를 자동으로 파악한다.
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id       # ← 이 서브넷이 속할 VPC를 참조
  cidr_block              = "10.10.1.0/24"          # 서브넷 IP 대역: 10.10.1.0 ~ 10.10.1.255 (256개)
  availability_zone       = "ap-northeast-2a"      # 가용영역: 서울 리전의 AZ-a
  map_public_ip_on_launch = true                   # 이 서브넷에 생성되는 인스턴스에 퍼블릭 IP 자동 할당

  tags = {
    Name = "public-subnet"
  }
}


# -----------------------------------------------------------------------------
# Internet Gateway
# -----------------------------------------------------------------------------
# VPC와 인터넷을 연결하는 관문.
# Internet Gateway가 없으면 VPC 내부에서 인터넷으로 나갈 수 없다.
#
# ★ 리소스 참조: vpc_id = aws_vpc.main.id
#   → 이 IGW를 위에서 만든 VPC에 연결한다.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id    # ← VPC에 연결

  tags = {
    Name = "main-igw"
  }
}


# -----------------------------------------------------------------------------
# Route Table (Public)
# -----------------------------------------------------------------------------
# 네트워크 트래픽의 경로를 정의하는 라우팅 테이블.
#
# route 블록:
#   cidr_block = "0.0.0.0/0" → 모든 목적지 (= 인터넷으로 향하는 모든 트래픽)
#   gateway_id = aws_internet_gateway.main.id → Internet Gateway로 보내라
#
# ★ 두 개의 리소스 참조가 사용됨:
#   1. vpc_id    = aws_vpc.main.id              → 이 라우트 테이블이 속할 VPC
#   2. gateway_id = aws_internet_gateway.main.id → 트래픽을 보낼 게이트웨이
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"                      # 목적지: 모든 IP (인터넷)
    gateway_id = aws_internet_gateway.main.id      # ← IGW로 트래픽 전달
  }

  tags = {
    Name = "public-rt"
  }
}


# -----------------------------------------------------------------------------
# Route Table Association
# -----------------------------------------------------------------------------
# 서브넷과 라우트 테이블을 연결한다.
# 이 연결이 없으면 서브넷은 기본(main) 라우트 테이블을 사용하게 되며,
# 위에서 만든 퍼블릭 라우트(0.0.0.0/0 → IGW)가 적용되지 않는다.
#
# ★ 두 개의 리소스 참조:
#   1. subnet_id      = aws_subnet.public.id      → 연결할 서브넷
#   2. route_table_id = aws_route_table.public.id  → 연결할 라우트 테이블
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id            # ← 퍼블릭 서브넷
  route_table_id = aws_route_table.public.id       # ← 퍼블릭 라우트 테이블
}


# -----------------------------------------------------------------------------
# Output 블록
# -----------------------------------------------------------------------------
# terraform apply 완료 후, 생성된 리소스의 주요 값을 터미널에 출력한다.
# 형식: output "출력이름" { value = 리소스참조 }
#
# 용도:
#   1. apply 결과를 바로 확인 (터미널에 표시)
#   2. 다른 모듈에서 이 값을 가져다 쓸 수 있음 (2교시에서 다룸)

output "vpc_id" {
  description = "생성된 VPC의 ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "생성된 Public Subnet의 ID"
  value       = aws_subnet.public.id
}

output "internet_gateway_id" {
  description = "생성된 Internet Gateway의 ID"
  value       = aws_internet_gateway.main.id
}
