FROM python:3.6

EXPOSE 5000

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app


RUN pip install -r requirements.txt

COPY app.py /app
CMD python app.py