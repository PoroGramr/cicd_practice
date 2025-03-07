FROM ubuntu:latest
LABEL authors="park"

ENTRYPOINT ["top", "-b"]