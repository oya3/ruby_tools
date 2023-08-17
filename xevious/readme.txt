# web server 起動。その後、ブラウザで localhost:8000 でアクセスする
$ ruby -rwebrick -e 'WEBrick::HTTPServer.new(:DocumentRoot => "./", :Port => 8000).start'

# 表示優先
# group1: 地上物
# group2: 空中：低
# group3: 空中：player
# group4: 空中：高
