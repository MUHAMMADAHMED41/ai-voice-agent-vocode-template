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
RUN pip install httpx
# Configure Poetry
RUN poetry config virtualenvs.create false

# Regenerate poetry.lock if necessary
RUN poetry lock 

# Install project dependencies (excluding dev dependencies)
RUN poetry install --no-root
COPY main.py /code/main.py
COPY speller_agent.py /code/speller_agent.py
COPY memory_config.py /code/memory_config.py
COPY events_manager.py /code/events_manager.py
COPY config.py /code/config.py
COPY instructions.txt /code/instructions.txt
# Create necessary directories
RUN mkdir -p /code/call_transcripts /code/db
COPY ./utils /code/utils

# Expose the application port
EXPOSE 3000

# Run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "3000"]
