SET OPT=-s 0
rem SET OPT=
mkdir out
rem ruby mksig.rb -o "out\»qΟΘ.png" "ΈήΩ°ΜίΟΘ°Όή¬°" "'14. 1.12" "»q"
rem goto END

ruby mksig.rb -f 0xff000000 -c "single" -o "out\20140610_»q.png" "mr" "'14. 6.10" "»q"
ruby mksig.rb -f 0xff000000 -c "single" -o "out\20140718_ΎY.png" "mr" "'14. 7.18" "ΎY"
ruby mksig.rb -f 0xff000000 -c "single" -o "out\20140718_Τq.png" "mr" "'14. 7.18" "Τq"
ruby mksig.rb -f 0xff000000 -c "single" -o "out\20140718_κΎY.png" "mr" "'14. 7.18" "κΎY"
ruby mksig.rb -f 0xffff0000 -b 0xffffffff -c "double" -o "out\Τ_»q.png" "mr" "'14.06.10" "»q"
ruby mksig.rb -s 1 -r 12 -o "out\XyVΐ±.png" "fl" "'14.11.12" "ΐ±"

ruby mksig.rb %OPT% -o "out\»q.png" "fl" "'14. 1.12" "»q"
ruby mksig.rb %OPT% -o "out\»q}l.png" "O[v}l-W[" "'14. 2. 9" "»q"
ruby mksig.rb %OPT% -o "out\»qΟΘ.png" "ΈήΩ°ΜίΟΘ°Όή¬°" "'14.11.12" "»q"
ruby mksig.rb %OPT% -o "out\»q00.png" "λ"                   "' 9. 1. 1" "»q"
ruby mksig.rb %OPT% -o "out\»q01.png" "λλ"                   "' 8.02.02" "»q"
ruby mksig.rb %OPT% -o "out\»q02.png" "λλσ"                 "'77. 3. 3" "»q"
ruby mksig.rb %OPT% -o "out\»q03.png" "λλσQ"               "'96.04.04" "»q"
ruby mksig.rb %OPT% -o "out\»q04.png" "λλσQγζ"             "'14. 5. 5" "»q"
ruby mksig.rb %OPT% -o "out\»q05.png" "λλσQγζλ"           "'04.06.06" "»q"
ruby mksig.rb %OPT% -o "out\»q06.png" "λλσQγζλλ"         "'13. 7. 7" "»q"
ruby mksig.rb %OPT% -o "out\»q07.png" "λλσQγζλλσ"       "' 2.08.08" "»q"
ruby mksig.rb %OPT% -o "out\»q08.png" "λλσQγζλλσQ"     "'01. 9. 9" "»q"
ruby mksig.rb %OPT% -o "out\»q09.png" "λλσQγζλλσQγζ"   "'66.10.10" "»q"
ruby mksig.rb %OPT% -o "out\»q10.png" "          "   "' 5.12.11" "»q"
:END
