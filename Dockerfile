# Start from an official Python 3.9 slim image
FROM python:3.9-slim

# Set the working directory inside the container to /app
WORKDIR /app

# Copy the requirements file into the container at /app
COPY requirements.txt .

# Run the pip package manager to install the libraries from the requirements file
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application's code (app.py) into the container
COPY . .

# Tell Docker that the container listens on port 5000
EXPOSE 5000

# The command to run when the container starts
CMD ["python", "app.py"]