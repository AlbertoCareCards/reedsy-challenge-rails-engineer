#
# =========================================================
FROM ruby:3.0-slim-bullseye

# Install required project packages
# =================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Listen to 5432 port for running database creation/migrations
    netcat \
    # Install editor for Rails secret edition
    vim \
    # Rails required packages
    tzdata \
    build-essential \
    libpq-dev \
    postgresql-client \
    git \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create Container User
# =====================
RUN adduser reedy-user
USER reedy-user

# Copy application into container and set up permissions
# ======================================================
WORKDIR /home/app/reedsy-challenge

# Set up bundler
# ==============
RUN gem update --system 3.2.3
RUN gem install bundler --no-document

# Install Project
# ===============
COPY --chown=reedy-user Gemfile /home/app/reedsy-challenge/
RUN bundle install

COPY --chown=reedy-user . /home/app/reedsy-challenge