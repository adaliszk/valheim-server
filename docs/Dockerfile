# Fix file format and permissions for the Windows peeps out there
# =================================================================================================
FROM adaliszk/valheim-server:dos2unix as unix

COPY Gemfile /bundle/
COPY jekyll.sh /scripts/
RUN dos2unix /scripts/** && chmod +x /scripts/** \
 && dos2unix /bundle/** && chmod +x /bundle/**


# Set up Jekyll with the Gems used by this project
# =================================================================================================
FROM jekyll/jekyll:stable

RUN mkdir -p /bundle && chmod 777 /bundle \
 && apk add --no-cache bash rsync

COPY --from=unix /bundle /bundle
WORKDIR /bundle

RUN bundle config set --local path "/bundle/.bundle"
RUN bundle install
RUN bundle config set --local path "/srv/jekyll/.bundle"

WORKDIR /srv/jekyll
COPY --from=unix /scripts/jekyll.sh /jekyll
ENTRYPOINT [ "/jekyll" ]
EXPOSE 4000
