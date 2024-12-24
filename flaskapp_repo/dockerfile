FROM python:3.13

WORKDIR /app

COPY . /app

RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip

COPY requirements.txt /app/requirements.txt
RUN pip install -r requirements.txt

ENV FLASK_APP=crudapp.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_ENV=production

#ENV DB_USERNAME="flaskapp_user"
#ENV DB_PASSWORD="flaskapp_password"
#ENV DB_NAME="flaskapp_db"
#ENV DB_HOST="10.40.20.123:3306"

EXPOSE 80

COPY entrypoint.sh app/entrypoint.sh
RUN chmod +x app/entrypoint.sh

ENTRYPOINT ["app/entrypoint.sh"]

