#!/bin/bash
set -e
echo "*/5 * * * * $(which php) -f /var/www/html/bitrix/modules/main/tools/cron_events.php" | crontab -
