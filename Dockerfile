FROM nvidia/cuda:10.0-base-ubuntu16.04

# Install some basic utilities

RUN apt-get update && apt-get install -y \

    curl \

    ca-certificates \

    sudo \

    git \

    bzip2 \

    libx11-6 \

 && rm -rf /var/lib/apt/lists/*

# Create a working directory

RUN mkdir /app

WORKDIR /app

# Create a non-root user and switch to it

RUN adduser --disabled-password --gecos '' --shell /bin/bash user \

 && chown -R user:user /app

RUN echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-user

USER user

# All users can use /home/user as their home directory

ENV HOME=/home/user

RUN chmod 777 /home/user
# Install Miniconda

RUN curl -so ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh \

 && chmod +x ~/miniconda.sh \

 && ~/miniconda.sh -b -p ~/miniconda \

 && rm ~/miniconda.sh

ENV PATH=/home/user/miniconda/bin:$PATH

ENV CONDA_AUTO_UPDATE_CONDA=false

# Create a Python 3.6 environment

RUN /home/user/miniconda/bin/conda create -y --name py36 python=3.6.9 \

 && /home/user/miniconda/bin/conda clean -ya

ENV CONDA_DEFAULT_ENV=py36

ENV CONDA_PREFIX=/home/user/miniconda/envs/$CONDA_DEFAULT_ENV

ENV PATH=$CONDA_PREFIX/bin:$PATH

RUN /home/user/miniconda/bin/conda install conda-build=3.18.9=py36_3 \

 && /home/user/miniconda/bin/conda clean -ya

# CUDA 10.0-specific steps

RUN conda install -y -c pytorch \

    cudatoolkit=10.0 \

    "pytorch=1.2.0=py3.6_cuda10.0.130_cudnn7.6.2_0" \

    "torchvision=0.4.0=py36_cu100" \

 && conda clean -ya

# Install Torchnet, a high-level framework for PyTorch

RUN pip install torchnet==0.0.4
# Install Jupyter

RUN pip install jupyter

# Install Matplotlib

RUN pip install matplotlib

#Install Tensorflow

RUN pip install --upgrade tensorflow

# Excecute jupyter notebook
 
CMD ["sh", "-c", "jupyter notebook --no-browser --ip=0.0.0.0 --port=8888 --allow-root"]

