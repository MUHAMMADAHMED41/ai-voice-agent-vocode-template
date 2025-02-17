# Use Python 3.9 base image
FROM python:3.9-bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libportaudio2 libportaudiocpp0 portaudio19-dev libasound-dev libsndfile1-dev \
    ffmpeg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /code

# Copy project files
COPY ./pyproject.toml /code/pyproject.toml
COPY ./poetry.lock /code/poetry.lock

# Install Poetry and configure it
RUN pip install --no-cache-dir --upgrade poetry
RUN poetry config virtualenvs.create false

# Install project dependencies (excluding dev dependencies)
RUN poetry install --no-interaction --no-ansi

# Copy application code
COPY main.py /code/main.py
COPY speller_agent.py /code/speller_agent.py
COPY memory_config.py /code/memory_config.py
COPY events_manager.py /code/events_manager.py
COPY config.py /code/config.py

# Create necessary directories
RUN mkdir -p /code/call_transcripts
RUN mkdir -p /code/db

# Copy utils directory
COPY ./utils /code/utils

# Expose the application port
EXPOSE 3000

# Run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "3000"]
