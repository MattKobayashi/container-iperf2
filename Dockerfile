FROM alpine:3.23.2@sha256:c93cec902b6a0c6ef3b5ab7c65ea36beada05ec1205664a4131d9e8ea13e405d AS buildenv

ENV SOURCE_URL=https://downloads.sourceforge.net/project/iperf2/iperf-2.2.1.tar.gz \
    SOURCE_SHA256SUM=5f42447763e4f42ed1242abe3249289b4b423254c47afee16f2356896631bdc8

# Download source file, extract and compile
WORKDIR /iperf2
COPY iperf-2.2.1.tar /iperf2/
RUN apk --no-cache add tar build-base \
    && echo "${SOURCE_SHA256SUM}  $(ls *.tar)" > iperf2.sha256 \
    && sha256sum -c iperf2.sha256 \
    && for tarfile in *.tar; do tar -x --strip-components=1 --file="$tarfile"; done \
    && ./configure \
    && make \
    && make install

FROM alpine:3.23.2@sha256:c93cec902b6a0c6ef3b5ab7c65ea36beada05ec1205664a4131d9e8ea13e405d

# Copy relevant compiled files to distribution image
RUN adduser --system iperf2 \
    && apk --no-cache add libgcc libstdc++
COPY --from=buildenv /usr/local/bin/ /usr/local/bin/
COPY --from=buildenv /usr/local/share/man/ /usr/local/share/man/

# Switch to non-root user
USER iperf2

# Set expose port and entrypoint
EXPOSE 5001
ENTRYPOINT ["iperf"]

LABEL org.opencontainers.image.authors="MattKobayashi <matthew@kobayashi.au>"
