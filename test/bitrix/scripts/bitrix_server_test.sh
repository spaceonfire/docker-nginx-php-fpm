#!/bin/bash
set -e

if [ ! -f bitrix_server_test.php ]; then
	wget http://dev.1c-bitrix.ru/download/scripts/bitrix_server_test.php
fi
