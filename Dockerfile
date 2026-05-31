FROM python:3.11-slim AS builder

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

FROM python:3.11-slim AS runtime
WORKDIR /app

COPY --from=builder /root/.local /root/.local
COPY src/ .

ENV PATH=/root/.local/bin:$PATH

EXPOSE 5000 8000

CMD ["python" , "src/app.py"]