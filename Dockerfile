FROM alpine:3.13.6 AS build

ARG GIT_CHGLOG_VERSION=0.14.2
ARG SEMTAG_VERSION=0.1.1
ARG TERRAFORM_VERSION=1.0.2
ARG TERRAGRUNT_VERSION=0.31.0
COPY install.sh /tmp/install.sh

ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN chmod u+x /tmp/install.sh \
    && sh /tmp/install.sh

# TODO: use smaller base img and install psql within build
FROM alpine:3.13.6

COPY --from=build /usr/local/bin /usr/local/bin

# TODO: Figure out how to install apk packages to /usr/local/bin instead of usr/bin
# then mv runtime pkg to build stage
RUN apk add --virtual .runtime \
    bash \
    jq \
    git \
    # needed for bats --pretty formatter
    ncurses \
    && git config --global advice.detachedHead false \
    && git config --global user.email testing_user@users.noreply.github.com \
    && git config --global user.name testing_user

WORKDIR /src/tests