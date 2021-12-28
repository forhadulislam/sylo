FROM alpine:3.14

LABEL maintainer="Forhadul Islam"

RUN apk add make \
 && apk add gettext \
 && rm /var/cache/apk/*

RUN apk update
RUN apk --no-cache add \
    python \
    libc6-compat \
    jq \
    py-pip && \
    pip install --upgrade pip==18.1

RUN pip install shyaml \
    && pip install PyYAML

#-------------------------
COPY app /app
RUN chmod +x /app/script.sh && \
    ln -s "/app/script.sh" /usr/local/bin/validate.sh

WORKDIR /app

CMD ["sh","./script.sh"]










