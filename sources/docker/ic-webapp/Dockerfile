FROM python:3.6-alpine
WORKDIR /opt
EXPOSE 8080
ENV ODOO_URL=https://www.odoo.com/
ENV PGADMIN_URL=https://www.pgadmin.org/

RUN pip install flask==1.1.2
ADD https://github.com/sadofrazer/ic-webapp/archive/refs/heads/master.zip /opt
RUN unzip master.zip

ADD ../releases.txt /opt
ADD run_flask.sh /opt
ADD convert.sh /opt
RUN sh convert.sh

ENTRYPOINT ["/bin/sh", "run_flask.sh"]
