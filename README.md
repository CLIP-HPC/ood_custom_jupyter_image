# ood_custom_jupyter_image

An [Open OnDemand](https://openondemand.org/) Batch Connect app for CBE.next
that starts **JupyterLab from your own Apptainer image**. JupyterLab, its
extensions (themes, jupyter-ai, ...) and the default Python kernel all come
from the image, so a lab can ship one reproducible environment.

## Use it as a sandbox app

App development is enabled for every CBE.next account:

```bash
mkdir -p ~/ondemand/dev && cd ~/ondemand/dev
git clone https://github.com/CLIP-HPC/ood_custom_jupyter_image.git custom-jupyter-image
```

Reload the OnDemand portal and open **Develop** (the `</>` icon) >
**My Sandbox Apps (Development)** > **Jupyter (custom image)**. Choose your
`.sif` file under *Container image*, pick partition and resources, and launch.

## Image requirements

- **JupyterLab 4.x** with **jupyter_server 2.x**, with `jupyter` on the image's
  `PATH` (`apptainer exec image.sif jupyter lab --version` must work).
- Anything else you need (packages, extensions, kernels) installed in the image.
  JupyterHub and batchspawner are **not** needed.

Images built with [repo2docker](https://repo2docker.readthedocs.io/) work as they are.
A minimal Apptainer definition file:

```
Bootstrap: docker
From: python:3.12-slim
%post
    pip install --no-cache-dir "jupyterlab>=4,<5" ipykernel
```

```bash
apptainer build my-lab.sif my-lab.def
```

## What the app does

- runs `jupyter lab` in the image with `apptainer exec --cleanenv`, so host
  modules and environment variables don't interfere with the image's Python
- mounts home, `/groups`, `/scratch`, `/resources` and `/clustertmp`
- adds `--nv` on GPU sessions (partition `g`), so CUDA and the NVIDIA driver work
- passes `OMP_NUM_THREADS` (= requested cores) and the Slurm job variables
- sets `PYTHONNOUSERSITE=1`, so packages in `~/.local` don't leak into the image
- stops the session quickly with a clear message if the image is missing or
  has no JupyterLab (see `output.log` in the session directory)

Sessions use the interactive QOS: at most 12 hours, 48 cores and 1000 GB per
user across all OnDemand and `salloc` sessions; partition `m` needs at least 200 GB.

## Files

| File | Purpose |
|---|---|
| `manifest.yml` | App name and description |
| `form.yml` | Form fields |
| `submit.yml.erb` | Slurm options, limit checks |
| `template/before.sh.erb` | Port, password and `jupyter_server` config |
| `template/script.sh.erb` | Starts JupyterLab in the image |
| `template/after.sh` | Waits for the server, fails fast if it exits |
| `view.html.erb` | *Connect* button |

Documentation: <https://docs.vbc.ac.at/research-computing/cbe/openondemand-web-applications/>
