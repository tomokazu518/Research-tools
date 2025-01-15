# TexLiveのレポジトリをダウンロードしてからビルドする場合

FROM rocker/rstudio:latest

ARG TARGETARCH
WORKDIR /work

# 必要なパッケージのインストール
RUN apt update && apt upgrade -y &&  \
    apt install -y \
      # tidyverse に必要
      zlib1g-dev \
      libxml2-dev \
      libcurl4-openssl-dev \
      libfontconfig1-dev \
      libharfbuzz-dev  \
      libfribidi-dev \
      libfreetype6-dev \
      libpng-dev \
      libtiff5-dev \
      libjpeg-dev \
      # sf に必要
      libudunits2-dev \
      libgdal-dev \
      # fonts
      fonts-ipafont \
      fonts-ipaexfont \
      fonts-noto-cjk \
      # tools
      gnuplot \
      ghostscript \
      # other
      openssh-client \
      curl \
      xz-utils \
      pipx \
      locales && \
    apt autoremove -y && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8  
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8  

# renv
RUN R -e "install.packages('renv')"

## github copilot
RUN echo "copilot-enabled=1" > /etc/rstudio/rsession.conf

# Pandocフィルターのインストール
## pandoc-crossref
RUN wget "https://github.com/lierdakil/pandoc-crossref/releases/download/v0.3.18.1/pandoc-crossref-Linux-X64.tar.xz"
RUN tar xf pandoc-crossref-Linux-X64.tar.xz && \
    mv pandoc-crossref /usr/bin

RUN rm /work/*.*
RUN chown rstudio:rstudio /work && chmod 755 /work
