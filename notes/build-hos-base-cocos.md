[TOC]

# 【拥抱鸿蒙】基于Cocos Creator的OpenHarmony自动构建

## 概述
自 Cocos Creator v2.4.12 起，支持发布到 OpenHarmony 平台。那么我们如何使用命令行来实现 OpenHarmony 自动构建并发布呢？
华为官方提供了一套命令行工具，包含hvigor、ohpm、hdc等，我们可以借助这些工具来编写脚本，来实现自动构建的流程。

这里我们使用`bash`脚本，运行于Jenkins构建平台。

构建机环境如下：
* Cocos Creator的版本： v2.4.13（目前官方2.x最新版本）；
* DevEco Studio版本： 5.0.3.404（Mac）；
* SDK版本：API 12（HarmonyOS NEXT Developer Beta1）

## 获取命令行工具
1. 前往[华为Developer网站下载中心](https://developer.huawei.com/consumer/cn/download/)获取最新命令行工具 Command Line Tools for HarmonyOS NEXT Developer Beta1(5.0.3.404)。
2. 解压后添加环境变量，分别将以下环境变量添加到`~/.bash_profile`(bash)或`~/.zshrc`(zsh)中:
```shell
export PATH=~/command-line-tools/bin:$PATH  
```

再使用source使环境变量生效：

```shell
source ~/.bash_profile
```
or
```shell
source ~/.zshrc
```
3. 配置hvigorw

hvigorw是hvigor的命令行工具，实现命令行交互。
其使用方式为：

```shell
hvigorw [taskNames...] <options>
```

这里，我的命令行工具版本如下：
* hdc: 3.0.0b
* ohpm: 5.0.2
* hvigor: 1.1.2

这里我们着重介绍hvigor，hvigor是基于任务管理机制实现的一款全新的自动化构建工具，主要提供任务注册编排，编译工程模型管理，编译配置定制,插件扩展等核心能力，当前主要面向OpenHarmonyOS应用JS/eTS开发场景。

hvigor结构化模型：hvigor工程主要以build-profile.json5与hvigorfile.js组成
```
rootProject                        // Hvigor工程根目录
├── build-profile.json5            // 工程级别Hvigor配置，主要配置工程相关信息，包括子模块名字、路径等。
├── hvigorfile.js                  // 工程级别任务脚本，当前暂不支持自定义
├── moduleA
│   ├── build-profile.json5  // 模块级别Hvigor配置，主要模块构建相关参数
│   └── hvigorfile.js        // 模块级别任务脚本，当前暂不支持自定义
└── moduleB
    ├── build-profile.json5       // 模块级别Hvigor配置，主要模块构建相关参数
    └── hvigorfile.js             // 模块级别任务脚本，当前暂不支持自定义
```

## 编写自动构建脚本

1. 配置环境

* 下载并配置Node.js
```shell
init_Node() {
  if [ ! -d "${NODE_HOME}" ]; then 
     mkdir "${NODE_HOME}"
  fi
  cd ${NODE_HOME}
  wget --no-check-certificate -q "${node下载路径}" -O node-linux.tar.xz #下载node，需要替换node下载路径
  tar -vxf node-linux.tar.xz
  NODE_DIR=xxx #node压缩包文件里面的目录
  cd ${NODE_DIR}
  mv -f ./* .[^.]* ../
  cd ..
  rm -rf NODE_DIR node-linux.tar.xz
  export NODE_HOME=${NODE_HOME}
  export PATH=$NODE_HOME/bin:$PATH
  node -v
  npm config set registry=https://repo.huaweicloud.com/repository/npm/
  npm config set @ohos:registry=https://repo.harmonyos.com/npm/
  
  npm config get @ohos:registry
  npm config set proxy=http://user:password@proxy.server.com:port #配置npm http代理，企业网络受限的情况下需要配置
  npm config set https-proxy=http://user:password@proxy.server.com:port #配置npm https代理，企业网络受限的情况下需要配置
  npm info express
}
```

* 下载并配置JDK

```shell
init_JDK() {
  if [ ! -d "${JAVA_HOME}" ]; then 
     mkdir "${JAVA_HOME}"
  fi

  cd ${JAVA_HOME}
  wget --no-check-certificate -q "${jdk下载路径}" -O jdk-linux.tar.xz #下载jdk，需要替换jdk下载路径
  tar -vxf jdk-linux.tar.xz
  JDK_DIR=xxx #jdk压缩包文件里面的目录
  cd ${JDK_DIR}
  mv -f ./* .[^.]* ../
  cd ..
  rm -rf JDK_DIR jdk-linux.tar.xz
  export JAVA_HOME=${JAVA_HOME}
  export PATH=$JAVA_HOME/bin:$PATH
  java -version

  check "JDK install"
}
```

* 配置OpenHarmony SDK

```shell
init_SDK() {
  ./${COMMANDLINE_TOOL_DIR}/bin/sdkmgr install HarmonyOS-NEXT/DB1 --sdk-directory="/opt/HarmonyOS/SDK/" --accept-license

  #设置hdc工具的环境变量，hdc工具在toolchains所在路径下，请以实际路径为准
  export PATH=$HDC_HOME:$PATH
  export HDC_HOME=/opt/HarmonyOS/SDK/HarmonyOS-NEXT-DB1/base/toolchains 
  export HOS_SDK_HOME=${HOS_SDK_HOME}

  check "SDK install"
}
```

* 安装ohpm

```shell
init_ohpm() {
    # 初始化ohpm
    OHPM_HOME=${COMMANDLINE_TOOL_DIR}/command-line-tools/ohpm
    export PATH=${OHPM_HOME}/bin:$PATH
    ohpm -v
    # 配置ohpm仓库地址
    ohpm config set registry=https://ohpm.openharmony.cn/ohpm/
}

```

2. 同步代码

```shell 
synccode() {
  PRO_PATH=$1; PRO_NAME=$2; REPO_URL=$3; BRAN_NAME=$4;
  if [ ! -d $PRO_PATH ]; then
    #新创建 Clone
    echo "mkdir $PRO_PATH && cd $PRO_PATH && git clone -b $BRAN_NAME $REPO_URL $PRO_NAME && cd $PRO_NAME"

    mkdir $PRO_PATH && \
    cd $PRO_PATH && \
    git clone -b $BRAN_NAME $REPO_URL $PRO_NAME && \
    cd $PRO_NAME
    
    check "Git clone"
  else
    local NEW_PATH=${PRO_PATH}${PRO_NAME}
    if [ ! -d ${NEW_PATH} ]; then
      #新分支 Clone
      echo "cd $PRO_PATH && git clone -b $BRAN_NAME $REPO_URL $PRO_NAME && cd $PRO_NAME"
      cd $PRO_PATH && git clone -b $BRAN_NAME $REPO_URL $PRO_NAME && cd $PRO_NAME
    else
      #原分支 Checkout & Pull
      echo "cd $PRO_PATH$PRO_NAME && git checkout . && git clean -df && git checkout -B $BRAN_NAME origin/$BRAN_NAME && git pull"

      cd $PRO_PATH$PRO_NAME && \
      git checkout . && \
      git clean -df && \
      git checkout -B $BRAN_NAME origin/$BRAN_NAME && \
      git pull

      if [[ ${VERSION_FLAG} != "X" ]]; then
        echo "checkout 指定版本：${VERSION_FLAG}"
        git checkout ${VERSION_FLAG}
      fi

      check "Git checkout & pull"
    fi
  fi
}
```

3. 从Cocos Creator导出OpenHarmony工程

```shell
cocosbuild() {
  local COCOS_APP_PATH="/Applications/CocosCreator/Creator/${COCOS_VERSION}/CocosCreator.app/Contents/MacOS/CocosCreator"
  
  echo "$COCOS_APP_PATH --project $1 --build configPath=./buildConfig/buildConfig_harmonryos.json"
  
  $COCOS_APP_PATH \
  --project $1 \
  --build configPath=./buildConfig/buildConfig_harmonryos.json

  check "Cocos build"
}
```

4. 运行Gulp

```
rungulp() {
    RES_VERSION=$1

    echo "/usr/local/bin/npm install"
    /usr/local/bin/npm install

    echo "/usr/local/bin/gulp --ver $RES_VERSION --platform harmonryos"
    /usr/local/bin/gulp --ver $RES_VERSION --platform harmonryos

    echo "rm -rf build/harmonryos/data/assets"
    rm -rf build/harmonryos/data/assets
    
    echo "cp -r remote-assets/hall/$RES_VERSION/assets build/harmonryos/data/"
    cp -r remote-assets/hall/$RES_VERSION/assets build/harmonryos/data/

    echo "cp -r remote-assets/hall/$RES_VERSION/src build/harmonryos/data/"
    cp -r remote-assets/hall/$RES_VERSION/src build/harmonryos/data/
    
    echo "/usr/local/bin/gulp copyCertificate --platform harmonryos"
    /usr/local/bin/gulp copyCertificate --platform harmonryos

    check "Run Gulp"
}

```

5. 构建出包

```
buildHAP() {
    # 根据业务情况适配local.properties
    cd ${PROJECT_PATH}
    echo "hwsdk.dir=${HOS_SDK_HOME}"  > ./local.properties
    # 根据业务情况安装ohpm三方库依赖
    ohpm_install "${PROJECT_PATH}"
    ohpm_install "${PROJECT_PATH}/entry"
    ohpm_install "${PROJECT_PATH}/xxx"

    # 如果构建过程报错 ERR_PNPM_OUTDATED_LOCKFILE，需要增加配置：lockfile=false, 根据node版本选择设置方式：
    # node.version<18
    npm config set lockfile=false # 如果执行此命令报错，建议直接在镜像的.npmrc文件中需要增加一行配置：lockfile=false
    # node.version>=18
    #cat ${HOME}/.npmrc | grep 'lockfile=false' || echo 'lockfile=false' >> ${HOME}/.npmrc
    # 根据业务情况，采用对应的构建命令，可以参考IDE构建日志中的命令
    cd ${PROJECT_PATH}
    chmod +x hvigorw
    ./hvigorw clean --no-daemon
    ./hvigorw assembleHap --mode module -p product=default -p debuggable=false --no-daemon # 流水线构建命令建议末尾加上--no-daemon

    check "Hap Build"
}

install_hap() {
    hdc file send "${PROJECT_PATH}/entry/build/default/outputs/default/entry-default-signed.hap" "data/local/tmp/entry-default-signed.hap"
    hdc shell bm install -p "data/local/tmp/entry-default-signed.hap" 
    hdc shell rm -rf "data/local/tmp/entry-default-signed.hap"
    hdc shell aa start -a MainAbility -b com.example.myapplication -m entry

    check "HAP install"
}

# 使用ohpm发布har
upload_har() {
  ohpm publish pkg.har
}
```

6. 移动文件到WorkSpace

```shell
movehap() {
  local TARGET_HAP_NAME=${AUTO_BUILD_NUMBER}_${JOB_NAME}_${BUILD_VERSION}_${RES_VERSION}_${NET_MODE}_by_${USER_NAME}
  local TARGET_HAP_PATH=$HOME/Desktop/Jenkins/Workspace/${JOB_NAME}/${TARGET_HAP_NAME}.hap
  local ORIGIN_HAP_PATH=${1}/Project/build/harmonryos/proj/build/Debug/${PROJ_NAME}.hap

  echo "cp ${ORIGIN_HAP_PATH} ${TARGET_HAP_PATH}"
  cp ${ORIGIN_HAP_PATH} ${TARGET_HAP_PATH}

  check "Move hap"
}
```


## 完整代码

```shell
#!/bin/bash
set -ex

PROJECT_NAME="" #项目名称
JOB_NAME="" #Jenkins Job名
NET_MODE="" #网络环境
BUILD_VERSION="" #版本号
RESOURCE_VERSION="" #热更版本
USER_NAME="" #用户名
MACHINE_NAME="" #机器名
SDK_NAME="" #SDK
REPOSITORY_URL="" #仓库URL
REPOSITORY_BRANCH="" #分支
AUTO_BUILD_NUMBER="" #构建编号
COCOS_VERSION="" #Cocos Creator版本

WORK_NAME=${GIT_BRANCH} #工作空间
PROJECT_PATH="$HOME/Desktop/Jenkins/Projects/${JOB_NAME}/" #项目路径

NODE_HOME="" #指定Node.js的安装目录
JAVA_HOME="" #指定JDK的安装目录
COMMANDLINE_TOOL_DIR="" #命令行工具的安装目录
HOS_SDK_HOME="" #HarmonyOS SDK根路径

step() {
  LOG_LIST=(
    "🎈欢迎使用自动构建系统🎈"
    "⏳1. 安装构建环境"
    "⏳2. 同步远程仓库代码"
    "⏳3. 执行Cocos Creator build"
    "⏳4. 运行gulp脚本"
    "⏳5. 执行build hap"
    "⏳6. 移动App文件到Workspace"
    "🛫构建完成,请在WorkSpace查看HAP文件🛬"
  )
  echo "===================================="
  echo ${LOG_LIST[${1}]}
  echo "===================================="
}

# 运行结果检查
check() {
  local RETUEN_CODE=$?
  if [[ RETUEN_CODE -ne 0 ]] && [[ RETUEN_CODE -ne 36 ]]; then
    echo "📛$1 failed, error code:${RETUEN_CODE}"; echo "构建失败，请联系管理员"; exit 1
  else
    echo "🚀$1 succeed, return code:${RETUEN_CODE}"
  fi
}

#下载并配置Node.js
init_Node() {
  if [ ! -d "${NODE_HOME}" ]; then 
     mkdir "${NODE_HOME}"
  fi
  cd ${NODE_HOME}
  wget --no-check-certificate -q "${node下载路径}" -O node-linux.tar.xz #下载node，需要替换node下载路径
  tar -vxf node-linux.tar.xz
  NODE_DIR=xxx #node压缩包文件里面的目录
  cd ${NODE_DIR}
  mv -f ./* .[^.]* ../
  cd ..
  rm -rf NODE_DIR node-linux.tar.xz
  export NODE_HOME=${NODE_HOME}
  export PATH=$NODE_HOME/bin:$PATH
  node -v
  npm config set registry=https://repo.huaweicloud.com/repository/npm/
  npm config set @ohos:registry=https://repo.harmonyos.com/npm/
  
  npm config get @ohos:registry
  npm config set proxy=http://user:password@proxy.server.com:port #配置npm http代理，企业网络受限的情况下需要配置
  npm config set https-proxy=http://user:password@proxy.server.com:port #配置npm https代理，企业网络受限的情况下需要配置
  npm info express
}

#下载并配置JDK
init_JDK() {
  if [ ! -d "${JAVA_HOME}" ]; then 
     mkdir "${JAVA_HOME}"
  fi

  cd ${JAVA_HOME}
  wget --no-check-certificate -q "${jdk下载路径}" -O jdk-linux.tar.xz #下载jdk，需要替换jdk下载路径
  tar -vxf jdk-linux.tar.xz
  JDK_DIR=xxx #jdk压缩包文件里面的目录
  cd ${JDK_DIR}
  mv -f ./* .[^.]* ../
  cd ..
  rm -rf JDK_DIR jdk-linux.tar.xz
  export JAVA_HOME=${JAVA_HOME}
  export PATH=$JAVA_HOME/bin:$PATH
  java -version

  check "JDK install"
}

#配置OpenHarmony SDK
init_SDK() {
  ./${COMMANDLINE_TOOL_DIR}/bin/sdkmgr install HarmonyOS-NEXT/DB1 --sdk-directory="/opt/HarmonyOS/SDK/" --accept-license

  #设置hdc工具的环境变量，hdc工具在toolchains所在路径下，请以实际路径为准
  export PATH=$HDC_HOME:$PATH
  export HDC_HOME=/opt/HarmonyOS/SDK/HarmonyOS-NEXT-DB1/base/toolchains 
  export HOS_SDK_HOME=${HOS_SDK_HOME}

  check "SDK install"
}

# 安装ohpm, 若镜像中已存在ohpm，则无需重新安装
init_ohpm() {
    # 初始化ohpm
    OHPM_HOME=${COMMANDLINE_TOOL_DIR}/command-line-tools/ohpm
    export PATH=${OHPM_HOME}/bin:$PATH
    ohpm -v
    # 配置ohpm仓库地址
    ohpm config set registry=https://ohpm.openharmony.cn/ohpm/
}

# Git同步远程仓库代码
synccode() {
  PRO_PATH=$1; PRO_NAME=$2; REPO_URL=$3; BRAN_NAME=$4;
  if [ ! -d $PRO_PATH ]; then
    #新创建 Clone
    echo "mkdir $PRO_PATH && cd $PRO_PATH && git clone -b $BRAN_NAME $REPO_URL $PRO_NAME && cd $PRO_NAME"

    mkdir $PRO_PATH && \
    cd $PRO_PATH && \
    git clone -b $BRAN_NAME $REPO_URL $PRO_NAME && \
    cd $PRO_NAME
    
    check "Git clone"
  else
    local NEW_PATH=${PRO_PATH}${PRO_NAME}
    if [ ! -d ${NEW_PATH} ]; then
      #新分支 Clone
      echo "cd $PRO_PATH && git clone -b $BRAN_NAME $REPO_URL $PRO_NAME && cd $PRO_NAME"
      cd $PRO_PATH && git clone -b $BRAN_NAME $REPO_URL $PRO_NAME && cd $PRO_NAME
    else
      #原分支 Checkout & Pull
      echo "cd $PRO_PATH$PRO_NAME && git checkout . && git clean -df && git checkout -B $BRAN_NAME origin/$BRAN_NAME && git pull"

      cd $PRO_PATH$PRO_NAME && \
      git checkout . && \
      git clean -df && \
      git checkout -B $BRAN_NAME origin/$BRAN_NAME && \
      git pull

      if [[ ${VERSION_FLAG} != "X" ]]; then
        echo "checkout 指定版本：${VERSION_FLAG}"
        git checkout ${VERSION_FLAG}
      fi

      check "Git checkout & pull"
    fi
  fi
}

# Cocos Build
cocosbuild() {
  local COCOS_APP_PATH="/Applications/CocosCreator/Creator/${COCOS_VERSION}/CocosCreator.app/Contents/MacOS/CocosCreator"
  
  echo "$COCOS_APP_PATH --project $1 --build configPath=./buildConfig/buildConfig_harmonryos.json"
  
  $COCOS_APP_PATH \
  --project $1 \
  --build configPath=./buildConfig/buildConfig_harmonryos.json

  check "Cocos build"
}

# Run Gulp
rungulp() {
    RES_VERSION=$1

    echo "/usr/local/bin/npm install"
    /usr/local/bin/npm install

    echo "/usr/local/bin/gulp --ver $RES_VERSION --platform harmonryos"
    /usr/local/bin/gulp --ver $RES_VERSION --platform harmonryos

    echo "rm -rf build/harmonryos/data/assets"
    rm -rf build/harmonryos/data/assets
    
    echo "cp -r remote-assets/hall/$RES_VERSION/assets build/harmonryos/data/"
    cp -r remote-assets/hall/$RES_VERSION/assets build/harmonryos/data/

    echo "cp -r remote-assets/hall/$RES_VERSION/src build/harmonryos/data/"
    cp -r remote-assets/hall/$RES_VERSION/src build/harmonryos/data/
    
    echo "/usr/local/bin/gulp copyCertificate --platform harmonryos"
    /usr/local/bin/gulp copyCertificate --platform harmonryos

    check "Run Gulp"
}

# 移动hap文件
movehap() {
  local TARGET_HAP_NAME=${AUTO_BUILD_NUMBER}_${JOB_NAME}_${BUILD_VERSION}_${RES_VERSION}_${NET_MODE}_by_${USER_NAME}
  local TARGET_HAP_PATH=$HOME/Desktop/Jenkins/Workspace/${JOB_NAME}/${TARGET_HAP_NAME}.hap
  local ORIGIN_HAP_PATH=${1}/Project/build/harmonryos/proj/build/Debug/${PROJ_NAME}.hap

  echo "cp ${ORIGIN_HAP_PATH} ${TARGET_HAP_PATH}"
  cp ${ORIGIN_HAP_PATH} ${TARGET_HAP_PATH}

  check "Move hap"
}

# 进入package目录安装依赖
ohpm_install() {
    cd $1
    ohpm install

    check "ohpm install"
}

# 环境适配
buildHAP() {
    # 根据业务情况适配local.properties
    cd ${PROJECT_PATH}
    echo "hwsdk.dir=${HOS_SDK_HOME}"  > ./local.properties
    # 根据业务情况安装ohpm三方库依赖
    ohpm_install "${PROJECT_PATH}"
    ohpm_install "${PROJECT_PATH}/entry"
    ohpm_install "${PROJECT_PATH}/xxx"

    # 如果构建过程报错 ERR_PNPM_OUTDATED_LOCKFILE，需要增加配置：lockfile=false, 根据node版本选择设置方式：
    # node.version<18
    npm config set lockfile=false # 如果执行此命令报错，建议直接在镜像的.npmrc文件中需要增加一行配置：lockfile=false
    # node.version>=18
    #cat ${HOME}/.npmrc | grep 'lockfile=false' || echo 'lockfile=false' >> ${HOME}/.npmrc
    # 根据业务情况，采用对应的构建命令，可以参考IDE构建日志中的命令
    cd ${PROJECT_PATH}
    chmod +x hvigorw
    ./hvigorw clean --no-daemon
    ./hvigorw assembleHap --mode module -p product=default -p debuggable=false --no-daemon # 流水线构建命令建议末尾加上--no-daemon

    check "Hap Build"
}

install_hap() {
    hdc file send "${PROJECT_PATH}/entry/build/default/outputs/default/entry-default-signed.hap" "data/local/tmp/entry-default-signed.hap"
    hdc shell bm install -p "data/local/tmp/entry-default-signed.hap" 
    hdc shell rm -rf "data/local/tmp/entry-default-signed.hap"
    hdc shell aa start -a MainAbility -b com.example.myapplication -m entry

    check "HAP install"
}

# 使用ohpm发布har
upload_har() {
  ohpm publish pkg.har
}

init_env() {
    init_Node #安装Node.JS
    init_JDK #安装Java Development Kit
    init_SDK #安装OpenHarmony SDK
    init_ohpm #安装ohpm
}

main() {
    step 0; echo "构建脚本及参数："
    for i in "$*"; do
        echo -e "${i}\n";
    done
    
    step 1; init_env
    step 2; synccode $PROJECT_PATH $PROJECT_NAME $REPOSITORY_URL $REPOSITORY_BRANCH
    step 3; cocosbuild ./
    step 4; rungulp ${RESOURCE_VERSION}
    step 5; buildHAP; install_hap; upload_har
    step 6; movehapw
    step 7; exit 0
}

main $0 $*
```

以上，就是整个自动构建的流程。










