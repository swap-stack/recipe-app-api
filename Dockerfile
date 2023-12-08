# base image name with Python. Image Name: Python Image Tag: 3.9-alpine3.13 is the tag. 
# It ensures that we are using python 3.9 and the light weight version of linux which is ideal 
# for running docker containers. It is a bare minimum, efficient and lightweight image.

FROM python:3.9-alpine3.13

LABEL maintainer="swap-stack"

# We do not want to buffer the output from python. The output from Python will be printed directly to the console which prevents any delays of messages.
ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
# When we run the commands we dont need to specify the full path of the Django management command
COPY ./app /app

WORKDIR /app
EXPOSE 8080

ARG DEV=false

# create a virtual environment, some say it isnt necessary in docker containers but it is up to you
# upgrade pip for our virtual environment specify the full path for it
# install the requirements from the requirements file
# remove the tmp directory. Try to make the docker container as lightweight as possible and for that you should remove files that are not needed
# adds a new user. It is not a good practise to use the root user which has all the permissions (security purpose!!!!)


RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = true ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -r /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user
# creates an environment variable in the linux. We do this so that every time we dont have to specify the full path to access our environment

ENV PATH="/py/bin:$PATH"

USER django-user
