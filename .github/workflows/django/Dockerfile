FROM python:3.9-slim

WORKDIR /app

COPY django/requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY django /app

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]