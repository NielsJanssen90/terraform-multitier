#!/bin/sh

# Run migrations
flask db init
flask db migrate -m "entries table"
flask db upgrade

# Start the application
gunicorn -w 4 -b 0.0.0.0:80 crudapp:app
