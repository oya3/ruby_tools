# web server 起動。その後、ブラウザで localhost:8000 でアクセスする
$ ruby -rwebrick -e 'WEBrick::HTTPServer.new(:DocumentRoot => "./", :Port => 8000).start'


