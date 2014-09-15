SET OPT=-s 0
rem SET OPT=
mkdir out
rem ruby mksig.rb -o "out\判子ﾏﾈ.png" "ｸﾞﾙｰﾌﾟﾏﾈｰｼﾞｬｰ" "'14. 1.12" "判子"
rem goto END

ruby mksig.rb -f 0xff000000 -c "single" -o "out\20140610_判子.png" "ＮＳ" "'14. 6.10" "判子"
ruby mksig.rb -f 0xff000000 -c "single" -o "out\20140718_太郎.png" "ＮＳ" "'14. 7.18" "太郎"
ruby mksig.rb -f 0xff000000 -c "single" -o "out\20140718_花子.png" "ＮＳ" "'14. 7.18" "花子"
ruby mksig.rb -f 0xff000000 -c "single" -o "out\20140718_一太郎.png" "ＮＳ" "'14. 7.18" "一太郎"
ruby mksig.rb -f 0xffff0000 -b 0xffffffff -c "double" -o "out\赤_判子.png" "ＮＳ" "'14.06.10" "判子"
ruby mksig.rb -s 1 -r 12 -o "out\スペシャル実験.png" "ＧＭ" "'14.11.12" "実験"

ruby mksig.rb %OPT% -o "out\判子.png" "ＧＭ" "'14. 1.12" "判子"
ruby mksig.rb %OPT% -o "out\判子マネ.png" "グループマネ-ジャー" "'14. 2. 9" "判子"
ruby mksig.rb %OPT% -o "out\判子ﾏﾈ.png" "ｸﾞﾙｰﾌﾟﾏﾈｰｼﾞｬｰ" "'14.11.12" "判子"
ruby mksig.rb %OPT% -o "out\判子00.png" "零"                   "' 9. 1. 1" "判子"
ruby mksig.rb %OPT% -o "out\判子01.png" "零壱"                   "' 8.02.02" "判子"
ruby mksig.rb %OPT% -o "out\判子02.png" "零壱弐"                 "'77. 3. 3" "判子"
ruby mksig.rb %OPT% -o "out\判子03.png" "零壱弐参"               "'96.04.04" "判子"
ruby mksig.rb %OPT% -o "out\判子04.png" "零壱弐参肆"             "'14. 5. 5" "判子"
ruby mksig.rb %OPT% -o "out\判子05.png" "零壱弐参肆零"           "'04.06.06" "判子"
ruby mksig.rb %OPT% -o "out\判子06.png" "零壱弐参肆零壱"         "'13. 7. 7" "判子"
ruby mksig.rb %OPT% -o "out\判子07.png" "零壱弐参肆零壱弐"       "' 2.08.08" "判子"
ruby mksig.rb %OPT% -o "out\判子08.png" "零壱弐参肆零壱弐参"     "'01. 9. 9" "判子"
ruby mksig.rb %OPT% -o "out\判子09.png" "零壱弐参肆零壱弐参肆"   "'66.10.10" "判子"
ruby mksig.rb %OPT% -o "out\判子10.png" "國國國國國國國國國國"   "' 5.12.11" "判子"
:END
