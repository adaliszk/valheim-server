FROM python:3.8

RUN apt-get update \
 && apt-get install -y gcc python3-dev gcc ccache fuse \
 && pip install pipenv

COPY Pipfile /
WORKDIR /

RUN pipenv install --dev

COPY . /

ENTRYPOINT ["pipenv", "run"]
CMD ["build"]
