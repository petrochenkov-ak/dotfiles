# python3 ~/git/repo/setup.py install

for d in ~/git/*; do
    [ -e "$d"/setup.py ] && ( set -x; cd "$d" && python3 "$PWD"/setup.py install )
done
