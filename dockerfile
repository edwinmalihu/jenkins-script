# Gunakan image dasar Alpine Linux yang sangat ringan
FROM alpine:latest


# Install dependencies menggunakan package manager apk
RUN apk add --no-cache \
    git \
    podman \
    curl \
    unzip \
    shadow

# --- PENYIAPAN USER DAN HOME DIREKTORI (KUNCI UTAMA) ---

RUN mkdir -p /run/podman /var/lib/containers/storage && \
    printf '[storage]\ndriver = "vfs"\nrunroot = "/run/podman"\ngraphroot = "/var/lib/containers/storage"\n' > /etc/containers/storage.conf

# 1. Buat user dan grup generik di dalam image.
#    Kita beri nama 'appuser' dengan home direktori di /home/appuser
#    UID/GID tidak terlalu penting karena akan ditimpa oleh Jenkins,
#    tapi direktorinya harus ada.
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup -h /home/appuser

# 2. Atur izin agar home direktori ini BISA DITULIS OLEH USER MANAPUN.
#    Ini sangat penting agar user 503 dari Jenkins bisa menulis di sini.
RUN chmod -R 777 /home/appuser

# 3. Atur environment variable HOME secara permanen.
#    Ini memberitahu SEMUA proses di mana home direktori berada.
ENV HOME=/home/appuser

# --- INSTALASI TOOLS ---

# Install flyctl dan pindahkan ke lokasi global
RUN curl -L https://fly.io/install.sh | sh && \
    mv /home/appuser/.fly/bin/flyctl /usr/local/bin/flyctl && \
    ln -s /usr/local/bin/flyctl /usr/local/bin/fly && \
    rm -rf /home/appuser/.fly

# Atur working directory di dalam container ke home direktori
WORKDIR /home/appuser

# Set default command saat container dijalankan
CMD ["sh"]