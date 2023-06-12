FROM python:3.8-slim-buster as builder

WORKDIR /app

RUN adduser --disabled-password --gecos '' appuser

USER appuser

COPY --chown=appuser:appuser requirements.txt requirements.txt

RUN pip3 install --user -r requirements.txt

FROM python:3.8-slim-buster as runner

WORKDIR /app

RUN adduser --disabled-password --gecos '' appuser

USER appuser

COPY --from=builder --chown=appuser:appuser /home/appuser/.local /home/appuser/.local
COPY --chown=appuser:appuser . /app

ENV PATH=/home/appuser/.local/bin:$PATH

CMD ["python3", "-m", "flask", "run", "--host=0.0.0.0"]

