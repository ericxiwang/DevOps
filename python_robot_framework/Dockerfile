FROM python:3.11

LABEL maintainer="Eric Wang <gowest.wang@gmail.com>"

COPY ./app /opt/app
WORKDIR /opt/app
RUN yes | pip install -r requirements.txt
ENV PYTHONPATH=/opt/app

EXPOSE 8000/tcp
EXPOSE 8000/udp

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "main:app"]