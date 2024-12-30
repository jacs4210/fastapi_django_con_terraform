FROM python:3.9-slim

WORKDIR /app

COPY fastapi/requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY fastapi /app

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]