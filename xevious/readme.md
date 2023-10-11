# web server 起動。その後、ブラウザで localhost:8000 でアクセスする
$ ruby -rwebrick -e 'WEBrick::HTTPServer.new(:DocumentRoot => "./", :Port => 8000).start'

# サーバへデプロイ
```
$ scp -r ../xevious kagoya.ubuntu20.04.developer:.
```

# サーバ設定
```
$ sudo emacs /etc/apache2/sites-available/xevious.conf
<VirtualHost *:80>
    ServerName xevious.oya3.net
    DocumentRoot /home/developer/xevious
    <Directory "/home/developer/xevious">
        Options Includes FollowSymLinks
        AllowOverride All
        Order allow,deny
        Allow from all
        Require all granted
    </Directory>
</VirtualHost>
---END---
$ sudo apache2ctl configtest
$ sudo systemctl restart apache2
```

# メモ

- 表示優先
  - group1: 地上物
  - group2: 空中：低
  - group3: 空中：player
  - group4: 空中：高

