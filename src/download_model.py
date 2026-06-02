"""
Download a GGUF model from HuggingFace Hub on startup.

Environment variables:
    HF_MODEL_REPO:      HuggingFace repo ID (default: mradermacher/14B-Qwen2.5-Kunou-v1-GGUF)
    HF_MODEL_FILE:      GGUF filename pattern to match (default: 14B-Qwen2.5-Kunou-v1.Q8_0.gguf)
    HF_TOKEN:           (optional) HuggingFace access token for gated models
    MODEL_DOWNLOAD_DIR:  Local directory to store the downloaded model (default: /work/models)

Prints the local path to the downloaded GGUF file on stdout (last line),
so the calling shell script can capture it.
"""

import os
import sys
from huggingface_hub import hf_hub_download


def main():
    repo_id = os.environ.get("HF_MODEL_REPO", "mradermacher/14B-Qwen2.5-Kunou-v1-GGUF")
    filename = os.environ.get("HF_MODEL_FILE", "14B-Qwen2.5-Kunou-v1.Q8_0.gguf")
    token = os.environ.get("HF_TOKEN", None)
    download_dir = os.environ.get("MODEL_DOWNLOAD_DIR", "/work/models")

    print(f"download_model.py: Downloading {repo_id}/{filename} ...", file=sys.stderr)
    print(f"download_model.py: Target directory: {download_dir}", file=sys.stderr)

    try:
        local_path = hf_hub_download(
            repo_id=repo_id,
            filename=filename,
            local_dir=download_dir,
            token=token,
        )
    except Exception as e:
        print(f"download_model.py: ERROR: Failed to download model: {e}", file=sys.stderr)
        sys.exit(1)

    print(f"download_model.py: Download complete: {local_path}", file=sys.stderr)

    # Print the path on stdout so start.sh can capture it
    print(local_path)


if __name__ == "__main__":
    main()
