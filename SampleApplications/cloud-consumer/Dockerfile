#FROM python:3.11-slim
FROM public.ecr.aws/amazonlinux/amazonlinux:2023

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True

#RUN yum -y install librdkafka-devel

# Copy local code to the container image.
ENV APP_HOME /app
WORKDIR $APP_HOME
COPY . ./


# Install production dependencies.
RUN curl -O https://bootstrap.pypa.io/get-pip.py
RUN python3 get-pip.py --user
RUN /root/.local/bin/pip3 install --no-cache-dir -r requirements.txt

EXPOSE 8080
CMD ["gunicorn","--bind", "0.0.0.0:8080", "run_flask:app"] 
#CMD ["python3", "run_srvc.py"] 
