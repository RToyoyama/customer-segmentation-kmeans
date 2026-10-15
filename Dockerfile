# Imagem oficial do uv com Python 3.13
FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    PYTHONUNBUFFERED=1 \
    PATH="/app/.venv/bin:$PATH"

# Usuário sem privilégios de root
RUN useradd --create-home --uid 1000 analista
WORKDIR /app

# Instala as dependências primeiro (aproveita cache de camadas do Docker)
COPY pyproject.toml uv.lock .python-version ./
RUN uv sync --frozen --no-install-project

# Copia o projeto
COPY --chown=analista:analista . .
RUN chown -R analista:analista /app

USER analista
EXPOSE 8888

# Sobe o JupyterLab já com o notebook do projeto
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", \
     "--ServerApp.token=", "--ServerApp.password=", \
     "--ServerApp.root_dir=/app", \
     "--LabApp.default_url=/lab/tree/notebooks/segmentacao_clientes_kmeans.ipynb"]
