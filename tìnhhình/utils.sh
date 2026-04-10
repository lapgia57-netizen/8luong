diemvuong.sh
#!/bin/bash

# ================================================
# utils.sh - Script tiện ích tùy chỉnh cho Linux/MacOS
# Tác giả: Grok (dành cho Nguyễn Giang)
# ================================================

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Hàm log đẹp
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Kiểm tra quyền root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "Script này cần chạy với quyền root (sudo)"
        exit 1
    fi
}

# Cập nhật hệ thống (Ubuntu/Debian & Arch)
update_system() {
    log_info "Đang cập nhật hệ thống..."
    
    if command -v apt &> /dev/null; then
        apt update && apt upgrade -y
    elif command -v pacman &> /dev/null; then
        pacman -Syu --noconfirm
    elif command -v dnf &> /dev/null; then
        dnf update -y
    else
        log_error "Không hỗ trợ package manager của hệ thống này"
        return 1
    fi
    
    log_success "Hệ thống đã được cập nhật!"
}

# Tạo thư mục project nhanh
create_project() {
    if [ -z "$1" ]; then
        log_error "Vui lòng nhập tên project: ./utils.sh create_project ten_project"
        return 1
    fi
    
    local project_name=$1
    mkdir -p "$project_name"/{src,docs,tests,scripts}
    cd "$project_name" || return 1
    
    cat > README.md << EOF
# $project_name

Project được tạo bởi utils.sh

## Cấu trúc thư mục
- src/: Source code
- docs/: Tài liệu
- tests/: Test cases
- scripts/: Script tiện ích
EOF

    log_success "Đã tạo project '$project_name' thành công!"
}

# Hiển thị thông tin hệ thống đẹp
system_info() {
    echo -e "${BLUE}================ THÔNG TIN HỆ THỐNG ================${NC}"
    echo -e "Hostname     : $(hostname)"
    echo -e "OS           : $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo -e "Kernel       : $(uname -r)"
    echo -e "Uptime       : $(uptime -p)"
    echo -e "CPU          : $(nproc) cores"
    echo -e "Memory       : $(free -h | awk '/Mem:/ {print $2}')"
    echo -e "Disk Usage   : $(df -h / | awk 'NR==2 {print $5}')"
    echo -e "${BLUE}==================================================${NC}"
}

# Menu chính
show_menu() {
    clear
    echo -e "${GREEN}================ UTILS.SH - MENU ================${NC}"
    echo "1. Cập nhật hệ thống"
    echo "2. Tạo project mới"
    echo "3. Xem thông tin hệ thống"
    echo "4. Thoát"
    echo -e "${GREEN}================================================${NC}"
    
    read -p "Chọn chức năng (1-4): " choice
    
    case $choice in
        1) update_system ;;
        2) 
            read -p "Nhập tên project: " proj_name
            create_project "$proj_name"
            ;;
        3) system_info ;;
        4) 
            log_info "Tạm biệt! 👋"
            exit 0
            ;;
        *) log_error "Lựa chọn không hợp lệ!" ;;
    esac
}

# Main
main() {
    if [ "$1" = "menu" ] || [ -z "$1" ]; then
        while true; do
            show_menu
            echo ""
            read -p "Nhấn Enter để tiếp tục..."
        done
    else
        case "$1" in
            update) update_system ;;
            create) create_project "$2" ;;
            info) system_info ;;
            *) 
                log_error "Lệnh không hợp lệ. Sử dụng: ./utils.sh [menu|update|create <name>|info]"
                ;;
        esac
    fi
}

# Chạy main
main "$@"
