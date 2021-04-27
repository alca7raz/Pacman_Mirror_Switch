#!/bin/bash

# Debug
# MIRRORLIST_FILE='./mirrorlist'
# MIRRORLIST_CN_FILE='./mirrorlist.cn'

MIRRORLIST_FILE='/etc/pacman.d/mirrorlist'
MIRRORLIST_CN_FILE='/etc/pacman.d/mirrorlist.cn'
MIRROR_CN_SUFFIX='/archlinuxcn/$arch'
MIRROR_SUFFIX='/archlinux/$repo/os/$arch'

SOURCE_NAME=(
    Tsinghua
    USTC
    BSFU
    Tencent
    aliyun
)

SOURCE_URL=(
    'https://mirrors.tuna.tsinghua.edu.cn'
    'https://mirrors.ustc.edu.cn'
    'https://mirrors.bfsu.edu.cn'
    'https://mirrors.cloud.tencent.com'
    'https://mirrors.aliyun.com'
)

CONFIRM_MSGS=(
    "（按下空格或回车键确认，按其他键取消）"
    "mirrorlist备份文件已存在，若继续可能会丢失原有备份，确认继续？"
    "mirrorlist.cn备份文件已存在，若继续可能会丢失原有备份，确认继续？"
    "mirrorlist尚未备份，是否备份源文件？"
    "mirrorlist.cn尚未备份，是否备份源文件？"
)

ERROR_MSGS=(
    "（按任意键继续）"
    "mirrorlist备份文件不存在。"
    "mirrorlist.cn备份文件不存在。"
    "输入错误。"
)

_confirm() {
    local _reg=
    echo -e "\e[36mWARN\e[0m: ${CONFIRM_MSGS[$1]}"
    read -p ${CONFIRM_MSGS[0]} -n 1 -r -s -a _reg
    echo
    case ${_reg} in
        ' '|'')
            true
            ;;
        *)
            false
            ;;
    esac
}

_error() {
    echo -e "\e[31mERR\e[0m: ${ERROR_MSGS[$1]}"
    if [ -n "$2" ]; then
        read -s -n 1 -p ${ERROR_MSGS[0]}
        echo
    fi
    false
}

HELPER::backupList() {
    if ls ${MIRRORLIST_FILE}.bak > /dev/null 2>&1; then
        _confirm 1
    else
        sudo cp ${MIRRORLIST_FILE} ${MIRRORLIST_FILE}.bak
    fi
    if ls ${MIRRORLIST_CN_FILE}.bak > /dev/null 2>&1; then
        _confirm 2
    else
        sudo cp ${MIRRORLIST_CN_FILE} ${MIRRORLIST_CN_FILE}.bak
    fi
}

HELPER::restoreList() {
    if ls ${MIRRORLIST_FILE}.bak > /dev/null 2>&1; then
        sudo cp ${MIRRORLIST_FILE}.bak ${MIRRORLIST_FILE}
    else
        _error 1
    fi
    if ls ${MIRRORLIST_CN_FILE}.bak > /dev/null 2>&1; then
        sudo cp ${MIRRORLIST_CN_FILE}.bak ${MIRRORLIST_CN_FILE}
    else
        _error 2
    fi
}

HELPER::overwriteList() {
    if ! ls ${MIRRORLIST_FILE}.bak > /dev/null 2>&1; then
        if _confirm 3 ; then
            sudo cp ${MIRRORLIST_FILE} ${MIRRORLIST_FILE}.bak
        else
            sudo touch ${MIRRORLIST_FILE}.bak
        fi
    fi
    echo "Server = ${SOURCE_URL[$1]}${MIRROR_SUFFIX}" | sudo tee ${MIRRORLIST_FILE} > /dev/null
    if ! ls ${MIRRORLIST_CN_FILE}.bak > /dev/null 2>&1; then
        if _confirm 4 ; then
            sudo cp ${MIRRORLIST_CN_FILE} ${MIRRORLIST_CN_FILE}.bak
        else
            sudo touch ${MIRRORLIST_CN_FILE}.bak
        fi
    fi
    echo "Server = ${SOURCE_URL[$1]}${MIRROR_CN_SUFFIX}" | sudo tee ${MIRRORLIST_CN_FILE} > /dev/null
    echo "Overwrite complete."
}

HELPER::selectSource() {
    local i;
    echo "选择需要使用的软件源："
    for i in $(seq ${#SOURCE_NAME[*]}); do
        i=$(expr ${i} - 1)
        printf "\e[34m%$(expr length ${#SOURCE_NAME[*]})d\e[0m. " ${i}
        echo ${SOURCE_NAME[$i]}
    done
    read -p "Select: " -a _ans
    if [[ ${_ans} =~ ^[0-9]+$ ]]; then
        if [[ ${_ans} -lt ${#SOURCE_NAME[*]} ]]; then
            return ${_ans}
        else
            _error 3
        fi
    else
        _error 3
    fi
    exit 1
}

MAIN() {
    case ${1} in
        'w')
            HELPER::selectSource
            HELPER::overwriteList ${?}
            ;;
        'b')
            HELPER::backupList
            ;;
        'r')
            HELPER::restoreList
            ;;
    esac
}

# main
case ${1} in
    'restore'|'r')
        opr=r
        ;;
    'backup'|'b')
        opr=b
        ;;
    *)
        opr=w
        ;;
esac
MAIN ${opr}
