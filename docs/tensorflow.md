# Creating a docker with the correct versions of tensorflow

Tensorflow is very picky with [the versions of Cuda and Cudnn](https://www.tensorflow.org/install/source#gpu), probably the ones that your OS installs don't work and they don't give you any instructions on how to install a specific version from a tarball. Luckily [david does](https://davidfm43.github.io/jekyll/update/2024/04/17/cudnn.html) with that I've made the following Dockerfile to run:

- Tensorflow 1.29.0
- Cuda 12.5
- Cudnn 9.3.0

```Dockerfile
FROM nvidia/cuda:12.5.1-cudnn-devel-ubuntu22.04

# Install Python and dependencies
RUN apt-get update && apt-get install -y \
    python3 python3-pip wget \
    && apt-get remove -y --allow-change-held-packages cudnn libcudnn9-dev-cuda-12 libcudnn9-cuda-12 \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Install TensorFlow (latest GPU-compatible)
RUN pip install tensorflow keras pandas jupyter notebook matplotlib scikit-learn

# Install correct cudnn version
RUN wget https://developer.download.nvidia.com/compute/cudnn/redist/cudnn/linux-x86_64/cudnn-linux-x86_64-9.3.0.75_cuda12-archive.tar.xz \
   && tar -Jxvf  cudnn-linux-x86_64-9.3.0.75_cuda12-archive.tar.xz \
   && cp -P cudnn-linux-x86_64-9.3.0.75_cuda12-archive/lib/* /usr/local/cuda/lib64/ \
   && cp -P cudnn-linux-x86_64-9.3.0.75_cuda12-archive/include/* /usr/local/cuda/include/ \
   && chmod a+r /usr/local/cuda/include/cudnn*.h \
   && chmod a+r /usr/local/cuda/lib64/libcudnn* \
   && rm -rf /cudnn-linux-x86_64-9.3.0.75_cuda12-archive.tar.xz /cudnn-linux-x86_64-9.3.0.75_cuda12-archive

# Create working directory
WORKDIR /notebooks

# Expose Jupyter Notebook port
EXPOSE 8888

LABEL com.centurylinklabs.watchtower.enable=false
ENTRYPOINT []
CMD ["/usr/local/bin/jupyter", "notebook", "--ip=0.0.0.0", "--no-browser", "--allow-root"]
```

Which works with the next docker-compose

```yaml
---
services:
  jupyter:
    image: jupyter:latest
    container_name: jupyter-anomalia
    restart: unless-stopped
    ports:
      - "8888:8888"
    volumes:
      - notebooks:/notebooks
      - /etc/localtime:/etc/localtime:ro
    environment:
      - JUPYTER_ENABLE_LAB=yes
      - JUPYTER_TOKEN=your-super-secure-pass
    runtime: nvidia
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]

volumes:
  notebooks:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/your-user/notebooks
```

Once you do `docker compose up` you'll be able to access the notebook under `http://your-ip:8888?token=your-super-secure-pass`

# Troubleshooting

## tensorflow/compiler/mlir/tools/kernel_gen/tf_gpu_runtime_wrappers.cc:40] 'cuModuleLoadData(&module, data)' failed with 'CUDA_ERROR_ILLEGAL_ADDRESS

It's probably because you're trying to load stuff that does not fit your GPU

In my case I had to reduce units from 100 to 64

```python
def define_model(in_vocab_size, embedding_vec_length, max_text_length, out_timesteps, out_vocab_size):
    mt_model = Sequential()
    mt_model.add(Embedding(
        in_vocab_size,
        embedding_vec_length,
        mask_zero=True
        )
    )
    mt_model.add(GRU(units))
    mt_model.add(RepeatVector(out_timesteps))
    mt_model.add(GRU(units, return_sequences=True))
```
