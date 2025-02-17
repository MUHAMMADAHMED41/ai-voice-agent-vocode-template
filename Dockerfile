# Use Python 3.11 base image (compatible with <3.12)
FROM python:3.11-bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libportaudio2 libportaudiocpp0 portaudio19-dev libasound-dev libsndfile1-dev \
    ffmpeg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /code

# Copy project files
COPY . /code

# Install the latest version of Poetry
RUN pip install --no-cache-dir poetry>=1.5

# Configure Poetry
RUN poetry config virtualenvs.create false

# Regenerate poetry.lock if necessary
RUN poetry lock --no-update

# Install project dependencies (excluding dev dependencies)
RUN poetry install 

# Create necessary directories
RUN mkdir -p /code/call_transcripts /code/db

# Expose the application port
EXPOSE 3000

# Run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "3000"]
