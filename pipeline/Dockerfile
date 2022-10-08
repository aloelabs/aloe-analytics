# syntax=docker/dockerfile:experimental

FROM meltano/meltano:latest

ARG NPM_USER
ARG NPM_PASS
ARG NPM_EMAIL
ARG NPM_SCOPE

WORKDIR /project

RUN apt-get update -y && apt-get install -y openssh-client git cron curl

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash

RUN apt-get -y install nodejs
RUN apt-get -y install libpq-dev libpq5

# download public key for github.com
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# Install any additional requirements
COPY ./requirements.txt .
RUN pip install -r requirements.txt

# Install all plugins into the `.meltano` directory
COPY ./meltano.yml .
RUN --mount=type=ssh meltano install

RUN npm i -g graphql-api-to-json-schema npm-cli-login
RUN NPM_USER=${NPM_USER} NPM_PASS=${NPM_PASS} NPM_EMAIL=${NPM_EMAIL} NPM_SCOPE=${NPM_SCOPE} NPM_REGISTRY=https://npm.pkg.github.com npm-cli-login
RUN npm i -g @aloelabs/block-gobbler
ENV PATH="/usr/local/lib/node_modules/.bin:$PATH"

# Pin `discovery.yml` manifest by copying cached version to project root
RUN cp -n .meltano/cache/discovery.yml . 2>/dev/null || :

# Don't allow changes to containerized project files
ENV MELTANO_PROJECT_READONLY 1

# Copy over remaining project files
COPY . .

# Expose default port used by `meltano ui`
EXPOSE 5000

# Copy hello-cron file to the cron.d directory
COPY crontab /etc/cron.d/crontab

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/crontab

RUN chmod +x /project/scripts/*

# Apply cron job
RUN crontab /etc/cron.d/crontab

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# ENTRYPOINT ["meltano", "invoke", "airflow", "scheduler"]

ENTRYPOINT ["/project/scripts/start_container.sh"]

