FROM ros:humble-ros-base

SHELL ["/bin/bash", "-c"]

WORKDIR /home

RUN git clone -b v0.8 https://github.com/stevenlovegrove/Pangolin

# Install dependencies
RUN apt-get update && apt-get install -y \
    python3-pip \
    ros-humble-cv-bridge \
    ros-humble-image-transport-plugins \
    libboost-all-dev \
    libgl1-mesa-dev \
    libwayland-dev \
    libxkbcommon-dev \
    wayland-protocols \
    libegl1-mesa-dev \
    libc++-dev \
    libglew-dev \
    libeigen3-dev \
    cmake \
    g++ \
    ninja-build \
    && pip install opencv-python \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/Pangolin

# Build and install Pangolin system-wide
RUN cmake -B build \
    && cmake --build build -j4 \
    && cmake --install build

COPY . /root/ros2_test/src

WORKDIR /root/ros2_test

# Build
RUN export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/local \
    && ldconfig \
    && echo -e 'if [[ ":$LD_LIBRARY_PATH:" != *":/usr/local/lib:"* ]]; then\n    export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH\nfi' >> /root/.bashrc \
    && source /root/.bashrc \
    && python3 -c "import cv2; print(cv2.__version__)" \
    && source /opt/ros/humble/setup.bash \
    && colcon build --symlink-install