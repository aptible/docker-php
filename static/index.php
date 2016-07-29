<html>
<body>
<?php
echo 'If you can see this page, PHP is running.' . PHP_EOL;
echo 'PHP was installed in ' . $_ENV['PHP_DIR'] . PHP_EOL;
echo 'However, you probably forgot to add your app in /var/www/html.' . PHP_EOL;
// However, you should not see this unless this file is loaded as HTML.
?>
</body>
</html>
