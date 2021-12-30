FROM alpine:3.14

LABEL maintainer="Forhadul Islam"

RUN apk add make \
 && apk add gettext \
 && rm /var/cache/apk/*

RUN apk update
RUN apk --no-cache add \
    curl \ 
    py-pip \
    libc6-compat \
    jq \ 
    shellcheck && \
    pip install --upgrade pip==21.3.1

RUN pip install shyaml \
    && pip install PyYAML

#-------------------------
COPY app /app
RUN chmod +x /app/script.sh && \
    ln -s "/app/script.sh" /usr/local/bin/validate.sh

WORKDIR /app

CMD ["sh","./script.sh"]










