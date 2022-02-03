#                    #
# NEW KERNEL BUILDER #
#                    #


#
# Toolchain Path
#
ClangPath=$(pwd)/clang 
KernelPath=$(pwd)/kernel 


# clone
git clone --depth=1 https://github.com/Redmi-MT6768/android_kernel_xiaomi_mt6768 -b twelve $KernelPath
git clone --depth=1 https://github.com/kdrag0n/proton-clang $ClangPath

#
# Main
#
export TZ="Asia/Jakarta"
export KERNELNAME=JRE205-Kernel 
export TG_CHAT_ID=1689573524 
export TG_TOKEN=1689573524:AAHGMEDNkEpxSEc_c_rgwqaQ762n_dWJjJs
export KBUILD_BUILD_USER=@DreamersGo
export KBUILD_BUILD_HOST=ArmG80 
export DATE=$(date "+%m%d")
export HASH=$(git rev-parse --short HEAD)

IMAGE=$KernelPath/out/arch/arm64/boot/Image.gz
PATH=${ClangPath}/bin:${PATH}


#
# Telegram 
#
export BOT_MSG_URL="https://api.telegram.org/bot$TG_TOKEN/sendMessage"

tg_post_msg() {
  curl -s -X POST "$BOT_MSG_URL" -d chat_id="$TG_CHAT_ID" \
  -d "disable_web_page_preview=true" \
  -d "parse_mode=html" \
  -d text="$1"
}


#
# Compile Kernel
#
function compile() {
cd $KernelPath
tg_post_msg "Nama Kernel:$KERNELNAME""|""User:$KBUILD_BUILD_USER""|""Host:$KBUILD_BUILD_HOST""|""Tanggal:$DATE""|""<b>Sedang MengCompile...🤙</b>" \
make -j$(nproc) O=out ARCH=arm64 lancelot_defconfig
make -j$(nproc) ARCH=arm64 O=out \
    CC=${ClangPath}/bin/clang \
    CROSS_COMPILE=aarch64-linux-gnu- \
    CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
    CLANG_TRIPLE=aarch64-linux-gnu-

   if ! [ -a "$IMAGE" ]; then
	finerr
	exit 1
   fi
   
git clone --depth=1 https://github.com/CincauEXE/AnyKernel3 -b master AnyKernel
	cp $IMAGE AnyKernel
}



#
# Push Kernel to ch
#
function pushdoc() {
    cd AnyKernel
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/bot$TG_TOKEN/sendDocument" \
        -F chat_id="$TG_CHAT_ID" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="VoidKernel"
}


#
# Linux ver
#
function linux(){
   cd $KernelPath
   Linux=$(make kernelversion)
   cd -
}


#
# Find error
#
function finerr() {
    curl -s -X POST "https://api.telegram.org/bot$TG_TOKEN/sendMessage" \
        -d chat_id="$TG_CHAT_ID" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="error banh 🗿"
    exit 1
}


#
# Zipping kernel
#
function zipping() {
    cd AnyKernel || exit 1
    zip -r9 [$DATE][$Version]$KERNELNAME-$Linux-$HASH.zip *
    cd ..
}

#           #             #             #               #           #


compile
linux
zipping
pushdoc
