SET OPT=-s 0
rem SET OPT=
mkdir out
rem ruby mksig.rb -o "out\���q��.png" "��ٰ���Ȱ�ެ�" "'14. 1.12" "���q"
rem goto END

ruby mksig.rb -f 0xff000000 -c "single" -o "out\20140610_���q.png" "�m�r" "'14. 6.10" "���q"
ruby mksig.rb -f 0xff000000 -c "single" -o "out\20140718_���Y.png" "�m�r" "'14. 7.18" "���Y"
ruby mksig.rb -f 0xff000000 -c "single" -o "out\20140718_�Ԏq.png" "�m�r" "'14. 7.18" "�Ԏq"
ruby mksig.rb -f 0xff000000 -c "single" -o "out\20140718_�ꑾ�Y.png" "�m�r" "'14. 7.18" "�ꑾ�Y"
ruby mksig.rb -f 0xffff0000 -b 0xffffffff -c "double" -o "out\��_���q.png" "�m�r" "'14.06.10" "���q"
ruby mksig.rb -s 1 -r 12 -o "out\�X�y�V��������.png" "�f�l" "'14.11.12" "����"

ruby mksig.rb %OPT% -o "out\���q.png" "�f�l" "'14. 1.12" "���q"
ruby mksig.rb %OPT% -o "out\���q�}�l.png" "�O���[�v�}�l-�W���[" "'14. 2. 9" "���q"
ruby mksig.rb %OPT% -o "out\���q��.png" "��ٰ���Ȱ�ެ�" "'14.11.12" "���q"
ruby mksig.rb %OPT% -o "out\���q00.png" "��"                   "' 9. 1. 1" "���q"
ruby mksig.rb %OPT% -o "out\���q01.png" "���"                   "' 8.02.02" "���q"
ruby mksig.rb %OPT% -o "out\���q02.png" "����"                 "'77. 3. 3" "���q"
ruby mksig.rb %OPT% -o "out\���q03.png" "����Q"               "'96.04.04" "���q"
ruby mksig.rb %OPT% -o "out\���q04.png" "����Q��"             "'14. 5. 5" "���q"
ruby mksig.rb %OPT% -o "out\���q05.png" "����Q���"           "'04.06.06" "���q"
ruby mksig.rb %OPT% -o "out\���q06.png" "����Q����"         "'13. 7. 7" "���q"
ruby mksig.rb %OPT% -o "out\���q07.png" "����Q�����"       "' 2.08.08" "���q"
ruby mksig.rb %OPT% -o "out\���q08.png" "����Q�����Q"     "'01. 9. 9" "���q"
ruby mksig.rb %OPT% -o "out\���q09.png" "����Q�����Q��"   "'66.10.10" "���q"
ruby mksig.rb %OPT% -o "out\���q10.png" "��������������������"   "' 5.12.11" "���q"
:END
