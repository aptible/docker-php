<?php
$url = 'mysql:host=mysql;dbname=db;charset=utf8';
$user = 'aptible';
$pass = getenv('PASSPHRASE');

# This one should succeed
echo "Test: connect with MYSQL_ATTR_SSL_VERIFY_SERVER_CERT: ";

try {
new PDO(
  $url, $user, $pass,
  array(
    PDO::MYSQL_ATTR_SSL_CIPHER => 'DHE-RSA-AES256-SHA',
    PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT => false
  )
);
} catch (PDOException $e) {
  echo "fail!\n";
  exit(1);
}

echo "pass\n";

# This one should fail!
echo "Test: connect without MYSQL_ATTR_SSL_VERIFY_SERVER_CERT: ";

$erred = false;

try {
  new PDO(
    $url, $user, $pass,
    array(
      PDO::MYSQL_ATTR_SSL_CIPHER => 'DHE-RSA-AES256-SHA',
    )
  );
} catch (PDOException $e) {
  $erred = true;
}

if (!$erred) {
  echo "fail!\n";
  exit(1);
}

echo "pass\n";

exit(0);
?>
