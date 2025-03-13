#!/bin/bash

echo "Automatically configuring the EasIFA environment..."
source ~/.bashrc
# 设置环境变量
export CONDA_HOME=$(conda info --base)
export EASIFA_ROOT=$(pwd)

# 安装 gdown 工具
pip install gdown

# 创建需要的目录
mkdir -vp ~/.cache/torch/hub/checkpoints
mkdir -vp $CONDA_HOME/envs
mkdir -vp $EASIFA_ROOT/dataset/raw_dataset/chebi

# 检查并下载文件：ESM 模型
if [ ! -f ~/.cache/torch/hub/checkpoints/esm2_t33_650M_UR50D.pt ]; then
    echo "Downloading ESM model..."
    wget https://dl.fbaipublicfiles.com/fair-esm/models/esm2_t33_650M_UR50D.pt -O ~/.cache/torch/hub/checkpoints/esm2_t33_650M_UR50D.pt
else
    echo "ESM model already exists, skipping download."
fi

# 检查并下载 easifa_env.tar.gz
# 判断是否有虚拟环境
if [ ! -d $CONDA_HOME/envs/easifa_env ]; then
    # 没有虚拟环境 判断是否有环境的压缩包
    if [ ! -f /workspace/Downloads/easifa_env.tar.gz ]; then
        # 没有压缩包 则下载
        echo "Downloading easifa_env.tar.gz..."
        gdown https://drive.google.com/uc?id=1kLIx2h6kPk6OvRVPWWqJvoKAYVvBx80x -O /workspace/Downloads/easifa_env.tar.gz
        # 判断是否下载成功
        if [ $? -eq 0 ]; then
            echo "Download succeeded."
        else
            ossutil cp oss://easifa/py38.tar.gz /workspace/Downloads/easifa_env.tar.gz
            echo "Download succeeded."
        fi
    else
        # 有压缩包
        echo "easifa_env.tar.gz already exists, skipping download."
    fi
    # 下载后解压并配置
    echo "Extracting easifa_env.tar.gz..."
    mkdir $CONDA_HOME/envs/easifa_env
    tar -xvf /workspace/Downloads/easifa_env.tar.gz -C $CONDA_HOME/envs/easifa_env
    # 激活 conda 环境
    source activate $CONDA_HOME/envs/easifa_env
    conda unpack
    # 安装 Python 包
    pip uninstall fair-esm -y
    pip install git+https://github.com/facebookresearch/esm.git
    pip install mysql-connector-python==8.2.0 mysqlclient==2.2.1 rxnfp flask_wtf gdown 

else
    echo "easifa_env already exists, skipping unpack."
fi


# 检查并下载 checkpoints.zip
# 判断是否有checkpoints
if [ ! -d $EASIFA_ROOT/checkpoints ]; then
    # 判断是否有压缩包
    if [ ! -f /workspace/Downloads/checkpoints.zip ]; then
        # 没有压缩包 则下载
        echo "Downloading checkpoints.zip..."
        gdown https://drive.google.com/uc?id=1ra11M4PpIalKx9ZZP-mrgj13IuFakjz3 -O /workspace/Downloads/checkpoints.zip
        # 判断是否下载成功
        if [ $? -eq 0 ]; then
            echo "Download succeeded."
        else
            ossutil cp -r oss://easifa/checkpoints.zip /workspace/Downloads/
            echo "Download succeeded."
        fi
    else
        # 有压缩包
        echo "checkpoints.zip already exists, skipping download."
    fi
    # 解压 checkpoints.zip 文件
    echo "Unzipping checkpoints..."
    unzip /workspace/Downloads/checkpoints.zip -d ~/
    ln -s ~/checkpoints $EASIFA_ROOT/checkpoints 
fi

# 检查并下载 structures.csv.gz
if [ ! -f $EASIFA_ROOT/dataset/raw_dataset/chebi/structures.csv.gz ]; then
    echo "Downloading structures.csv.gz..."
    wget https://ftp.ebi.ac.uk/pub/databases/chebi/Flat_file_tab_delimited/structures.csv.gz -O $EASIFA_ROOT/dataset/raw_dataset/chebi/structures.csv.gz

else
    echo "structures.csv.gz already exists, skipping download."
fi

echo "EasIFA setup done!"

# 开启网页服务
# cd /workspace/EasIFA/webapp && ~/miniconda3/envs/easifa_env/bin/python app.py
