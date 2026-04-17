# ==============================================================================
# Custom build of llama.cpp with CUDA 12.0 support
# ==============================================================================
FROM nvidia/cuda:12.0.0-devel-ubuntu22.04

ENV PYTHONUNBUFFERED=1

# Install build dependencies and Python 3.11
RUN apt-get update --yes --quiet && DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet --no-install-recommends \
    software-properties-common \
    gpg-agent \
    build-essential \
    apt-utils \
    git \
    cmake \
    libcurl4-openssl-dev \
    && apt-get install --reinstall ca-certificates \
    && add-apt-repository --yes ppa:deadsnakes/ppa && apt update --yes --quiet \
    && DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet --no-install-recommends \
    python3.11 \
    python3.11-dev \
    python3.11-distutils \
    python3.11-lib2to3 \
    python3.11-gdbm \
    python3.11-tk \
    bash \
    curl && \
    ln -s /usr/bin/python3.11 /usr/bin/python && \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV LIBRARY_PATH=/usr/local/cuda/lib64/stubs:${LIBRARY_PATH}
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64/stubs:${LD_LIBRARY_PATH}
RUN ln -sf /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1

# Clone and build llama.cpp with CUDA 12.0 support
# Architectures: Pascal(60), Volta(70), Turing(75), Ampere(80,86), Ada Lovelace(89), Hopper(90)
RUN git clone --depth 1 https://github.com/ggml-org/llama.cpp.git /tmp/llama.cpp && \
    cd /tmp/llama.cpp && \
    cmake -B build \
        -DGGML_CUDA=ON \
        -DCMAKE_CUDA_ARCHITECTURES="60;70;75;80;86;89;90" \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLAMA_CURL=ON && \
    cmake --build build --config Release -j$(nproc) --target llama-server && \
    mkdir -p /app && \
    cp build/bin/llama-server /app/llama-server && \
    find build -name '*.so*' -exec cp {} /app/ \; && \
    echo "/app" > /etc/ld.so.conf.d/llama.conf && \
    ldconfig && \
    rm -rf /tmp/llama.cpp

# Set the working directory
WORKDIR /work

# Add ./src as /work
ADD ./src /work

# Install runpod and its dependencies
RUN pip install -r ./requirements.txt && chmod +x /work/start.sh

# Set the entrypoint
ENTRYPOINT ["/bin/sh", "-c", "/work/start.sh"]
