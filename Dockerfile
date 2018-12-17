FROM nginx:alpine

COPY site /usr/share/nginx/html
COPY ./default.conf.template /etc/nginx/conf.d/default.conf.template
COPY ./scripts/init.sh /init.sh

CMD ["sh", "init.sh"]