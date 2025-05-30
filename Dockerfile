FROM alpine:3.22.0@sha256:8a1f59ffb675680d47db6337b49d22281a139e9d709335b492be023728e11715 AS buildenv

ENV SOURCE_URL=https://ixpeering.dl.sourceforge.net/project/iperf2/iperf-2.2.1.tar.gz \
    SOURCE_SHA1SUM=9b30b1f3140d4f714555fee5ed21aa2bf4046aee

# Download source file, extract and compile
WORKDIR /iperf2
RUN apk --no-cache add tar build-base \
    && wget "$SOURCE_URL" \
    && echo "${SOURCE_SHA1SUM}  $(ls *.tar.gz)" > iperf2.sha1 \
    && sha1sum -c iperf2.sha1 \
    && for tarfile in *.tar.gz; do tar -xz --strip-components=1 --file="$tarfile"; done \
    && ./configure \
    && make \
    && make install

FROM alpine:3.22.0@sha256:8a1f59ffb675680d47db6337b49d22281a139e9d709335b492be023728e11715

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
