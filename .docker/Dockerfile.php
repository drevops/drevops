# @see https://github.com/amazeeio/lagoon/tree/master/images/php/fpm
ARG CLI_IMAGE
FROM ${CLI_IMAGE:-cli} as cli

FROM amazeeio/php:7.2-fpm-v0.22.1

# Enable Xdebug only if XDEBUG_ENABLE has a value.
# @see https://github.com/amazeeio/lagoon/issues/1170
COPY .docker/scripts/60-php-xdebug.sh /lagoon/entrypoints/60-php-xdebug.sh
COPY .docker/scripts/61-php-xdebug-cli-env.sh /lagoon/entrypoints/61-php-xdebug-cli-env.sh

COPY --from=cli /app /app
