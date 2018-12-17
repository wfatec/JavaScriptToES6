FROM nginx:alpine

COPY _book /usr/share/nginx/html
COPY ./default.conf.template /etc/nginx/conf.d/default.conf.template
COPY ./scripts/init.sh /init.sh

CMD ["sh", "init.sh"]