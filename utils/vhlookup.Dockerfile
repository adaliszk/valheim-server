FROM adaliszk/valheim-server-utils:develop

RUN ln -s /dist/vhlookup /lookup

ENTRYPOINT ["/lookup "]
CMD ["--help"]
USER 1001
